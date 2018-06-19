module ts_muxer(
input CLK_IN,		// 25 or 50 MHz
input RST,
input [1:0] SW,	// jumpers

input SCLK,
input nSS,
input MOSI,

input [31:0] DATA,
input [3:0] DCLK,
input [3:0] D_VALID,
input [3:0] P_SYNC,

output [7:0] DATA_OUT,		// pseudo TS ouput
output DCLK_OUT,
output D_VALID_OUT,
output P_SYNC_OUT,

output [7:0] DATA_OUT_ASI,	// TS output to ASI transmitter, contains one of the source streams reclocked to 27 MHz
output DCLK_OUT_ASI,
output D_VALID_OUT_ASI,

output [3:0] LEDS,
output MISO
);

assign DCLK_OUT = !clk_27;				// inversion of clock. not sure about it
assign DCLK_OUT_ASI = DCLK_OUT;
assign D_VALID_OUT_ASI = D_VALID_OUT;
assign DATA_OUT_ASI = DATA_OUT;

pll_for_ts_muxer pll_for_ts_muxer(
.inclk0(CLK_IN),
.c0(clk_27)
);
wire clk_27;

genvar i;
generate
for(i=0; i<4; i=i+1)
	begin: wow
	reclock_and_prepare reclock_and_prepare(
	.SYS_CLK(clk_27),
	.RST(RST),
	.DATA(DATA[(8*i+7):(8*i)]),
	.DCLK(DCLK[i]),
	.D_VALID(D_VALID[i]),
	.P_SYNC(P_SYNC[i]),
	.RD_REQ(rd_req[i]),
	
	.GOT_FULL_PACKET(got_full_packet[i]),
	.DATA_OUT(data_out_bus[(8*i+7):(8*i)]),
	.BYTERATE(byterate_bus[(32*i+31):(32*i)])
	);
	
	led_lighter led_lighter(
	.CLK(clk_27),
	.RST(RST),
	.SIGNAL_IN(rd_req[i]),
	.LED(LEDS[i])
	);
	end
endgenerate
wire [31:0] data_out_bus;
wire [127:0] byterate_bus;


wire [3:0] got_full_packet;
source_switch source_switch(
.SYS_CLK(clk_27),
.RST(RST),
.GOT_FULL_PACKET(got_full_packet),
.DATA_IN_BUS(data_out_bus),
.header_byte_addr(header_byte_addr),
.header_byte(header_byte),

.RD_REQ(rd_req),
.DATA_OUT(DATA_OUT),
.D_VALID_OUT(D_VALID_OUT),
.P_SYNC_OUT(P_SYNC_OUT)
);
wire [3:0] rd_req;

SPI SPI(
.CLK(clk_27),
.RST(RST),
.SCLK(SCLK),
.MOSI(MOSI),
.SS(nSS),

.SPI_ADDRESS(spi_address),
.SPI_DATA(spi_data),
.SPI_ENA(spi_ena),
.MISO(MISO),
.DATA_IN(data_to_miso)
);
wire [6:0] spi_address;
wire [7:0] spi_data;
wire spi_ena;

SPI_maintain SPI_maintain(
.CLK(clk_27),
.RST(RST),
.SPI_ADDRESS(spi_address),
.SPI_DATA(spi_data),
.SPI_ENA(spi_ena),

.header_byte_addr(header_byte_addr),
.header_byte(header_byte),
.byterate_bus(byterate_bus),
.DATA_TO_MISO(data_to_miso)
);
wire [3:0] header_byte_addr;
wire [7:0] header_byte;
wire [7:0] data_to_miso;


endmodule
