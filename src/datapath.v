module datapath(
   input 	    turn_side, move_up, move_down, move_left, move_right, plot_empty, plot_box, place_disk,
   input 	    resetn,
   input 	    clock,
   output [2:0]     x,
   output [2:0]     y,
   output reg [7:0] x_plot,
   output reg [6:0] y_plot,
   output reg [1:0] select
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

	always @(*) // Plot related regs
	begin
		if (resetn)
		begin
			x_plot[7:0] = 1'd0;
			y_plot[6:0] = 1'd0;
			select[1:0] = 2'd0;
		end
	
		if (plot_empty)
		begin
			select = 2'd0;
			x_plot[7:0] = old_x_plot[7:0];
			y_plot[6:0] = old_y_plot[6:0];
		end

		else if (plot_box)
		begin
			select = 2'd1;
			x_plot[7:0] = cur_x_plot[7:0];
			y_plot[6:0] = cur_y_plot[6:0];
		end

		else if (place_disk)
		begin
			select[1] = 1;
			select[0] = side;
			x_plot[7:0] = cur_x_plot[7:0];
			y_plot[6:0] = cur_y_plot[6:0];
		end		
	end
	
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
			
endmodule














