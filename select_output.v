module select_output(
input CLK,
input RST,

input [1:0] SW,

input [31:0] DATA_IN_BUS,
input [3:0] DCLK_BUS,
input [3:0] D_VALID_BUS,

output [7:0] DATA_OUT,
output DCLK_OUT,
output D_VALID_OUT,

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

wire [1:0] select = SW;						// what goes to ASI output selected by "switch"

endmodule
