module othello(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
      PS2_CLK,
      PS2_DAT,
		KEY,
		LEDR,
		HEX0,HEX2,HEX4,HEX5,
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
		
		output[9:0] LEDR;
		output[6:0] HEX0;
		output[6:0] HEX2;
		output[6:0] HEX4;
		output[6:0] HEX5;
		
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
			

	  wire [3:0] state,ns;
//	  select_ld;
 	  wire clk, restart, start;
	  wire place, win;
//	  wire ld_alu_out, ld_key, ld_x, ld_y;
	  wire up, down, left, right;
	  wire plot_empty, place_disk, draw_cell, turn_side;
	  wire confirm;
	  wire [7:0] check_dir;
//	  wire clock;
	  
	  assign win = 0;
	  assign confirm = &check_dir;
//	  assign clock = CLOCK_50;
	  
	  assign start = ~KEY[1];
	  assign restart = ~KEY[0];
	  assign LEDR[9] = clk;
	  
	  control c1(
				.clk(clk),
            .restart(restart),
		      .go(~KEY[1]), 
				.jump(~KEY[3]),
				.confirm(confirm),
				.win(win),
				.state(state),
				.ns(ns),
				
//				.ld_key(ld_key), 
//				.ld_x(ld_x), 
//				.ld_y(ld_y),
//				.select_ld(select_ld),
//				.ld_alu_out(ld_alu_out),  
				.draw_cell(draw_cell),
				.plot_empty(plot_empty), 
				.place_disk(place_disk),
				.turn_side(turn_side),
				.detect(detect),
				
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
				
		wire [7:0] x_plot = place_disk ? x_plot1 : x_plot0;
		wire [6:0] y_plot = place_disk ? y_plot1 : y_plot0;
		wire [1:0] select = place_disk ? select1 : select0;
		wire [1:0] q_data[0:63];
		wire enable;
		
		assign enable0 = plot_empty | draw_cell;
				
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
				
				.x_plot(x_plot0),
				.y_plot(y_plot0),
				.select(select0)
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
		
		board_ram(
				.clock(CLOCK_50), 
				.resetn(restart), 
				.side(), 
				.detecten(detect), 
				.writeen(place_disk), 
				.x(), 
				.y(), 
				.q(q_data), 
				.dir(check_dir)
				);
		
		redraw re(
				.clock(CLOCK_50), 
				.en, 
				.resetn(restart), 
				.q(q_data), 
				.enable(enable1), 
				.x_pos(x_plot1), 
				.y_pos(y_plot1),
				.select(select1)
				);
		
		hex_decoder H0(
			  .hex_digit(state), 
			  .segments(HEX0)
			  );
        
		hex_decoder H2(
			  .hex_digit(ns), 
			  .segments(HEX2)
			  );
//		hex_decoder H4(
//			  .hex_digit(SW[7:4]), 
//			  .segments(HEX4)
//			  );
//		hex_decoder H5(
//			  .hex_digit(SW[8]), 
//			  .segments(HEX5)
//			  );
				
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule