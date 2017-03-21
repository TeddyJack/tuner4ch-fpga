`include "defines.v"

module reclock_and_prepare(
input SYS_CLK,
input RST,
input [7:0] DATA,
input DCLK,
input D_VALID,
input P_SYNC,
input RD_REQ,

output GOT_FULL_PACKET,
output [7:0] DATA_OUT,
output reg [31:0] BYTERATE
);

wire fifo_wr_req = (P_SYNC | (!sync_lost)) & D_VALID;		// for first-ever alignment
assign GOT_FULL_PACKET = (fifo_used >= 9'd188);

reg clear_fifo;
always@(posedge SYS_CLK or negedge RST)
begin
if(!RST)
	clear_fifo <= 0;
else
	clear_fifo <= sync_lost & (!P_SYNC) & (!RD_REQ);
end

input_fifo input_fifo(
.aclr((!RST) | clear_fifo),
.data(DATA),
.rdclk(SYS_CLK),
.rdreq(RD_REQ),
.wrclk(DCLK),
.wrreq(fifo_wr_req),
.q(DATA_OUT),
.rdusedw(fifo_used)
);
wire [8:0] fifo_used;

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

reg [31:0] counter;
always@(posedge SYS_CLK or negedge RST)
begin
if(!RST)
	begin
	BYTERATE <= 0;
	counter <= 0;
	end
else
	begin
	if(counter < (`ONE_SECOND_LIMIT-1'b1))
		counter <= counter + 1'b1;
	else
		begin
		counter <= 0;
		BYTERATE <= bytes_per_sec;
		end
	end
end

reg [31:0] bytes_per_sec;
wire reset_counting = (!RST) | (counter == 0) | (sync_lost);
always@(posedge DCLK or posedge reset_counting)
begin
if(reset_counting)
	begin
	bytes_per_sec <= 0;
	end
else if(fifo_wr_req)
	bytes_per_sec <= bytes_per_sec + 1'b1;
end

endmodule
