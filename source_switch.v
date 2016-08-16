// для своевременного вычитывания пакетов из буферов, необходимо, чтобы F_read >= (4 x F_write_max), а лучше (5 x F_write_max)

`include "defines.v"

module source_switch(		// здесь сформировать give_me_one_packet для каждого источника
input SYS_CLK,
input RST,
input [3:0] GOT_FULL_PACKET,
input [7:0] DATA_IN_0,
input [7:0] DATA_IN_1,
input [7:0] DATA_IN_2,
input [7:0] DATA_IN_3,

input [7:0] SPI_ADDRESS,
input [7:0] SPI_DATA,
input RISING_SS,

output reg [3:0] GIVE_ME_ONE_PACKET,

output reg [7:0] DATA_OUT,
output DCLK_OUT,
output reg D_VALID_OUT,
output reg P_SYNC_OUT

);

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
wire [7:0] DATA_IN_BUS [3:0];
assign DATA_IN_BUS[0]	= DATA_IN_0;
assign DATA_IN_BUS[1]	= DATA_IN_1;
assign DATA_IN_BUS[2]	= DATA_IN_2;
assign DATA_IN_BUS[3]	= DATA_IN_3;

reg [1:0] state;
parameter [1:0] check_source		= 2'h0;
parameter [1:0] fill_header		= 2'h1;
parameter [1:0] forward_packet	= 2'h2;

reg [1:0] source_counter;
reg [7:0] byte_counter;

always@(posedge SYS_CLK or negedge RST)
begin
if(!RST)
	begin
	source_counter <= 0;
	state <= check_source;
	byte_counter <= 0;
	DATA_OUT <= 0;
	GIVE_ME_ONE_PACKET <= 4'b0000;
	P_SYNC_OUT <= 0;
	D_VALID_OUT <= 0;
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
		DATA_OUT <= header_2d_array[(source_counter<<2) + byte_counter];	// (<<2) = (*4)
		byte_counter <= byte_counter + 1'b1;
		if(byte_counter == 8'd0)
			D_VALID_OUT <= 1;
		else if(byte_counter == 8'd1)						// чтобы ts пакет попал сразу после псевдо-заголовка, запрос на пакет надо выдать здесь
			GIVE_ME_ONE_PACKET[source_counter] <= 1;
		else if(byte_counter == 8'd3)
			state <= forward_packet;
		else
			GIVE_ME_ONE_PACKET[source_counter] <= 0;
		end
	forward_packet:
		begin
		if(byte_counter < 8'd192)
			begin
			DATA_OUT <= DATA_IN_BUS[source_counter];
			byte_counter <= byte_counter + 1'b1;
			if(byte_counter == 8'd4)
				P_SYNC_OUT <= 1;
			else
				P_SYNC_OUT <= 0;
			end
		else
			begin
			byte_counter <= 0;
			D_VALID_OUT <= 0;
			source_counter <= source_counter + 1'b1;
			state <= check_source;
			DATA_OUT <= 0;
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
