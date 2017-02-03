// для своевременного вычитывания пакетов из буферов, необходимо, чтобы F_read >= (4 x F_write_max), а лучше (5 x F_write_max)

`include "defines.v"

module source_switch(		// здесь сформировать give_me_one_packet для каждого источника
input SYS_CLK,
input RST,
input [3:0] GOT_FULL_PACKET,

input [31:0] DATA_IN_BUS,

input [7:0] SPI_ADDRESS,
input [7:0] SPI_DATA,
input RISING_SS,

output reg [3:0] RD_REQ,

output [7:0] DATA_OUT,
output DCLK_OUT,
output D_VALID_OUT,
output reg P_SYNC_OUT,

output [1:0] state_mon,
output error_detector
);

assign state_mon = state;
assign error_detector = ((byte_counter == 8'd5) && (DATA_OUT != 8'h47)) || ((byte_counter == 8'd1) && (DATA_OUT == 8'h47));

//reg [7:0] header_3d_array [3:0][3:0];		// 
//reg [7:0] src;										// число, номер источника
//initial
//begin
//for(src=0; src<4; src=src+1'b1)
//	begin
//	header_3d_array[src][0] = src;			// PLP ID
//	header_3d_array[src][1] = src + 8'd2;	// stream source
//	header_3d_array[src][2] = 8'h00;			// reserved
//	header_3d_array[src][3] = 8'h00;			// reserved
//	end
//end
reg [7:0] header_2d_array [15:0];		// 
reg [7:0] src;										// число, номер источника
initial
begin
for(src=0; src<4; src=src+1'b1)
	begin
	header_2d_array[(src<<2) + 2'h0] = src;			// PLP ID				// (<<2) = (*4)
	header_2d_array[(src<<2) + 2'h1] = src + 8'd2;	// stream source
	header_2d_array[(src<<2) + 2'h2] = 8'h00;			// reserved
	header_2d_array[(src<<2) + 2'h3] = 8'h00;			// reserved
	end
end



assign DCLK_OUT = SYS_CLK;
wire [7:0] DATA_IN [3:0];

genvar i;
generate
for(i=0; i<4; i=i+1)
	begin: wow
	assign DATA_IN[i] = DATA_IN_BUS[(8*i+7):(8*i)];
	end
endgenerate

reg [1:0] state;
parameter [1:0] check_source		= 2'h0;
parameter [1:0] fill_header		= 2'h1;
parameter [1:0] forward_packet	= 2'h2;

reg [1:0] source_counter;
reg [7:0] byte_counter;
reg d_valid_header;
assign D_VALID_OUT = d_valid_header || RD_REQ[source_counter];
assign DATA_OUT = (state == fill_header) ? (data_header) : (DATA_IN[source_counter]);
reg [7:0] data_header;

always@(posedge SYS_CLK or negedge RST)
begin
if(!RST)
	begin
	source_counter <= 0;
	state <= check_source;
	byte_counter <= 0;
	P_SYNC_OUT <= 0;
	RD_REQ <= 4'b0000;
	d_valid_header <= 0;
	data_header <= 0;
	end
else
	case(state)
	check_source:
		begin
		if(GOT_FULL_PACKET[source_counter])
			begin
			state <= fill_header;
			end
		else
			source_counter <= source_counter + 1'b1;
		end
	fill_header:
		begin
		if(byte_counter < 4)
			begin
			data_header <= header_2d_array[(source_counter<<2) + byte_counter];
			d_valid_header <= 1;
			byte_counter <= byte_counter + 1'b1;
			end
		else
			begin
			d_valid_header <= 0;
			state <= forward_packet;
			end
		end
	forward_packet:
		begin
		if(byte_counter < 8'd192)
			begin
			RD_REQ[source_counter] <= 1;
			byte_counter <= byte_counter + 1'b1;
			if(byte_counter == 8'd4)
				P_SYNC_OUT <= 1;
			else
				P_SYNC_OUT <= 0;
			end
		else
			begin
			byte_counter <= 0;
			RD_REQ[source_counter] <= 0;
			source_counter <= source_counter + 1'b1;
			state <= check_source;
			end
		end
	endcase
end

always@(posedge SYS_CLK)
begin
if(RISING_SS && (SPI_ADDRESS >= `ADDR_HEADR_FIRST) && (SPI_ADDRESS <= `ADDR_HEADR_LAST))
	header_2d_array[SPI_ADDRESS-`ADDR_HEADR_FIRST] <= SPI_DATA;
end


endmodule
