//`include "defines.v"

module SPI(
input clk,
input rst,
input sclk,
input mosi,
input ss,
input [7:0] data_to_pc,
input [7:0] address_to_pc,

output miso,
output [7:0] data,
output [7:0] address,
output rising_ss,
output falling_ss,
output send_to_pc_request,
//
input [1:0] acknowledge
);
assign miso = shift_reg_out[15];
assign data		= shift_reg_in[15:8];
assign address	= shift_reg_in[7:0];

reg sync_sclk;
reg sync_ss;
reg sync_mosi;
reg load_flag;
always@(posedge clk or negedge rst)
begin
if(!rst)
	begin
	sync_ss <= 1;
	sync_sclk <= 0;
	sync_mosi <= 0;
	load_flag <= 0;
	end
else
	begin
	sync_ss <= ss;
	sync_sclk <= sclk;
	sync_mosi <= mosi;
	load_flag <= falling_ss;
	end
end

reg [15:0] shift_reg_out;
always@(posedge clk or negedge rst)
begin
if(!rst)
	begin
	shift_reg_out	<= 0;
	end
else if(!sync_ss)
	begin
	if(load_flag)
		begin
		shift_reg_out[15:8] <= data_to_pc;
		shift_reg_out[7:0] <= address_to_pc;
		end
	else if(short_sclk)
		begin
		shift_reg_out[15:1] <= shift_reg_out[14:0];
		end
	end
end

reg [15:0] shift_reg_in;
always@(posedge clk or negedge rst)
begin
if(!rst)
	begin
	shift_reg_in <= 0;
	end
else if(!sync_ss & short_sclk)
	begin
	shift_reg_in[0]		<= sync_mosi;
	shift_reg_in[15:1]	<= shift_reg_in[14:0];
	end
end

rise_fall_pulse_maker rfss(
.CLOCK(clk),
.RESET(rst),
.LONG_SIGNAL(sync_ss),
.FALLING_EDGE_PULSE(falling_ss),
.RISING_EDGE_PULSE(rising_ss)
);

rise_fall_pulse_maker rising_sclk(
.CLOCK(clk),
.RESET(rst),
.LONG_SIGNAL(sync_sclk),
.RISING_EDGE_PULSE(short_sclk)
);
wire short_sclk;

//assign send_to_pc_request = ((rising_ss) && (address == `READ_REQ_ADDR));		// this define is absent

endmodule
