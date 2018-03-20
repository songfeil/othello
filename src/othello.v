module othello(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
      PS2_CLK,
      PS2_DAT,
		KEY
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input		[9:0] KEY;
	inout 		PS2_CLK, PS2_DAT;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	

	  wire [3:0] select_ld;
 	  wire clk, restart, start;
	  wire place, win;
	  wire ld_alu_out, ld_key, ld_x, ld_y;
	  wire plot_empty, place_disk, draw_cell, turn_side;
	  wire clock;
	  
	  assign win = 0;
	  assign clock = CLOCK_50;
	  
	  control c1(
				.clk(clk),
            .restart(restart),
		      .go(start),  
				.win(win),
				
//				.ld_key(ld_key), 
//				.ld_x(ld_x), 
//				.ld_y(ld_y),
//				.select_ld(select_ld),
//				.ld_alu_out(ld_alu_out),  
				.draw_cell(draw_cell),
				.plot_empty(plot_empty), 
				.place_disk(place_disk),
				.turn_side(turn_side),
				
				.move_up(up), 
				.move_down(down), 
				.move_left(left), 
				.move_right(right),
				.place(place)
				
				);
				
		keyboard_tracker k1 (
				.clock(CLOCK_50),
				.reset(KEY[0]),
	 
				.PS2_CLK(PS2_CLK),
				.PS2_DAT(PS2_DAT),
	 
				.w(restart), 
				.a(), 
				.s(), 
				.d(),
				.left(left), 
				.right(right), 
				.up(up), 
				.down(down),
				.space(place), 
				.enter(start)
				);
				
		ratedivider r1(
				.enable(clk),
				.en(start),
				.clock(CLOCK_50),
				.reset_n(restart)
				);
				
		datapath d1(
				.turn_side(turn_side),
				
				.move_up(up), 
				.move_down(down), 
				.move_left(lefft), 
				.move_right(right),
				
				.plot_empty(plot_empty), 
				.plot_box(draw_cell), 
				.place_disk(place_disk),

				.resetn(restart), 
				.clk(CLOCK_50),
				
				.x_plot,
				.y_plot,
				.select;
				);
endmodule
