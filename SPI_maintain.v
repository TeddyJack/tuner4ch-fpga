`include "defines.v"

module SPI_maintain(
input CLK,
input RST,
input [6:0] SPI_ADDRESS,
input [7:0] SPI_DATA,
input SPI_ENA,
output reg [7:0] DATA_TO_MISO,

input [3:0] header_byte_addr,
output [7:0] header_byte,

input [127:0] byterate_bus
);

/*
reg [1:0] select;							// what goes to ASI output selected by SPI control

always@(posedge CLK or negedge RST)
begin
if(!RST)
	begin
	RESET_ON_CHANGE_OUT <= 1'b0;
	end
else if(RISING_SS && (SPI_ADDRESS == `ADDR_OUT_SELECT))
	begin
	select <= SPI_DATA[1:0];
	RESET_ON_CHANGE_OUT <= 1'b1;
	end
else
	RESET_ON_CHANGE_OUT <= 1'b0;
end
*/

reg [7:0] header_2d_array [15:0];
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

always@(posedge CLK)
begin
if(SPI_ENA)
	begin
	if((SPI_ADDRESS >= `ADDR_HEADR_FIRST) && (SPI_ADDRESS <= `ADDR_HEADR_LAST))
		header_2d_array[SPI_ADDRESS-`ADDR_HEADR_FIRST] <= SPI_DATA;
	end
end

assign header_byte = header_2d_array[header_byte_addr];

wire [7:0] byterate_array [15:0];
genvar i;
genvar j;
generate
for(i=0; i<4; i=i+1)
	begin: hey
	for(j=0; j<4; j=j+1)
		begin: wow
		assign byterate_array[4*i+j] = byterate_bus[(8*(4*i+3-j)+7):(8*(4*i+3-j))];	// cast from bus to array with reversing bytes in every int_32
		end
	end
endgenerate
//generate
//for(i=0; i<16; i=i+1)
//	begin: wow
//	assign byterate_array[i] = byterate_bus[(8*i+7):(8*i)];
//	end
//endgenerate


always@(posedge CLK)
begin
if((SPI_ADDRESS >= `ADDR_BRATE_FIRST) && (SPI_ADDRESS <= `ADDR_BRATE_LAST))
	DATA_TO_MISO <= byterate_array[SPI_ADDRESS-`ADDR_BRATE_FIRST];
end

endmodule
