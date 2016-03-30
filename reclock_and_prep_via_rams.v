module reclock_and_prep_via_rams(
input SYS_CLK,
input RST,
input [7:0] DATA,
input DCLK,
input D_VALID,
input P_SYNC,
input GIVE_ME_ONE_PACKET,

output reg GOT_FULL_PACKET,
output reg [7:0] DATA_OUT
);

reg [7:0] ram_0 [187:0];
reg [7:0] ram_1 [187:0];

reg state;
parameter wait_psync		= 1'b0;
parameter write_packet	= 1'b1;

reg [1:0] ram_content_status [1:0];				// статус содержимого ram-ки
parameter [1:0] corrupted		= 2'h0;
parameter [1:0] unconfirmed	= 2'h1;
parameter [1:0] valid			= 2'h2;

reg current_wr_ram;

reg [7:0] write_counter;
always@(posedge DCLK or negedge RST)			// блок записи
begin
if(!RST)
	begin
	current_wr_ram <= 0;
	state <= wait_psync;
	write_counter <= 0;
	ram_content_status[0] <= corrupted;
	ram_content_status[1] <= corrupted;
	end
else if(D_VALID)					// возможно это надо не настолько главным условием сделать. надо проверить на реальном сигнале
	case(state)
	wait_psync:
		begin
		if(P_SYNC)
			begin
			state <= write_packet;
			write_counter <= 1;
			//ram_content_status[current_wr_ram] <= corrupted;		// (*) делаем текущую ram-ку недоступной для чтения, чтобы подготовить к записи. здесь на такт позже, чем в (**)
			if(current_wr_ram == 0)
				ram_0[0] <= DATA;
			else
				ram_1[0] <= DATA;
			if(ram_content_status[!current_wr_ram] == unconfirmed)
				ram_content_status[!current_wr_ram] <= valid;
			end
		else
			begin
			ram_content_status[!current_wr_ram] <= corrupted;
			end
		end
	write_packet:
		begin
		if(P_SYNC)
			begin
			write_counter <= 1;
			if(current_wr_ram == 0)
				ram_0[0] <= DATA;
			else
				ram_1[0] <= DATA;
			end
		else
			begin
			if(write_counter < 187)
				write_counter <= write_counter + 1'b1;
			else
				begin
				write_counter <= 0;
				state <= wait_psync;
				ram_content_status[current_wr_ram] <= unconfirmed;
				current_wr_ram <= !current_wr_ram;
				ram_content_status[!current_wr_ram] <= corrupted;		// (**) делаем следующую ram-ку недоступной для чтения, чтобы подготовить к записи. здесь на такт раньше, чем в (*) для доп. безопасности
				end
			if(current_wr_ram == 0)
				ram_0[write_counter] <= DATA;
			else
				ram_1[write_counter] <= DATA;
			end
		end
	endcase
end

reg read_state;
parameter wait_rd_req	= 1'b0;
parameter read				= 1'b1;
reg [7:0] read_counter;
reg scanned_ram;
always@(posedge SYS_CLK or negedge RST)			// блок чтения
begin
if(!RST)
	begin
	read_state <= wait_rd_req;
	GOT_FULL_PACKET <= 0;
	read_counter <= 0;
	DATA_OUT <= 0;
	scanned_ram <= 1;
	end
else
	case(read_state)
	wait_rd_req:
		begin
		DATA_OUT <= 0;		// когда читать нечего, посылаем 0
		if((current_wr_ram == scanned_ram) && ((ram_content_status[0] == valid) || (ram_content_status[1] == valid)))		// чтобы прочитать ram-ку единожды в течение записи другой ram-ки
			begin
			GOT_FULL_PACKET <= 1;
			scanned_ram <= !current_wr_ram;
			end
		if(GIVE_ME_ONE_PACKET)
			begin
			GOT_FULL_PACKET <= 0;
			read_state <= read;
			read_counter <= 0;
			end
		end
	read:
		begin
		if(current_wr_ram == 0)
			DATA_OUT <= ram_1[read_counter];
		else
			DATA_OUT <= ram_0[read_counter];
		//////////
		if(read_counter < 187)
			read_counter <= read_counter + 1'b1;
		else
			begin
			read_state <= wait_rd_req;
			read_counter <= 0;
			scanned_ram <= !current_wr_ram;
			end
		end
	endcase
end

endmodule
