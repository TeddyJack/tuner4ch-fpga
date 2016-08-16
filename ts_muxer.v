module ts_muxer(
input CLK_IN,		// 25 or 50 MHz
input RST,
input [1:0] SW,	// jumpers

input SCLK,
input nSS,
input MOSI,

input [7:0] DATA_0,
input DCLK_0,
input D_VALID_0,
input P_SYNC_0,

input [7:0] DATA_1,
input DCLK_1,
input D_VALID_1,
input P_SYNC_1,

input [7:0] DATA_2,
input DCLK_2,
input D_VALID_2,
input P_SYNC_2,

input [7:0] DATA_3,
input DCLK_3,
input D_VALID_3,
input P_SYNC_3,

output [7:0] DATA_OUT,		// pseudo TS ouput
output DCLK_OUT,
output reg D_VALID_OUT,
output P_SYNC_OUT,

output [7:0] DATA_OUT_ASI,	// TS output to ASI transmitter, contains one of the source streams reclocked to 27 MHz
output DCLK_OUT_ASI,
output reg D_VALID_OUT_ASI,

output [3:0] LEDS,
output MISO

);

pll_for_ts_muxer pll_for_ts_muxer(
.inclk0(CLK_IN),
.c0(sys_clk),
.c1(clk_27)
);
wire sys_clk;
wire clk_27;

reclock_and_prepare reclock_and_prepare_0(
.SYS_CLK(sys_clk),
.RST(RST),
.DATA(DATA_0),
.DCLK(DCLK_0),
.D_VALID(D_VALID_0),
.P_SYNC(P_SYNC_0),
.GIVE_ME_ONE_PACKET(give_me_one_packet[0]),

.GOT_FULL_PACKET(got_full_packet[0]),
.DATA_OUT(data_out_0)
);
wire [7:0] data_out_0;

reclock_and_prepare reclock_and_prepare_1(
.SYS_CLK(sys_clk),
.RST(RST),
.DATA(DATA_1),
.DCLK(DCLK_1),
.D_VALID(D_VALID_1),
.P_SYNC(P_SYNC_1),
.GIVE_ME_ONE_PACKET(give_me_one_packet[1]),

.GOT_FULL_PACKET(got_full_packet[1]),
.DATA_OUT(data_out_1)
);
wire [7:0] data_out_1;

reclock_and_prepare reclock_and_prepare_2(
.SYS_CLK(sys_clk),
.RST(RST),
.DATA(DATA_2),
.DCLK(DCLK_2),
.D_VALID(D_VALID_2),
.P_SYNC(P_SYNC_2),
.GIVE_ME_ONE_PACKET(give_me_one_packet[2]),

.GOT_FULL_PACKET(got_full_packet[2]),
.DATA_OUT(data_out_2)
);
wire [7:0] data_out_2;

reclock_and_prepare reclock_and_prepare_3(
.SYS_CLK(sys_clk),
.RST(RST),
.DATA(DATA_3),
.DCLK(DCLK_3),
.D_VALID(D_VALID_3),
.P_SYNC(P_SYNC_3),
.GIVE_ME_ONE_PACKET(give_me_one_packet[3]),

.GOT_FULL_PACKET(got_full_packet[3]),
.DATA_OUT(data_out_3)
);
wire [7:0] data_out_3;


wire [3:0] got_full_packet;
source_switch source_switch(
.SYS_CLK(sys_clk),
.RST(RST),
.GOT_FULL_PACKET(got_full_packet),
.DATA_IN_0(data_out_0),
.DATA_IN_1(data_out_1),
.DATA_IN_2(data_out_2),
.DATA_IN_3(data_out_3),
.GIVE_ME_ONE_PACKET(give_me_one_packet),

.DATA_OUT(data_out_54),
.DCLK_OUT(dclk_out_54),
.D_VALID_OUT(d_valid_out_54),
.P_SYNC_OUT(p_sync_out_54)
);
wire [3:0] give_me_one_packet;
wire [7:0] data_out_54;
wire dclk_out_54;
wire d_valid_out_54;
wire p_sync_out_54;


out_fifo out_fifo(
.aclr(!RST),
.data({p_sync_out_54,data_out_54}),
.rdclk(clk_27),
.rdreq(!fifo_empty),
.wrclk(dclk_out_54),
.wrreq(d_valid_out_54),
.q({P_SYNC_OUT,DATA_OUT}),
.rdempty(fifo_empty)
);
wire fifo_empty;
assign DCLK_OUT = clk_27;

always@(posedge clk_27 or negedge RST)
begin
if(!RST)
	D_VALID_OUT <= 0;
else
	D_VALID_OUT <= !fifo_empty;
end

SPI SPI(
.CLK(sys_clk),
.RST(RST),
.SCLK(SCLK),
.MOSI(MOSI),
.SS(!nSS),

.SPI_ADDRESS(spi_address),
.SPI_DATA(spi_data),
.RISING_SS(rising_ss),
.MISO(MISO)
);
wire [7:0] spi_address;
wire [7:0] spi_data;
wire rising_ss;

select_output select_output(
.CLK(sys_clk),
.RST(RST),
.SPI_ADDRESS(spi_address),
.SPI_DATA(spi_data),
.RISING_SS(rising_ss),

.SW(SW),

.DATA_IN_0(DATA_0),
.DATA_IN_1(DATA_1),
.DATA_IN_2(DATA_2),
.DATA_IN_3(DATA_3),
.DCLK_BUS({DCLK_3,DCLK_2,DCLK_1,DCLK_0}),
.D_VALID_BUS({D_VALID_3,D_VALID_2,D_VALID_1,D_VALID_0}),
.P_SYNC_BUS({P_SYNC_3,P_SYNC_2,P_SYNC_1,P_SYNC_0}),

.DATA_OUT(data_from_selector),
.DCLK_OUT(dclk_from_selector),
.D_VALID_OUT(d_valid_from_selector),
.P_SYNC_OUT(p_sync_from_selector),

.RESET_ON_CHANGE_OUT(reset_on_change_out)
);
wire [7:0] data_from_selector;
wire dclk_from_selector;
wire d_valid_from_selector;
wire p_sync_from_selector;
wire reset_on_change_out;

out_fifo out_fifo_asi(
.aclr((!RST) || (reset_on_change_out)),				// not sure we need this extra reset
.data({1'b0,data_from_selector}),						// data is 9 bit wide. we replace data[8] (reserved for psync) with 0, because p_sync on the output of fifo is not needed
.rdclk(clk_27),
.rdreq(!fifo_asi_empty),
.wrclk(dclk_from_selector),
.wrreq(d_valid_from_selector),
.q(psync_and_dout_asi),
.rdempty(fifo_asi_empty)
);
wire fifo_asi_empty;
assign DCLK_OUT_ASI = clk_27;
wire [8:0] psync_and_dout_asi;
assign DATA_OUT_ASI = psync_and_dout_asi[7:0];

always@(posedge clk_27 or negedge RST)
begin
if(!RST)
	D_VALID_OUT_ASI <= 0;
else
	D_VALID_OUT_ASI <= !fifo_asi_empty;
end

led_lighter led_lighter_0(
.CLK(sys_clk),
.RST(RST),
.SIGNAL_IN(give_me_one_packet[0]),
.LED(LEDS[0])
);
led_lighter led_lighter_1(
.CLK(sys_clk),
.RST(RST),
.SIGNAL_IN(give_me_one_packet[1]),
.LED(LEDS[1])
);
led_lighter led_lighter_2(
.CLK(sys_clk),
.RST(RST),
.SIGNAL_IN(give_me_one_packet[2]),
.LED(LEDS[2])
);
led_lighter led_lighter_3(
.CLK(sys_clk),
.RST(RST),
.SIGNAL_IN(give_me_one_packet[3]),
.LED(LEDS[3])
);

endmodule
