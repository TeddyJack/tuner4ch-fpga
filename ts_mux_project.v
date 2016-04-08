module ts_mux_project(
input BOARD_CLK,
input RESERVE_CLK,
input BTN_0,
//input BTN_1,
output [7:0] DATA_OUT,
output DCLK_OUT,
output D_VALID_OUT,
output P_SYNC_OUT
);

wire rst = BTN_0;

the_pll the_pll(
.inclk0(/*BOARD_CLK*/RESERVE_CLK),
.c0(clk_ts_0),
.c1(clk_ts_1),
.c2(clk_ts_2),
.c3(clk_ts_3)
);
wire clk_ts_0;
wire clk_ts_1;
wire clk_ts_2;
wire clk_ts_3;

ts_generator ts_gen_0(
.CLK(clk_ts_0),
.RST(rst),
.PID(13'h1000),

.DATA(data_0),
.D_CLK(d_clk_0),
.D_VALID(d_valid_0),
.P_SYNC(p_sync_0)
);
wire [7:0] data_0;
wire d_clk_0;
wire d_valid_0;
wire p_sync_0;

ts_generator ts_gen_1(
.CLK(clk_ts_1),
.RST(rst),
.PID(13'h1001),

.DATA(data_1),
.D_CLK(d_clk_1),
.D_VALID(d_valid_1),
.P_SYNC(p_sync_1)
);
wire [7:0] data_1;
wire d_clk_1;
wire d_valid_1;
wire p_sync_1;

ts_generator ts_gen_2(
.CLK(clk_ts_2),
.RST(rst),
.PID(13'h1002),

.DATA(data_2),
.D_CLK(d_clk_2),
.D_VALID(d_valid_2),
.P_SYNC(p_sync_2)
);
wire [7:0] data_2;
wire d_clk_2;
wire d_valid_2;
wire p_sync_2;

ts_generator ts_gen_3(
.CLK(clk_ts_3),
.RST(rst),
.PID(13'h1003),

.DATA(data_3),
.D_CLK(d_clk_3),
.D_VALID(d_valid_3),
.P_SYNC(p_sync_3)
);
wire [7:0] data_3;
wire d_clk_3;
wire d_valid_3;
wire p_sync_3;

ts_muxer ts_muxer(
.EXT_CLK_IN(BOARD_CLK),
.RST(rst),

.DATA_0(data_0),
.DCLK_0(d_clk_0),
.D_VALID_0(d_valid_0),
.P_SYNC_0(p_sync_0),

.DATA_1(data_1),
.DCLK_1(d_clk_1),
.D_VALID_1(d_valid_1),
.P_SYNC_1(p_sync_1),

.DATA_2(data_2),
.DCLK_2(d_clk_2),
.D_VALID_2(d_valid_2),
.P_SYNC_2(p_sync_2),

.DATA_3(data_3),
.DCLK_3(d_clk_3),
.D_VALID_3(d_valid_3),
.P_SYNC_3(p_sync_3),

.DATA_OUT(DATA_OUT),
.DCLK_OUT(DCLK_OUT),
.D_VALID_OUT(D_VALID_OUT),
.P_SYNC_OUT(P_SYNC_OUT)
);
// testing
//assign DATA_OUT = data_0;
//assign DCLK_OUT = d_clk_0;
//assign D_VALID_OUT = d_valid_0;
//assign P_SYNC_OUT = p_sync_0;


endmodule
