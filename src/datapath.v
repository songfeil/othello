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
	
    reg [2:0] curr_x_pos;
    reg [2:0] curr_y_pos;
    reg [2:0] old_x_pos;
    reg [2:0] old_y_pos;
    reg side;

    wire board_ram_out;
    wire board_ram_wren;
    wire [1:0] board_ram_data_in;
    wire [5:0] board_ram_address;
    wire move;
   assign x = curr_x_pos;
   assign y = curr_y_pos;
   
    assign move = move_up || move_down || move_left || move_right;
	assign plot = plot_box || plot_empty || place_disk;

//    board_ram br0 (
//	.address(board_ram_address[5:0]),
//	.clock(clock),
//	.data(board_ram_data_in[1:0]),
//	.wren(board_ram_wren),
//	.q(board_ram_out));

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
			x_plot[7:0] <= 1'd0;
			y_plot[7:0] <= 1'd0;
            select[1:0] <= 2'd0;
		end
	
		if (plot_empty)
		begin
			x_plot[7:0] <= 7'd13 * old_x_pos[2:0] + 7'd9;
			y_plot[6:0] <= 6'd13 * old_y_pos[2:0] + 6'd9;
			select <= 2'd0;
		end

		else if (plot_box)
		begin
			x_plot[7:0] <= 7'd13 * curr_x_pos[2:0] + 7'd9;
			y_plot[6:0] <= 6'd13 * curr_y_pos[2:0] + 6'd9;
			select <= 2'd1;
		end

		else if (place_disk)
		begin
			x_plot[7:0] <= 7'd13 * curr_x_pos[2:0] + 7'd9;
			y_plot[6:0] <= 6'd13 * curr_y_pos[2:0] + 6'd9;
			select <= (side) ? 2'd2 : 2'd3;
		end		
	end
	
	
    always @ (posedge clock, posedge resetn) begin
        if (resetn) begin
            curr_x_pos <= 3'd0;
            curr_y_pos <= 3'd0;
            old_x_pos <= 3'd0;
            old_y_pos <= 3'd0;
            side <= 1'd0;
        end else begin
			if (movecontrol) begin
				old_x_pos[2:0] <= curr_x_pos[2:0];
				old_y_pos[2:0] <= curr_y_pos[2:0];
				if (move_up)
					 curr_y_pos[2:0] <= curr_y_pos[2:0] - 1;
				else if (move_down) 
					 curr_y_pos[2:0] <= curr_y_pos[2:0] + 1;
				else if (move_left) 
					 curr_x_pos[2:0] <= curr_x_pos[2:0] - 1;
				else if (move_right) 
					 curr_x_pos[2:0] <= curr_x_pos[2:0] + 1;
			end
        
			if (sidecontrol) begin
				side <= ~side;
			end
		end
	end
			
endmodule














