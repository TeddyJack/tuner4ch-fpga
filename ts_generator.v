module ts_generator(
input CLK,
input RST,
input [12:0] PID,

output reg [7:0] DATA,
output D_CLK,
output D_VALID,
output reg P_SYNC
);

assign D_CLK = CLK;
assign D_VALID = 1;

reg [7:0] byte_counter;
reg [3:0] contin_counter;
always@(posedge CLK or negedge RST)
begin
if(!RST)
	begin
	byte_counter <= 0;
	contin_counter <= 0;
	end
else
	begin
	if(byte_counter < 187)
		byte_counter <= byte_counter + 1'b1;
	else
		begin
		byte_counter <= 0;
		contin_counter <= contin_counter + 1'b1;
		end
	end
end

always@(posedge CLK or negedge RST)
begin
if(!RST)
	begin
	P_SYNC <= 0;
	DATA <= 0;
	end
else
	case(byte_counter)
	0:	begin
		P_SYNC <= 1;
		DATA <= 8'h47;
		end
	1:	begin
		P_SYNC <= 0;
		DATA <= PID[12:8];
		end
	2:	begin
		DATA <= PID[7:0];
		end
	3:	begin
		DATA <= 8'h10 + contin_counter;		// 8'h10 is mask for payload flag
		end
	default:
		DATA <= PID[7:0];
	endcase
end

endmodule
