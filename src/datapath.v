module datapath(
    input turn_side, move_up, move_down, move_left, move_right, plot_empty, plot_box, place_disk,
	input [5:0] color,
	input resetn,
	input clk,
    output reg [7:0] x_plot;
    output reg [6:0] y_plot;
    output reg [1:0] select;
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

    module board_ram br0 (
	.address(board_ram_address[5:0]),
	.clock(clk),
	.data(board_ram_data_in[1:0]),
	.wren(board_ram_wren),
	.q(board_ram_out));

    module counter c0(
        .clock(clk),
        .enable(),
        .resetn(),
        .q(),
        .en()
        );

    always@(posedge move) begin
            old_x_pos[2:0] <= curr_x_pos[2:0];
            old_y_pos[2:0] <= curr_y_pos[2:0];
            if (move_up)
                curr_y_pos[2:0] <= curr_y_pos[2:0] - 1;
            if (move_down) begin
                curr_y_pos[2:0] <= curr_y_pos[2:0] + 1;
            if (move_left) begin
                curr_x_pos[2:0] <= curr_x_pos[2:0] - 1;
            if (move move_right) begin
                curr_x_pos[2:0] <= curr_x_pos[2:0] + 1;
    end
 
    always @ (posedge clk) begin
        if (!resetn) begin
            curr_x_pos <= 3'd0;
            curr_y_pos <= 3'd0;
            old_x_pos <= 3'd0;
            old_y_pos <= 3'd0;
            select <= 2'd0;
            x_plot[]
            side <= 0;
        end
        
        if (turn_side)
            side <= ~side;

        if (plot_empty)
        begin
            x_plot[7:0] <= 7'd13 * old_x_pos[2:0] + 7'd9;
            y_plot[6:0] <= 6'd13 * old_y_pos[2:0] + 6'd9;
            select <= 2'd0;
        end

        if (plot_box)
        begin
            x_plot[7:0] <= 7'd13 * curr_x_pos[2:0] + 7'd9;
            y_plot[6:0] <= 6'd13 * curr_y_pos[2:0] + 6'd9;
            select <= 2'd1;
        end

        if (place_disk)
        begin
            x_plot[7:0] <= 7'd13 * curr_x_pos[2:0] + 7'd9;
            y_plot[6:0] <= 6'd13 * curr_y_pos[6:0] + 6'd9;
            select <= (side) ? 2'd2 : 2'd3;
        end
		
    end
	
endmodule














