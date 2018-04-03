
module control(
    input clk,
    input restart,
    input go, jump,
	 input confirm,
	 input move_up, move_down, move_left, move_right, place,
	 input win,
	 
//    output reg ld_key,
//	 output reg [3:0] select_ld
	 output reg enable_select,
	 output reg ld_pos,ld_select_out,ld_enable,
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
	 assign en = move_up || move_down || move_left || move_right;
    localparam  START_GAME   = 4'd0,
//                DRAW_BOARD   = 4'd1,
					 
					 B_SELECT     = 4'd1,
					 
					 B_WAIT       = 4'd8,
					 
                S_CYCLE_WAIT = 4'd3,
					 S_CYCLE_1    = 4'd2,
					 
					 B_WAIT_0 	  = 4'd6,
					 
					 S_CYCLE_2    = 4'd4,
                B_WAIT_1     = 4'd5,
					 
					 B_DET_WAIT   = 4'd9,
					 B_DETECT     = 4'd13,
					 B_WAIT_2     = 4'd15,
                B_PLACE  	  = 4'd14,
					 B_WAIT_3     = 4'd12,
					 
					 PLACE_CYCLE  = 4'd10,
					 TURN_SIDES   = 4'd11,
					 
					 END_GAME     = 4'd7;
                
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                START_GAME: next_state = go ? B_SELECT : START_GAME; // Loop in current state until value is input
//                DRAW_BOARD: next_state = B_SELECT; // Loop in current state until go signal goes low
                
					 B_WAIT: next_state = jump ? B_WAIT : TURN_SIDES;
					 B_SELECT: begin
						 if (jump)
								next_state = B_WAIT;
						 else if (place)
								next_state = B_DET_WAIT;
						 else 
								next_state = en ? S_CYCLE_WAIT : B_SELECT;
//						 else
//								next_state = B_SELECT;
						 end // 
					 S_CYCLE_WAIT: next_state = en ? S_CYCLE_WAIT : S_CYCLE_1;
                S_CYCLE_1: next_state = B_WAIT_0; // Loop in current state until go signal goes low
					 B_WAIT_0: next_state = S_CYCLE_2;
                S_CYCLE_2: next_state = B_WAIT_1; // Loop in current state until value is input
					 
					 B_WAIT_1: next_state = B_SELECT;
					 B_DET_WAIT: next_state = place ? B_DET_WAIT : B_DETECT;
					 B_DETECT:  next_state = B_WAIT_2;
					 B_WAIT_2:  next_state = confirm ? B_PLACE : B_SELECT;
                B_PLACE: next_state = B_WAIT_3;
					 B_WAIT_3: next_state = PLACE_CYCLE;
					 PLACE_CYCLE: next_state = win ? END_GAME : TURN_SIDES; // Loop in current state until go signal goes low
					 
                TURN_SIDES: next_state = B_SELECT;
					 
					 END_GAME: next_state = en ? START_GAME : END_GAME;
					 
//					 W_WAIT: next_state = jump ? W_WAIT : B_SELECT;
					 
            default:     next_state = START_GAME;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		  ld_pos = 1'b0;
		  ld_select_out = 1'b0;
		  ld_enable = 1'b0;
        draw_cell = 1'b0;
//        ld_key = 1'b0;
		  detect = 1'b0;
		  turn_side = 1'b0;
		  plot_empty = 1'b0;
		  draw_cell = 1'b0;
		  place_disk = 1'b0;
		  enable_select = 1'b0;
//		  select_ld = 4'b0000;

        case (current_state)
            START_GAME: begin
//                select_ld = 4'd10; // beginning scene
//					 plot = 1'b1;
                end
//            DRAW_BOARD: begin
//                select_ld = 4'd11; //load the board pic
//					 plot = 1'b1;
//                end
					 
            B_SELECT: begin
					 draw_cell = 1'b1;	 
                end
					 
            S_CYCLE_1: begin
					 draw_cell = 1'b1; 
					 end
					 
				S_CYCLE_2: begin 
					 plot_empty = 1'b1; // enable signal for drawing a cell
					 end
					 
				B_DETECT: begin
					 detect = 1'b1;
					 end
					 
				B_PLACE: begin
					 place_disk = 1'b1;
					 end
				
				PLACE_CYCLE: begin
					 enable_select = 1'b1;
					 end
				TURN_SIDES: begin
					 turn_side = 1'b1;
					 end
					 
				END_GAME: begin  
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

module ratedivider(enable,en,clock,reset_n,d);
	input clock,en,reset_n;
	input [27:0] d;
	
	output enable;
	wire par_load;
	
	reg [27:0] half;
	
	always@(*) begin
		half = d >> 1;
	end
	
//	assign d = 'd833333;
	
	reg [27:0] q; // Declare q
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
	
	assign enable = (q < half) ? 1 : 0;
endmodule

