
module control(
    input clk,
    input restart,
    input go, jump,
	 input confirm,
	 input move_up, move_down, move_left, move_right, place,
	 input win,
	 
//    output reg ld_key,
//	 output reg [3:0] select_ld
	 output reg turn_side, detect,
    output reg plot_empty, draw_cell, place_disk,
	 output [3:0] state,
	 output [3:0] ns
	 );

    reg [3:0] current_state, next_state;
	 wire en;
	 assign state[3:0] = current_state[3:0];
	 assign ns[3:0] = next_state[3:0];
	 
//	 assign en = 0;
	 assign en = move_up | move_down | move_left | move_right;
    localparam  START_GAME   = 4'd0,
                DRAW_BOARD   = 4'd1,
					 
					 B_WAIT       = 4'd2,
                B_SELECT     = 4'd3,
					 S_CYCLE_1    = 4'd4,
                S_CYCLE_2    = 4'd5,
					 B_DETECT     = 4'd6,
                B_PLACE  	  = 4'd7,
					 
					 W_WAIT		  = 4'd8,
                W_SELECT     = 4'd9,
					 S_CYCLE_3    = 4'd10,
					 S_CYCLE_4    = 4'd11,
					 W_DETECT     = 4'd12,
                W_PLACE      = 4'd13,
                
					 END_GAME     = 4'd14;
                
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                START_GAME: next_state = go ? DRAW_BOARD : START_GAME; // Loop in current state until value is input
                DRAW_BOARD: next_state = B_SELECT; // Loop in current state until go signal goes low
                
					 B_WAIT: next_state = jump ? B_WAIT : W_SELECT;
					 B_SELECT: begin
						 if (jump)
								next_state = B_WAIT;
						 else if (place)
								next_state = B_DETECT;
						 else
								next_state = en ? S_CYCLE_1 : B_SELECT;
						 end // 
                S_CYCLE_1: next_state = S_CYCLE_2; // Loop in current state until go signal goes low
                S_CYCLE_2: next_state = B_SELECT; // Loop in current state until value is input
					 B_DETECT:  next_state = confirm ? B_PLACE : B_SELECT;
                B_PLACE: next_state = win ? END_GAME : W_SELECT; // Loop in current state until go signal goes low
                
					 END_GAME: next_state = en ? START_GAME : END_GAME;
					 
					 W_WAIT: next_state = jump ? W_WAIT : B_SELECT;
					 W_SELECT: begin
						 if (jump)
								next_state = B_SELECT;
						 else if (place)
								next_state = W_DETECT;
						 else
								next_state = en ? S_CYCLE_3 : W_SELECT;
						 end
					 S_CYCLE_3: next_state = S_CYCLE_4;
					 S_CYCLE_4: next_state = W_SELECT; // we will be done our two operations, start over after
					 W_DETECT: next_state = confirm ? W_PLACE : W_SELECT;
					 W_PLACE: next_state = win ? END_GAME : B_SELECT;
					 
            default:     next_state = START_GAME;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
//        ld_alu_out = 1'b0;
//        ld_x = 1'b0;
//        ld_y = 1'b0;
        draw_cell = 1'b0;
//        ld_key = 1'b0;

		  turn_side = 1'b0;
		  plot_empty = 1'b0;
		  draw_cell = 1'b0;
		  place_disk = 1'b0;
//		  select_ld = 4'b0000;

        case (current_state)
            START_GAME: begin
//                select_ld = 4'd10; // beginning scene
//					 plot = 1'b1;
                end
            DRAW_BOARD: begin
//                select_ld = 4'd11; //load the board pic
//					 plot = 1'b1;
                end
            B_SELECT: begin
//                ld_x = 1'b1;
//					 ld_y = 1'b1; // load present location
					 draw_cell = 1'b1;
					 turn_side = 1'b0;
                end
            S_CYCLE_1: begin
					 plot_empty = 1'b1; // enable signal for drawing a cell
//					 select_ld = 4'd13 // load empty cell pic 
					 end
				S_CYCLE_2: begin 
//                ld_key = 1'b1; // load present keyboard
//					 ld_alu_out = 1'b1;
//					 ld_x = 1'b1; 
//					 ld_y = 1'b1; // load new location based on keyboard operations
//					 select_ld = 4'd2 // load selected cell pic
                draw_cell = 1'b1;
					 end
				B_DETECT: begin
					 detect = 1'b1;
					 end
					 
				B_PLACE: begin
//					 select_ld = 4'd14; // load black in cell
					 place_disk = 1'b1;
					 end
				
				END_GAME: begin  
					 end
				
            W_SELECT: begin 
                draw_cell = 1'b1;
					 turn_side = 1'b1;
					 end
				S_CYCLE_3: begin
                plot_empty = 1'b1; 
					 end
				S_CYCLE_4: begin 
//					 ld_key = 1'b1; // load present keyboard
//					 ld_alu_out = 1'b1;
//					 ld_x = 1'b1; 
//					 ld_y = 1'b1; // load new location based on keyboard operations
//					 select_ld = 4'd2 // load selected cell pic
                draw_cell = 1'b1;
					 end
				W_DETECT: begin
					 detect = 1'b1;
				W_PLACE: begin
//					 select_ld = 4'd15; // load white in cell
					 place_disk = 1'b1;
					 end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(restart) begin
            current_state <= START_GAME;
				//next_state <= START_GAME;
				end
        else
            current_state <= next_state;
    end // state_FFS
	 
endmodule

module ratedivider(enable,en,clock,reset_n);
	input clock,en,reset_n;
	output enable;
	wire par_load;
	wire [19:0] d;
	assign d = 'd833333;
	
	reg [19:0] q; // Declare q
//	assign par_load = (q == 0) ? 1 : 0;
	always @(posedge clock, negedge reset_n) // Triggered every time clock rises
		begin
			if (reset_n == 1'b0) // When reset n is 0
				q <= d; // Set q to 0
//			else if (par_load == 1'b1) // Check if parallel load
//				q <= d; // Load d
			else if (en == 1'b1) // Increment q only when enable is 1
				begin
				  if (q == 0) // When q is the maximum value for the counter
						q <= d;
				  else
						q <= q - 1'b1 ; // Increment q
				end
		end
	
	assign enable = (q == 0) ? 1 : 0;
endmodule

