module reclock_and_prepare(
input SYS_CLK,
input RST,
input [7:0] DATA,
input DCLK,
input D_VALID,
input P_SYNC,
input GIVE_ME_ONE_PACKET,

output GOT_FULL_PACKET,
output [7:0] DATA_OUT
);

wire fifo_wr_req = (P_SYNC | (!sync_lost)) & D_VALID;		// for first-ever alignment
assign GOT_FULL_PACKET = (fifo_used >= 9'd188);
input_fifo input_fifo(
.aclr(!RST | short_sync_lost),
.data(DATA),
.rdclk(SYS_CLK),
.rdreq(fifo_rd_req),
.wrclk(DCLK),
.wrreq(fifo_wr_req),
.q(DATA_OUT),
.rdusedw(fifo_used)
);
wire [8:0] fifo_used;

reg state;
parameter idle				= 1'b0;
parameter read_packet	= 1'b1;
reg [7:0] read_counter;
reg fifo_rd_req;
always@(posedge SYS_CLK or negedge RST)
begin
if(!RST)
	begin
	state <= idle;
	read_counter <= 0;
	fifo_rd_req <= 0;
	end
else
	case(state)
	idle:
		if(GIVE_ME_ONE_PACKET)
			begin
			state <= read_packet;
			fifo_rd_req <= 1;
			read_counter <= read_counter + 1'b1;
			end
	read_packet:
		begin
		if(read_counter < 8'd188)
			read_counter <= read_counter + 1'b1;
		else
			begin
			read_counter <= 0;
			fifo_rd_req <= 0;
			state <= idle;
			end
		end
	endcase
end

rising_edge_detect rising_edge_detect(
.CLOCK(SYS_CLK),
.RESET(RST),
.LONG_SIGNAL(sync_lost),
.RISING_EDGE_PULSE(short_sync_lost)
);
wire short_sync_lost;


reg [7:0] psync_byte_counter;
reg sync_lost;
reg state_of_sync;
parameter wait_for_psync	= 1'b0;
parameter count				= 1'b1;
always@(posedge DCLK or negedge RST)
begin
if(!RST)
	begin
	sync_lost <= 1;
	state_of_sync <= wait_for_psync;
	psync_byte_counter <= 0;
	end
else
	case(state_of_sync)
	wait_for_psync:
		begin
		if(P_SYNC)
			begin
			state_of_sync <= count;
			sync_lost <= 0;
			psync_byte_counter <= 1;
			end
		else
			sync_lost <= 1;
		end
	count:
		begin
		if(P_SYNC)
			begin
			state_of_sync <= wait_for_psync;
			sync_lost <= 1;
			end
		else
			begin
			psync_byte_counter <= psync_byte_counter + 1'b1;
			if(psync_byte_counter == 8'd187)
				state_of_sync <= wait_for_psync;
			end
		end
	endcase
end

endmodule
