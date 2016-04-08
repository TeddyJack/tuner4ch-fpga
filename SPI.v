//`include "defines.v"

module SPI(
input CLK,
input RST,
input SCLK,
input MOSI,
input SS,
input [7:0] data_to_pc,
input [7:0] address_to_pc,

output MISO,
output [7:0] SPI_DATA,
output [7:0] SPI_ADDRESS,
output RISING_SS,
//output falling_ss,
//output send_to_pc_request,
//
input [1:0] acknowledge
);
assign MISO = shift_reg_out[15];
assign SPI_DATA		= shift_reg_in[15:8];
assign SPI_ADDRESS	= shift_reg_in[7:0];

reg sync_sclk;
reg sync_ss;
reg sync_mosi;
reg load_flag;
always@(posedge CLK or negedge RST)
begin
if(!RST)
	begin
	sync_ss <= 1;
	sync_sclk <= 0;
	sync_mosi <= 0;
	load_flag <= 0;
	end
else
	begin
	sync_ss <= SS;
	sync_sclk <= SCLK;
	sync_mosi <= MOSI;
	load_flag <= /*falling_ss*/0;
	end
end

reg [15:0] shift_reg_out;
always@(posedge CLK or negedge RST)
begin
if(!RST)
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
always@(posedge CLK or negedge RST)
begin
if(!RST)
	begin
	shift_reg_in <= 0;
	end
else if(!sync_ss & short_sclk)
	begin
	shift_reg_in[0]		<= sync_mosi;
	shift_reg_in[15:1]	<= shift_reg_in[14:0];
	end
end

rising_edge_detect rising_edge_detect_0(
.CLOCK(CLK),
.RESET(RST),
.LONG_SIGNAL(sync_ss),
.RISING_EDGE_PULSE(RISING_SS)
);

rising_edge_detect rising_edge_detect_1(
.CLOCK(CLK),
.RESET(RST),
.LONG_SIGNAL(sync_sclk),
.RISING_EDGE_PULSE(short_sclk)
);
wire short_sclk;

//assign send_to_pc_request = ((RISING_SS) && (SPI_ADDRESS == `READ_REQ_ADDR));		// this define is absent

endmodule
