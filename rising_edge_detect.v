module rising_edge_detect(
input CLOCK,
input RESET,
input LONG_SIGNAL,
output reg RISING_EDGE_PULSE
);

reg flag1;
always@(posedge CLOCK or negedge RESET)
begin
if(!RESET)
	begin
	RISING_EDGE_PULSE <= 0;
	flag1 <= 1;
	end
else
	begin
	flag1 <= LONG_SIGNAL;
	if((!flag1) & LONG_SIGNAL)
		RISING_EDGE_PULSE <= 1;
	else
		RISING_EDGE_PULSE <= 0;
	end
end

endmodule
