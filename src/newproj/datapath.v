module datapath(
	input 	    turn_side, move_up, move_down, move_left, move_right, plot_empty, plot_box, place_disk,
	input 	    resetn,
	input 	    clock,
	output [2:0]     x,
	output [2:0]     y,
	output reg [7:0] x_plot,
	output reg [6:0] y_plot,
	output reg [1:0] select,
	output outside,
	output winsignal
    );
	
    reg [7:0] curr_x_pos;
    reg [7:0] curr_y_pos;
    reg [7:0] old_x_pos;
    reg [7:0] old_y_pos;
    reg side;
	reg [7:0] cur_x_plot;
	reg [6:0] cur_y_plot;
	reg [7:0] old_x_plot;
	reg [6:0] old_y_plot;
	
    wire move;
    assign x = curr_x_pos[2:0];
    assign y = curr_y_pos[2:0];
   
    assign move = move_up || move_down || move_left || move_right;
	assign plot = plot_box || plot_empty || place_disk;
	assign outside = side;
	
	wire [7:0] pos;
	assign pos = x + (y * 8);
	reg [1:0] boardreg [0:63];
	wire [1:0] curr_reg;
	assign curr_reg = boardreg [pos];
	wire [1:0] twobitside;
	assign twobitside[1] = 1;
	assign twobitside[0] = side;


	//Enable once module for move
	wire movecontrol;
	enableonce e1(
		.q(movecontrol),
		.enable(move),
		.clock(clock),
		.resetn(resetn)
	);
	
	//Enable once module for side
	wire sidecontrol;
	enableonce e2(
		.q(sidecontrol),
		.enable(turn_side),
		.clock(clock),
		.resetn(resetn)
	);
	
	reg old_stored;
	
    always @ (posedge clock, posedge resetn) begin
        if (resetn) begin
            curr_x_pos <= 8'd0;
            curr_y_pos <= 8'd0;
            old_x_pos <= 8'd0;
            old_y_pos <= 8'd0;
			cur_x_plot[7:0] <= 8'd9;
			cur_y_plot[6:0] <= 7'd9;
			old_x_plot[7:0] <= 8'd9;
			old_y_plot[6:0] <= 7'd9;
            side <= 1'd0;
			old_stored <= 1'd0;
        end else begin
			if (movecontrol) begin
				if (~old_stored) begin
					old_x_pos[7:0] <= curr_x_pos[7:0];
					old_y_pos[7:0] <= curr_y_pos[7:0];
					old_x_plot[7:0] <= cur_x_plot[7:0];
					old_y_plot[6:0] <= cur_y_plot[6:0];
					old_stored <= 1;
				end
				
				if (move_up) begin
					 curr_y_pos[7:0] <= curr_y_pos[7:0] - 1;
					 cur_y_plot[6:0] <= cur_y_plot[6:0] - 7'd13;
				end else if (move_down) begin
					 curr_y_pos[7:0] <= curr_y_pos[7:0] + 1;
					 cur_y_plot[6:0] <= cur_y_plot[6:0] + 7'd13;
				end else if (move_left) begin
					 curr_x_pos[7:0] <= curr_x_pos[7:0] - 1;
					 cur_x_plot[7:0] <= cur_x_plot[7:0] - 7'd13;
				end else if (move_right) begin
					 curr_x_pos[7:0] <= curr_x_pos[7:0] + 1;
					 cur_x_plot[7:0] <= cur_x_plot[7:0] + 7'd13;
				end
			end
        
			if (sidecontrol) begin
				side <= ~side;
			end
			
			if (~movecontrol && old_stored) begin
				old_stored <= 1'd0;
			end
		end
	end
	
	reg [7:0] detstop;
	reg [2:0] horizoncount;
	reg [2:0] verticalcount;
	reg [2:0] backcount;
	reg [2:0] forwardcount;
	reg [7:0] uppos;
	reg [7:0] downpos;
	reg [7:0] leftpos;
	reg [7:0] rightpos;
	reg [7:0] ulpos;
	reg [7:0] urpos;
	reg [7:0] dlpos;
	reg [7:0] drpos;
	reg [7:0] i;
	wire detectcounteren;

	wire detectcontrol;
	enableonce e5(
		.q(detectcontrol),
		.enable(detecten),
		.clock(clock),
		.resetn(resetn)
	);
	
	always@(posedge clock) begin
		if (resetn) begin
			x_plot[7:0] <= 1'd0;
			y_plot[6:0] <= 1'd0;
			select[1:0] <= 2'd0;
			for(i = 0; i <= 63; i=i+1)
				begin
					boardreg [i] <= 2'b0;
				end
				
			detstop <= 8'd0;
		end else begin
			if (plot_empty)
			begin
				select <= 2'd0;
				x_plot[7:0] <= old_x_plot[7:0];
				y_plot[6:0] <= old_y_plot[6:0];
			end

			else if (plot_box)
			begin
				select <= 2'd1;
				x_plot[7:0] <= cur_x_plot[7:0];
				y_plot[6:0] <= cur_y_plot[6:0];
			end

			else if (place_disk)
			begin
				if (boardreg [pos] < 2) begin
					boardreg [pos] <= twobitside;
					select[1] <= 1;
					select[0] <= side;
				end else begin
					select <= boardreg[pos];
				end
				x_plot[7:0] <= cur_x_plot[7:0];
				y_plot[6:0] <= cur_y_plot[6:0];
			end		
			
			if (detectcounteren) begin: detect
				uppos[7:0] <= pos - (detcountout * 8);
				downpos[7:0] <= pos + (detcountout * 8);
				leftpos[7:0] <= pos - detcountout;
				rightpos[7:0] <= pos + detcountout;
				ulpos[7:0] <= uppos - 1;
				urpos[7:0] <= uppos + 1;
				dlpos[7:0] <= downpos - 1;
				drpos[7:0] <= dlpos + 1;
				if (detcountout == 0) begin
					// Original board should be empty
					if (boardreg [pos] == twobitside) begin
						detstop <= 8'd0;
						horizoncount <= 1;
						verticalcount <= 1;
						backcount <= 1;
						forwardcount <= 1;
					end
				end 
				else begin
					// Find for same color disk
					if (uppos >= 0 && uppos < 64) begin
						if (boardreg [uppos] == twobitside && detstop[0] == 0)
							verticalcount <= verticalcount + 1;
						else
							detstop[0] <= 1;
					end else begin
						detstop[0] <= 1;
					end
					
					if (urpos >= 0 && urpos < 64) begin
						if (boardreg [urpos] == twobitside && detstop[1] == 0)
							forwardcount <= forwardcount + 1;
						else
							detstop[1] <= 1;
					end else begin
						detstop[1] <= 1;
					end

					if (rightpos >= 0 && rightpos < 64) begin
						if (boardreg [rightpos] == twobitside && detstop[2] == 0)
							horizoncount <= horizoncount + 1;
						else
							detstop[2] <= 1;
					end else begin
						detstop[2] <= 1;
					end
					
					if (drpos >= 0 && drpos < 64) begin
						if (boardreg [drpos] == twobitside && detstop[3] == 0)
							backcount <= backcount + 1;
						else
							detstop[3] <= 1;
					end else begin
						detstop[3] <= 1;
					end
					
					if (downpos >= 0 && downpos < 64) begin
						if (boardreg [downpos] == twobitside && detstop[4] == 0)
							verticalcount <= verticalcount + 1;
						else
							detstop[4] <= 1;
					end else begin
						detstop[4] <= 1;
					end
					
					if (dlpos >= 0 && dlpos < 64) begin
						if (boardreg [dlpos] == twobitside && detstop[5] == 0)
							forwardcount <= forwardcount + 1;
						else
							detstop[5] <= 1;
					end else begin
						detstop[5] <= 1;
					end
					
					if (leftpos >= 0 && leftpos < 64) begin
						if (boardreg [leftpos] == twobitside && detstop[6] == 0)
							horizoncount <= horizoncount + 1;
						else
							detstop[6] <= 1;
					end else begin
						detstop[6] <= 1;
					end
					
					if (ulpos >= 0 && ulpos < 64) begin
						if (boardreg [ulpos] == twobitside && detstop[7] == 0)
							backcount <= backcount + 1;
						else
							detstop[7] <= 1;
					end else begin
						detstop[7] <= 1;
					end

				end
			end
		end
	end
	
	wire win;
	assign win = (horizoncount > 4 || verticalcount > 4 || backcount > 4 || forwardcount > 4);
	assign winsignal = win;
	
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
			
endmodule














