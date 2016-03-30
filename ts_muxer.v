module ts_muxer(
input EXT_CLK_IN,		// 25 or 41 or 16 MHz
input RST,
//input [1:0] SWITCH,	// jumpers

input SCLK,
input SS_inv,
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

output [7:0] DATA_OUT,
output DCLK_OUT,
output reg D_VALID_OUT,
output P_SYNC_OUT

//output [4:0] LEDS,
//output MISO

);

pll_for_ts_muxer pll_for_ts_muxer(
.inclk0(EXT_CLK_IN),
.c0(sys_clk),
.c1(clk_27)
);
wire sys_clk;
wire clk_27;

reclock_and_prep_via_rams reclock_and_prepare_0(
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

reclock_and_prep_via_rams reclock_and_prepare_1(
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

reclock_and_prep_via_rams reclock_and_prepare_2(
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

reclock_and_prep_via_rams reclock_and_prepare_3(
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
.rdempty(fifo_empty),
.wrusedw()
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

endmodule
