module othello(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
      PS2_CLK,
      PS2_DAT,
		KEY,
		LEDR,
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
		input[3:0]  KEY;
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
		
		output [9:0] LEDR;
		
		wire [17:0] colour;
		wire [7:0] x;
		wire [6:0] y;
		wire writeEn;
		wire resetn;
		
		assign resetn = ~(KEY[0]);

	
		vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 6;
		defparam VGA.BACKGROUND_IMAGE = "board_32.mif";
			

	  wire [3:0] select_ld;
 	  wire clk, restart, start;
	  wire place, win;
	  wire ld_alu_out, ld_key, ld_x, ld_y;
	  wire plot_empty, place_disk, draw_cell, turn_side;
	  wire clock;
	  
	  assign win = 0;
	  assign clock = CLOCK_50;
	  
	  assign start = ~KEY[1];
	  assign restart = ~KEY[0];
	  assign LEDR[9] = clk;
	  control c1(
				.clk(clk),
            .restart(restart),
		      .go(~KEY[1]),  
				.win(win),
				.state(LEDR[3:0]),
				.ns(LEDR[7:4]),
				
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
				.move_down(~KEY[2]), 
				.move_left(left), 
				.move_right(right),
				.place(~KEY[3])
				
				);
				
		keyboard_tracker k1 (
				.clock(CLOCK_50),
				.reset(KEY[0]),
	 
				.PS2_CLK(PS2_CLK),
				.PS2_DAT(PS2_DAT),
	 
				.w(), 
				.a(), 
				.s(), 
				.d(),
				.left(left), 
				.right(right), 
				.up(up), 
				.down(down),
				.space(place), 
				.enter()
				);
				
		ratedivider r1(
				.enable(clk),
				.en(1),
				.clock(CLOCK_50),
				.reset_n(~restart)
				);
				
		wire [7:0] x_plot;
		wire [6:0] y_plot;
		wire [1:0] select;
		wire enable;
		
		assign enable = plot_empty | draw_cell | place_disk;
				
		datapath d1(
				.turn_side(turn_side),
				
				.move_up(up), 
				.move_down(down), 
				.move_left(left), 
				.move_right(right),
				
				.plot_empty(plot_empty), 
				.plot_box(draw_cell), 
				.place_disk(place_disk),

				.resetn(restart), 
				.clk(CLOCK_50),
				
				.x_plot(x_plot),
				.y_plot(y_plot),
				.select(select)
				);
				
		plothelper p1(
				.plot(writeEn), 
				.x_out(x), 
				.y_out(y), 
				.color(colour), 
				.x_in(x_plot), 
				.y_in(y_plot), 
				.select(select), 
				.clock(CLOCK_50), 
				.enable(enable), 
				.resetn(restart)
				);
endmodule
