`include "defines.v"

module select_output(
input CLK,
input RST,
input [7:0] SPI_ADDRESS,
input [7:0] SPI_DATA,
input RISING_SS,

input [1:0] SW,

input [31:0] DATA_IN_BUS,
input [3:0] DCLK_BUS,
input [3:0] D_VALID_BUS,
input [3:0] P_SYNC_BUS,

output [7:0] DATA_OUT,
output DCLK_OUT,
output D_VALID_OUT,
output P_SYNC_OUT,

output reg RESET_ON_CHANGE_OUT
);

wire [7:0] DATA_IN [3:0];
genvar i;
generate
for(i=0; i<4; i=i+1)
	begin: wow
	assign DATA_IN[i] = DATA_IN_BUS[(8*i+7):(8*i)];
	end
endgenerate

assign DATA_OUT = DATA_IN[select];
assign DCLK_OUT = DCLK_BUS[select];
assign D_VALID_OUT = D_VALID_BUS[select];
assign P_SYNC_OUT = P_SYNC_BUS[select];

wire [1:0] select = SW;						// what goes to ASI output selected by "switch"
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
endmodule
