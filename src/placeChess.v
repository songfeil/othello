module control(
    input clk,
    input restart,
    input go,
	 input en, place, win,
	 
    output reg ld_key, ld_x, ld_y,
	 output reg [3:0] select_ld
    output reg ld_alu_out, plot, draw_cell,
    );

    reg [3:0] current_state, next_state; 
    
    localparam  START_GAME   = 4'd0,
                DRAW_BOARD   = 4'd1,
                B_SELECT     = 4'd2,
                B_PLACE  	  = 4'd3,
                W_SELECT     = 4'd4,
                W_PLACE      = 4'd5,
                END_GAME     = 4'd6,
                S_CYCLE_1    = 4'd7,
                S_CYCLE_2    = 4'd8,
					 S_CYCLE_3    = 4'd9,
					 S_CYCLE_4    = 4'd10;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                START_GAME: next_state = go ? DRAW_BOARD : START_GAME; // Loop in current state until value is input
                DRAW_BOARD: next_state = B_SELECT; // Loop in current state until go signal goes low
                
					 B_SELECT: begin
						 if (place)
								next_state = B_PLACE
						 else
								next_state = en ? S_CYCLE_1 : B_SELECT;
						 end // 
                S_CYCLE_1: next_state = S_CYCLE_2; // Loop in current state until go signal goes low
                S_CYCLE_2: next_state = B_SELECT; // Loop in current state until value is input
                B_PLACE: next_state = win ? END_GAME : W_SELECT; // Loop in current state until go signal goes low
                
					 END_GAME: next_state = en ? START_GAME : END_GAME;
					 
					 W_SELECT: begin
						 if (place)
								next_state = W_PLACE
						 else
								next_state = en ? S_CYCLE_3 : W_SELECT;
						 end
					 S_CYCLE_3: next_state = S_CYCLE_4;
					 S_CYCLE_4: next_state = W_SELECT; // we will be done our two operations, start over after
					 W_PLACE: next_state = win ? END_GAME : B_SELECT;
					 
            default:     next_state = START_GAME;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_alu_out = 1'b0;
        draw_cell = 1'b0;
        ld_key = 1'b0;
        ld_x = 1'b0;
        ld_y = 1'b0;
		  select_ld = 4'b0000;

        case (current_state)
            START_GAME: begin
                select_ld = 4'd10; // beginning scene
					 plot = 1'b1;
                end
            DRAW_BOARD: begin
                select_ld = 4'd11; //load the board pic
					 plot = 1'b1;
                end
            B_SELECT: begin
                ld_x = 1'b1;
					 ld_y = 1'b1; // load present location
                end
            S_CYCLE_1: begin
					 draw_cell = 1'b1; // enable signal for drawing a cell
					 select_ld = 4'd13 // load empty cell pic
                plot = 1'b1; 
					 end
				S_CYCLE_2: begin 
                ld_key = 1'b1; // load present keyboard
					 ld_alu_out = 1'b1;
					 ld_x = 1'b1; 
					 ld_y = 1'b1; // load new location based on keyboard operations
					 select_ld = 4'd2 // load selected cell pic
                plot = 1'b1;
					 end
				B_PLACE: begin
					 select_ld = 4'd14; // load black in cell
					 plot = 1'b1;
					 end
				
				END_GAME: begin  
					 end
				
            W_SELECT: begin 
                ld_x = 1'b1;
					 ld_y = 1'b1;
					 end
				S_CYCLE_3: begin 
					 draw_cell = 1'b1;
					 select_ld = 4'd13;
                plot = 1'b1; 
					 end
				S_CYCLE_4: begin 
					 ld_key = 1'b1;
					 ld_alu_out = 1'b1;
					 ld_x = 1'b1;
					 ld_y = 1'b1;
                plot = 1'b1; 
					 select_ld = 4'd2
					 end
				W_PLACE: begin
					 select_ld = 4'd15; // load white in cell
					 plot = 1'b1;
					 end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(restart)
            current_state <= START_GAME;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

//module datapath(
//    input clk,
//    input resetn,
//    input [6:0] data_in,
//	 input [2:0] c,
//    input ld_alu_out,
//    input ld_x, ld_y,
//    input ld_c,
//	 input [1:0] alu_select_a, alu_select_b,
//    output reg [7:0] pos_x,
//	 output reg [6:0] pos_y,
//	 output reg [2:0] colour
//    );
// 
//    // alu input muxes
//    reg [6:0] alu_a, alu_b;
//    
//	 reg [6:0] alu_out;
//    // Registers x,y,c with respective input logic
//    always @ (posedge clk) begin
//        if (!resetn) begin 
//            colour <= 3'd0; 
//            pos_x <= 7'd0; 
//				pos_y <= 7'd0;
//        end
//        else 
//            if (ld_x)
//                pos_x <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
//            if (ld_y)
//                pos_y <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
//            if (ld_c)
//                colour <= c;
//        end
//    end
//
//    // The ALU input multiplexers
//    always @(*)
//    begin
//        case (alu_select_a)
//            1'd0:
//                alu_a = pos_x;
//            1'd1:
//                alu_a = pos_y;
//            default: alu_a = 7'd0;
//        endcase
//
//        case (alu_select_b)
//            1'd0:
//                alu_b = 1'd1;
//            1'd1:
//                alu_b = -1'd1;
//            default: alu_b = 7'd0;
//        endcase
//    end
//
//    // The ALU 
//    always @(*)
//    begin : ALU
//        // alu
//       alu_out = alu_a + alu_b; //performs addition
//    end
//    
endmodule
