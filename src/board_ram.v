module board_ram(clock, resetn, side, detecten, writeen, x, y, q, dir,x_plot,y_plot,select,enable,en_plot,check_board);
	input clock, resetn;
	input detecten, writeen;
	input [2:0] x;
	input [2:0] y;
	input side;
	input en_plot;
	output [1:0] q;
	output [7:0] dir;
	
	output [7:0] x_plot;
	output [6:0] y_plot;
	output [1:0] select;
	output [15:0] check_board;
	output enable;
	
	wire detectcontrol;
	enableonce e1(
		.q(detectcontrol),
		.enable(detecten),
		.clock(clock),
		.resetn(resetn)
	);
	
	
	wire writecontrol;
	enableonce e2(
		.q(writecontrol),
		.enable(writeen),
		.clock(clock),
		.resetn(resetn)
	);
	
	wire en;
	reg [7:0] i;
//	reg [7:0] i0;
//	reg [7:0] i1;
//	reg [7:0] i2;
//	reg [7:0] i3;
//	reg [7:0] i4;
//	reg [7:0] i5;
//	reg [7:0] i6;
//	reg [7:0] i7;
	reg [7:0] dirreg;
	reg [1:0] boardreg [0:63];
	
	assign dir = dirreg;
	
	reg [7:0] detstart;
	reg [7:0] detend;
	reg [7:0] detnot;
	reg [7:0] wrifin;
	
	wire [7:0] pos;
	assign pos = (y << 3) + x;
	assign q = boardreg [pos];
	wire [1:0] opside;
	wire [1:0] twobitside;
	assign opside[1] = 1;
	assign opside[0] = ~side;
	assign twobitside[1] = 1;
	assign twobitside[0] = side;
	
	wire [2:0] minxy;
	assign minxy = (x < y) ? x : y;
	
	wire [1:0] test;
	assign test = boardreg [pos + 1];
	
	wire detectcounteren;
	wire writecounteren;
	reg writeenabled;
	reg [7:0] uppos;
	reg [7:0] downpos;
	reg [7:0] leftpos;
	reg [7:0] rightpos;
	reg [2:0] upamt;
	reg [2:0] downamt;
	reg [2:0] leftamt;
	reg [2:0] rightamt;
	
	wire [1:0] cb0 = boardreg[24];
	assign check_board[0] = cb0 [0];
	wire [1:0] cb1 = boardreg[25];
	assign check_board[1] = cb1 [0];
	wire [1:0] cb2 = boardreg[26];
	assign check_board[2] = cb2 [0];
	wire [1:0] cb3 = boardreg[27];
	assign check_board[3] = cb3 [0];
	wire [1:0] cb4 = boardreg[28];
	assign check_board[4] = cb4 [0];
	wire [1:0] cb5 = boardreg[29];
	assign check_board[5] = cb5 [0];
	wire [1:0] cb6 = boardreg[30];
	assign check_board[6] = cb6 [0];
	wire [1:0] cb7 = boardreg[31];
	assign check_board[7] = cb7 [0];
	wire [1:0] cb8 = boardreg[32];
	assign check_board[8] = cb8 [0];
	wire [1:0] cb9 = boardreg[33];
	assign check_board[9] = cb9 [0];
	wire [1:0] cb10 = boardreg[34];
	assign check_board[10] = cb10 [0];
	wire [1:0] cb11 = boardreg[35];
	assign check_board[11] = cb11 [0];
	wire [1:0] cb12 = boardreg[36];
	assign check_board[12] = cb12 [0];
	wire [1:0] cb13 = boardreg[37];
	assign check_board[13] = cb13 [0];
	wire [1:0] cb14 = boardreg[38];
	assign check_board[14] = cb14 [0];
	wire [1:0] cb15 = boardreg[39];
	assign check_board[15] = cb15 [0];
	
	always@(*) begin
	if (resetn) begin
		for(i = 0; i < 64; i=i+1)
			begin
				boardreg [i] <= 2'b0;
			end
			
			boardreg [27] <= 2'd2;
			boardreg [28] <= 2'd3;
			boardreg [35] <= 2'd3;
			boardreg [36] <= 2'd2;
			detstart = 8'd0;
			detend = 8'd0;
			detnot = 8'd0;
			wrifin = 8'd0;

	end
		dirreg[7:0] = detstart[7:0] & detend[7:0] & (~detnot[7:0]);
//		dirreg[7:0] = detend[7:0] & detend[7:0] & (~detnot[7:0])
		upamt[2:0] = (pos >> 3) + 1;
		downamt[2:0] = 8 - (pos >> 3);
		leftamt[2:0] = pos + 1 - ((pos >> 3) << 3);
		rightamt[2:0] = 8 + ((pos >> 3) << 3) - pos;
		
			if (detectcounteren) begin: detect
				uppos[7:0] = pos - (detcountout << 3);
				downpos[7:0] = pos + (detcountout << 3);
				leftpos[7:0] = pos - detcountout;
				rightpos[7:0] = pos + detcountout;
				if (detcountout == 0) begin
					// Original board should be empty
					if (boardreg [pos] != 0 && boardreg [pos] != 1)
						detnot = 8'b11111111;
				end 
				else if (detcountout == 1) begin
					// Check the disk beside it
					if (detcountout < upamt && boardreg [uppos] == opside)
						detstart[0] = 1;
					if (detcountout < downamt && boardreg [downpos] == opside)
						detstart[4] = 1;
					if (detcountout < leftamt && boardreg [leftpos] == opside)
						detstart[6] = 1;
					if (detcountout < rightamt && boardreg [rightpos] == opside)
						detstart[2] = 1;
				end 
				else begin
					// Find for same color disk
					if (detcountout < upamt && boardreg [uppos] == twobitside)
						detend[0] = 1;
					if (detcountout < downamt && boardreg [downpos] == twobitside)
						detend[4] = 1;
					if (detcountout < leftamt && boardreg [leftpos] == twobitside)
						detend[6] = 1;
					if (detcountout < rightamt && boardreg [rightpos] == twobitside)
						detend[2] = 1;
				end
				
			end
			
			else if (dirreg == 0 && ~detectcounteren) begin
				detstart = 8'd0;
				detend = 8'd0;
				detnot = 8'd0;
			end
			
						
			else if (writeenabled && ~writecounteren) begin
				detstart = 8'd0;
				detend = 8'd0;
				detnot = 8'd0;
				wrifin = 8'd0;
				writeenabled = 0;
			end
			
			if (writecounteren) begin
				wrifin[7:0] = ~dirreg;
				writeenabled = 1;
				uppos[7:0] = pos - (wricountout << 3);
				downpos[7:0] = pos + (wricountout << 3);
				leftpos[7:0] = pos - wricountout;
				rightpos[7:0] = pos + wricountout;
				if (wricountout == 0)
					boardreg [pos] = twobitside;
				else begin
					if (boardreg [uppos] == twobitside[1:0] || boardreg [uppos] < 2'b10)
						wrifin[0] = 1;
					if (boardreg [downpos] == twobitside[1:0] || boardreg [downpos] < 2'b10)
						wrifin[4] = 1;
					if (boardreg [leftpos] == twobitside[1:0] || boardreg [leftpos] < 2'b10)
						wrifin[6] = 1;
					if (boardreg [rightpos] == twobitside[1:0] || boardreg [rightpos] < 2'b10)
						wrifin[2] = 1;
					if (wrifin[0] == 0)
						boardreg [uppos] = twobitside[1:0];
					if (wrifin[4] == 0)
						boardreg [downpos] = twobitside[1:0];
					if (wrifin[6] == 0)
						boardreg [leftpos] = twobitside[1:0];
					if (wrifin[2] == 0)
						boardreg [rightpos] = twobitside[1:0];
				end
			end
	end
	
	wire [7:0] detcountoutt;
	wire [7:0] wricountoutt;
	wire [7:0] detcountout;
	wire [7:0] wricountout;
	assign detcountout = detcountoutt;
	assign wricountout = wricountoutt;
	counter #(7) c1(
		.clock(clock),
		.enable(detectcontrol),
		.resetn(resetn),
		.q(detcountoutt),
		.en(detectcounteren)
	);
	
	counter #(7) c2(
		.clock(clock),
		.enable(writecontrol),
		.resetn(resetn),
		.q(wricountoutt),
		.en(writecounteren)
	);
	

	
//	always@(posedge clock) begin
//		if (resetn) begin
//			for(i = 0; i < 64; i=i+1)
//			begin
//				boardreg [i] <= 2'b0;
//			end
//			
//			boardreg [27] <= 2'd2;
//			boardreg [28] <= 2'd3;
//			boardreg [35] <= 2'd3;
//			boardreg [36] <= 2'd2;
////			detstart <= 8'd0;
////			detend <= 8'd0;
////			detnot <= 8'd0;
////			wrifin <= 8'd0;
//		end
//	end
	
	
	wire clk;
	reg[7:0] x_plot;
	reg[6:0] y_plot;
	reg [1:0] select;	
	reg enable;
	reg [7:0] d; // Declare d
	
//	always @(posedge clock, posedge resetn) // Triggered every time clock rises
//			begin
//				if (resetn == 1'b1) // When reset n is 0
//					begin
//						d <= 'd64; // Set d to 0
//						enable <= 0;
//					end
//			end
//				else // Increment d only when enable is 1
//					begin
//					  if (en) // When d is the maximum value for the counter
//							d <= 'd64;
//					  else if(clk)
//							begin
//								select <= boardreg[d];
//								x_plot[7:0] <= 7'd13 * d + 7'd9;
//								y_plot[6:0] <= 6'd13 * d + 6'd9;
//								enable <= 1'b1;
//								d <= d - 1'b1 ; // Increment d
//							end
//					  else 
//							begin
//							enable <= 1'b0;
//							end
//					end
//			end
			
	always@(*) begin
		
	  if (resetn) // When d is the maximum value for the counter
		begin
			d = 'd64;
			enable = 0;
			x_plot[7:0] = 9;
			y_plot[6:0] = 9;
		end
//	  else if()
	
	  else if(clk)
			begin
				select = boardreg[d];
				y_plot[6:0] = y_plot[6:0] + 13;
				if (y_plot[6:0] > 100) begin
					y_plot[6:0] = 9;
					x_plot[7:0] = x_plot[7:0] + 13;
				end
				if (x_plot[7:0] > 100) begin
					x_plot[7:0] = 9;
				end
				enable = 1'b1;
				d = d - 1'b1 ; // Increment d
			end
	  else if (~clk)
			begin
				enable = 1'b0;
				if (d == 0) begin
					d = 64;
					x_plot[7:0] = 9;
					y_plot[6:0] = 9;
				end
				if (~en_plot) begin
					d = 'd64;
					enable = 0;
					x_plot[7:0] = 9;
					y_plot[6:0] = 9;
				end
			end
	end
	
	ratedivider r2(
				.enable(clk),
				.en(en_plot),
				.clock(clock),
				.reset_n(~resetn),
				.d('d19999)
				);

endmodule

