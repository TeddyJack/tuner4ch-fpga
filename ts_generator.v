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
assign D_VALID = 1'b1;

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
	if(byte_counter < 8'd187)
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
	begin
	if(byte_counter == 8'd0)
		begin
		P_SYNC <= 1;
		DATA <= 8'h47;
		end
	else if(byte_counter == 8'd1)
		begin
		P_SYNC <= 0;
		DATA <= PID[12:8];
		end
	else if(byte_counter == 8'd2)
		DATA <= PID[7:0];
	else if(byte_counter == 8'd3)
		DATA <= 8'h10 + contin_counter;		// 8'h10 is mask for payload flag
	else
		DATA <= PID[7:0];
	end
end

endmodule
