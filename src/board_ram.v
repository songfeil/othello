module board_ram(clock, resetn, side, detecten, writeen, x, y, q, dir,x_plot,y_plot,select,enable);
	input clock, resetn;
	input detecten, writeen;
	input [2:0] x;
	input [2:0] y;
	input [1:0] side;
	output [1:0] q;
	output [7:0] dir;
	
	output [7:0] x_plot;
	output [6:0] y_plot;
	output [1:0] select;
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
	reg [7:0] i0;
	reg [7:0] i1;
	reg [7:0] i2;
	reg [7:0] i3;
	reg [7:0] i4;
	reg [7:0] i5;
	reg [7:0] i6;
	reg [7:0] i7;
	reg [7:0] dirreg;
	reg [1:0] boardreg [0:63];
	
	assign dir = dirreg;
	
	reg [7:0] detstart;
	reg [7:0] detend;
	reg [7:0] detnot;
	reg [7:0] wrifin;
	
	wire [7:0] pos;
	assign pos = 8 * y + x;
	assign q = boardreg [pos];
	wire [1:0] opside;
	assign opside[1] = 1;
	assign opside[0] = ~side[0];
	
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
	
	always@(*) begin
		dirreg[7:0] = detstart[7:0] & detend[7:0] & (~detnot[7:0]);
		upamt = pos / 8;
		downamt = 7 - pos / 8;
		leftamt = pos - (pos / 8) * 8;
		rightamt = 7 + (pos / 8) * 8 - pos;
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
	

	
	always@(posedge clock) begin
		if (resetn) begin
			for(i = 0; i < 64; i=i+1)
			boardreg [i] <= 2'b0;
			boardreg [27] <= 2'd2;
			boardreg [28] <= 2'd3;
			boardreg [35] <= 2'd3;
			boardreg [36] <= 2'd2;
			detstart <= 8'd0;
			detend <= 8'd0;
			detnot <= 8'd0;
			wrifin <= 8'd0;
		end else begin
			// Detect if placeable
			if (detectcounteren) begin: detect
				uppos <= pos - 8 * detcountout;
				downpos <= pos + 8 * detcountout;
				leftpos <= pos - 1 * detcountout;
				rightpos <= pos + 1 * detcountout;
				if (detcountout == 1) begin
					// Original board should be empty
					if (boardreg [pos] != 0 && boardreg [pos] != 1)
						detnot <= 8'b11111111;
				end else if (detcountout == 2) begin
					// Check the disk beside it
					if (detcountout <= upamt && boardreg [uppos] == opside)
						detstart[0] <= 1;
					if (detcountout <= downamt && boardreg [downpos] == opside)
						detstart[4] <= 1;
					if (detcountout <= leftamt && boardreg [leftpos] == opside)
						detstart[6] <= 1;
					if (detcountout <= rightamt && boardreg [rightpos] == opside)
						detstart[2] <= 1;
				end else begin
					// Find for same color disk
					if (boardreg [uppos] == side && detcountout <= upamt)
						detend[0] <= 1;
					if (boardreg [downpos] == side && detcountout <= downamt)
						detend[4] <= 1;
					if (boardreg [leftpos] == side && detcountout <= leftamt)
						detend[6] <= 1;
					if (boardreg [rightpos] == side && detcountout <= rightamt)
						detend[2] <= 1;
				end
				
				wrifin <= ~dirreg;
				
				// // Detect up
				// if (pos > 7) begin: dup
					// if (boardreg [pos - 8] == opside) begin
						// detstart[0] <= 1;
						// for (i0 = pos; i0 >= 0; i0=i0-8) begin: loop0
							// if (boardreg [i0] == side) begin
								// detend[0] <= 1;
								// disable dup;
							// end else if ((i0 != pos) && boardreg [i0] < 2'b10) begin
								// disable dup;
							// end
						// end
					// end
				// end

				// // Detect down
				// if (pos < 56) begin: ddown
					// if (boardreg [pos + 8] == opside) begin
						// detstart[4] <= 1;
						// for (i4 = pos; i4 < 64; i4=i4+8) begin: loop1
							// if (boardreg [i4] == side) begin
								// detend[4] <= 1;
								// disable ddown;
							// end else if ((i4 != pos) && boardreg [i4] < 2'b10) begin
								// disable ddown;
							// end
						// end
					// end
				// end
				
				// // Detect left
				// if (pos > 8 * y) begin: dleft
					// if (boardreg [pos - 1] == opside) begin
						// detstart[6] <= 1;
						// for (i6 = pos; i6 >= 8*y; i6=i6-1) begin: loop
							// if (boardreg [i6] == side) begin
								// detend[6] <= 1;
								// disable dleft;
							// end else if ((i6 != pos) && boardreg [i6] < 2'b10) begin
								// disable dleft;
							// end
						// end
					// end
				// end
				
				// // Detect right
				// if (pos < 8 * y + 7) begin: dright
					// if (boardreg [pos + 1] == opside) begin
						// detstart[2] <= 1;
						// for (i2 = pos; i2 <= 8*y+7; i2=i2+1) begin: loop
							// if (boardreg [i2] == side) begin
								// detend[2] <= 1;
								// disable dright;
							// end else if ((i2 != pos) && boardreg [i2] < 2'b10) begin
								// disable dright;
							// end
						// end
					// end
				// end // block: dright

			        // if (boardreg [pos] == 2'b00) begin
				   // detstart[7:0] <= 8'b0;
				// end
			end
			
			else if (dirreg == 0 && ~detectcounteren) begin
				detstart <= 8'd0;
				detend <= 8'd0;
				detnot <= 8'd0;
			end
			
						
			else if (writeenabled && ~writecounteren) begin
				detstart <= 8'd0;
				detend <= 8'd0;
				detnot <= 8'd0;
				wrifin <= 8'd0;
				writeenabled <= 0;
			end
			
			// Reserve the disks
			else if (writecounteren) begin
				writeenabled <= 1;
				uppos <= pos - 8 * wricountout;
				downpos <= pos + 8 * wricountout;
				leftpos <= pos - 1 * wricountout;
				rightpos <= pos + 1 * wricountout;
				if (wricountout == 1)
					boardreg [pos] <= side;
				else begin
					if (boardreg [uppos] == side || boardreg [uppos] < 2'b10)
						wrifin[0] <= 1;
					if (boardreg [downpos] == side || boardreg [downpos] < 2'b10)
						wrifin[4] <= 1;
					if (boardreg [leftpos] == side || boardreg [leftpos] < 2'b10)
						wrifin[6] <= 1;
					if (boardreg [rightpos] == side || boardreg [rightpos] < 2'b10)
						wrifin[2] <= 1;
					if (wrifin[0] == 0)
						boardreg [uppos] <= side;
					if (wrifin[4] == 0)
						boardreg [downpos] <= side;
					if (wrifin[6] == 0)
						boardreg [leftpos] <= side;
					if (wrifin[2] == 0)
						boardreg [rightpos] <= side;
				end
			end

			
			
				// boardreg [pos] <= side;
				// // Write up
				// if (dirreg[0] == 1) begin: wup
					// for (i0 = pos; i0 >= 0; i0=i0-8) begin
						// if (boardreg [i0] == opside)
							// boardreg [i0] <= side;
					// end
				// end
				
				// // Write down
				// if (dirreg[4] == 1) begin: wdown
					// for (i4 = pos; i4 < 64; i4=i4+8) begin
						// if (boardreg [i4] == opside)
							// boardreg [i4] <= side;
					// end
				// end
				
				// // Write left
				// if (dirreg[6] == 1) begin: wleft
					// for (i6 = pos; i6 >= 8*y; i6=i6-1) begin
						// if (boardreg [i6] == opside)
							// boardreg [i6] <= side;
					// end
				// end
				
				// // Write right
				// if (dirreg[2] == 1) begin: wright
					// for (i2 = pos; i2 <= 8*y+7; i2=i2+1) begin
						// if (boardreg [i2] == opside)
							// boardreg [i2] <= side;
					// end
				// end
				
//				// Write upright
//				if (dirreg[1] == 1) begin: wupr
//					for (i1 = pos; i1 >= 0; i1=i1-8) begin
//						if (boardreg [i1] == opside)
//							boardreg [i1] <= side;
//					end
//				end
//				
//				// Write downright
//				if (dirreg[3] == 1) begin: wdownr
//					for (i3 = pos; i3 < 64; i3=i3+8) begin
//						if (boardreg [i3] == opside)
//							boardreg [i3] <= side;
//					end
//				end
//				
//				// Write downleft
//				if (dirreg[5] == 1) begin: wdownl
//					for (i6 = pos; i6 >= 8*y; i6=i6-1) begin
//						if (boardreg [i5] == opside)
//							boardreg [i5] <= side;
//					end
//				end
//				
//				// Write upleft
//				if (dirreg[7] == 1) begin: wupl
//					for (i7 = pos; i7 <= 8*y+7; i2=i2+1) begin
//						if (boardreg [i7] == opside)
//							boardreg [i7] <= side;
//					end
//				end
				
			
		end
	end
	
	
	wire clk;
	reg[7:0] x_pos;
	reg[6:0] y_pos;
	reg [1:0] select;	
	reg enable;
	reg [7:0] d; // Declare d
	
	always @(posedge clk, negedge clk, negedge resetn) // Triggered every time clock rises
			begin
				if (resetn == 1'b0) // When reset n is 0
					begin
						d <= 'd64; // Set d to 0
						enable <= 0;
					end
				else // Increment d only when enable is 1
					begin
					  if (en) // When d is the maximum value for the counter
							d <= 'd64;
					  else
							begin
								select <= boardreg[d];
								x_pos[7:0] <= 7'd13 * d + 7'd9;
								y_pos[6:0] <= 6'd13 * d + 6'd9;
								enable <= 1'b1;
								d <= d - 1'b1 ; // Increment d
							end
					end
			end
	
	ratedivider r2(
				.enable(clk),
				.en(1),
				.clock(clock),
				.reset_n(~resetn),
				.d('d1999999)
				);

endmodule

