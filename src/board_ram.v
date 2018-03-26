module board_ram(clock, resetn, side, detecten, writeen, x, y, q, dir);
	input clock, resetn;
	input detecten, writeen;
	input [2:0] x;
	input [2:0] y;
	input [1:0] side;
	output [1:0] q [0:63];
	output [7:0] dir;
	
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
	
	always@(*) begin
		dirreg[7:0] = detstart[7:0] & detend[7:0];
	end
	
	always@(posedge clock) begin
		if (resetn) begin
			for(i = 0; i < 64; i=i+1)
				boardreg [i] <= 2'b0;
			boardreg [27] <= 2'd2;
			boardreg [28] <= 2'd3;
			boardreg [35] <= 2'd3;
			boardreg [36] <= 2'd2;
			dirreg <= 8'd0;
			detstart <= 8'd0;
			detend <= 8'd0;
		end else begin
			// Detect if placeable
			if (detectcontrol) begin: detect
				// Detect up
				if (pos > 7) begin: dup
					if (boardreg [pos - 8] == opside) begin
						detstart[0] <= 1;
						for (i0 = pos; i0 >= 0; i0=i0-8) begin: loop0
							if (boardreg [i0] == side) begin
								detend[0] <= 1;
								disable dup;
							end else if ((i0 != pos) && boardreg [i0] < 2'b10) begin
								disable dup;
							end
						end
					end
				end

				// Detect down
				if (pos < 56) begin: ddown
					if (boardreg [pos + 8] == opside) begin
						detstart[4] <= 1;
						for (i4 = pos; i4 < 64; i4=i4+8) begin: loop1
							if (boardreg [i4] == side) begin
								detend[4] <= 1;
								disable ddown;
							end else if ((i4 != pos) && boardreg [i4] < 2'b10) begin
								disable ddown;
							end
						end
					end
				end
				
				// Detect left
				if (pos > 8 * y) begin: dleft
					if (boardreg [pos - 1] == opside) begin
						detstart[6] <= 1;
						for (i6 = pos; i6 >= 8*y; i6=i6-1) begin: loop
							if (boardreg [i6] == side) begin
								detend[6] <= 1;
								disable dleft;
							end else if ((i6 != pos) && boardreg [i6] < 2'b10) begin
								disable dleft;
							end
						end
					end
				end
				
				// Detect right
				if (pos < 8 * y + 7) begin: dright
					if (boardreg [pos + 1] == opside) begin
						detstart[2] <= 1;
						for (i2 = pos; i2 <= 8*y+7; i2=i2+1) begin: loop
							if (boardreg [i2] == side) begin
								detend[2] <= 1;
								disable dright;
							end else if ((i2 != pos) && boardreg [i2] < 2'b10) begin
								disable dright;
							end
						end
					end
				end
				
			end
			
			// Reserve the disks
			else if (writecontrol) begin
				boardreg [pos] <= side;
				// Write up
				if (dirreg[0] == 1) begin: wup
					for (i0 = pos; i0 >= 0; i0=i0-8) begin
						if (boardreg [i0] == opside)
							boardreg [i0] <= side;
					end
				end
				
				// Write down
				if (dirreg[4] == 1) begin: wdown
					for (i4 = pos; i4 < 64; i4=i4+8) begin
						if (boardreg [i4] == opside)
							boardreg [i4] <= side;
					end
				end
				
				// Write left
				if (dirreg[6] == 1) begin: wleft
					for (i6 = pos; i6 >= 8*y; i6=i6-1) begin
						if (boardreg [i6] == opside)
							boardreg [i6] <= side;
					end
				end
				
				// Write right
				if (dirreg[2] == 1) begin: wright
					for (i2 = pos; i2 <= 8*y+7; i2=i2+1) begin
						if (boardreg [i2] == opside)
							boardreg [i2] <= side;
					end
				end
				
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
	end
	
endmodule
