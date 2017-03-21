module SPI(
input CLK,
input RST,
input SCLK,
input MOSI,
input SS,
output reg MISO,

output reg [7:0] SPI_DATA,
output reg [6:0] SPI_ADDRESS,
input [7:0] DATA_IN,
output SPI_ENA
);
assign SPI_ENA = rising_ss & (!mode_read);

reg [3:0] counter;
reg mode_read;
always@(posedge SCLK or posedge SS)
begin
if(SS)
	begin
	counter <= 0;	// in case of bad receive when (number of SCLKs) < 16
	end
else
	begin
	counter <= counter + 1'b1;
	if(counter == 4'd0)
		begin
		mode_read <= MOSI;
		end
	else if(counter < 4'd8)
		begin
		SPI_ADDRESS[0] <= MOSI;
		SPI_ADDRESS[6:1] <= SPI_ADDRESS[5:0];
		end
	else
		begin
		MISO <= DATA_IN[4'd15-counter];
		SPI_DATA[0] <= MOSI;
		SPI_DATA[7:1] <= SPI_DATA[6:0];
		end
	end
end

rising_edge_detect spi_ena(
.CLOCK(CLK),
.RESET(RST),
.LONG_SIGNAL(SS),
.RISING_EDGE_PULSE(rising_ss)
);
wire rising_ss;

endmodule
