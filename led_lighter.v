// this module designed to capture short signal losses and kill the output LED for a specified time
// add following text to defines.v
// `define COUNTER_LIMIT		32'd5400000		// N_MSECS*N_MHZ*1000. e.g.: 100*54*1000 = 5400000



`include "defines.v"

module led_lighter(
input CLK,
input RST,
input SIGNAL_IN,

output reg LED
);

reg state;
parameter wait_for_signal	= 1'b0;
parameter keep_high			= 1'b1;

reg [31:0] counter;

always@(posedge CLK or negedge RST)
begin
if(!RST)
	begin
	state	<= wait_for_signal;
	counter	<= 1'b0;
	LED		<= 1'b0;
	end
else
	case(state)
	wait_for_signal:
		begin
		LED <= SIGNAL_IN;
		if(SIGNAL_IN)
			state <= keep_high;
		end
	keep_high:
		begin
		if(counter < (`COUNTER_LIMIT-1'b1))
			counter <= counter + 1'b1;
		else
			begin
			counter	<= 1'b0;
			state		<= wait_for_signal;
			end
		end
	endcase
end

endmodule
