module datapath(
   input turn_side, move_up, move_down, move_left, move_right, plot_empty, plot_box, place_disk,
	input resetn,
	input clk,
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
    assign move = move_up || move_down || move_left || move_right;

    board_ram br0 (
	.address(board_ram_address[5:0]),
	.clock(clk),
	.data(board_ram_data_in[1:0]),
	.wren(board_ram_wren),
	.q(board_ram_out));
	
	
    always @ (posedge clk, posedge move, posedge resetn) begin
        if (resetn) begin
            curr_x_pos <= 3'd0;
            curr_y_pos <= 3'd0;
            old_x_pos <= 3'd0;
            old_y_pos <= 3'd0;
            select <= 2'd0;
            x_plot <= 1'd0;
				y_plot <= 1'd0;
            side <= 1'd0;
        end
		  
		  else if(move) begin
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
        
        else if (turn_side)
            side <= ~side;

        else if (plot_empty)
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
endmodule














