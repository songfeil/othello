module othello(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
      PS2_CLK,
      PS2_DAT,
		KEY,
		LEDR,
		HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,
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
		output[6:0] HEX1;
		output[6:0] HEX2;
		output[6:0] HEX3;
		output[6:0] HEX4;
		output[6:0] HEX5;
		
		wire [2:0] colour;
		wire [7:0] x;
		wire [6:0] y;
		wire writeEn;
		wire resetn;
		
		assign resetn = ~(KEY[0]);
//		assign LEDR[9] = writeEn;

	
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
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "board_32.mif";
			

	  wire [3:0] state,ns;
//	  select_ld;
 	  wire clk, restart, start;
	  wire place, win;
	  wire ld_pos,ld_select_out,ld_enable;
	  wire up, down, left, right;
	  wire plot_empty, place_disk, draw_cell, turn_side;
	  wire confirm;
	  wire enable_select;
	  wire [7:0] check_dir;
//	  wire clock;
	  
	  assign win = 0;
	  assign confirm = |check_dir[7:0];
//	  assign clock = CLOCK_50;
	  
	  assign keyright = ~KEY[1];
	  assign keydown = ~KEY[2];
	  wire orright;
	  assign orright = keyright || right;
	  assign ordown = keydown || down;
//	  assign start = ~KEY[1];
	  assign restart = ~KEY[0];
//	  assign LEDR[0] = clk;
	  
	  control c1(
				.clk(clk),
            .restart(restart),
		      .go(1), 
				.jump(),
				.confirm(confirm),
				.win(win),
				.state(state),
				.ns(ns),
				
//				.ld_key(ld_key), 
				.ld_pos(ld_pos),
				.ld_select_out(ld_select_out),
				.ld_enable(ld_enable), 
				.enable_select(enable_select),
				
				.draw_cell(draw_cell),
				.plot_empty(plot_empty), 
				.place_disk(place_disk),
				.turn_side(turn_side),
				.detect(detect),
				
				.move_up(up), 
				.move_down(ordown), 
				.move_left(left), 
				.move_right(orright),
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
				.reset_n(~restart),
				.d('d2833333)
				);
				
		wire [7:0] x_plot0, x_plot1;
		wire [6:0] y_plot0, y_plot1;
		wire [1:0] select0, select1; 	
		wire [7:0] x_plot = enable_select ? x_plot1[7:0] : x_plot0[7:0];
		wire [6:0] y_plot = enable_select ? y_plot1[6:0] : y_plot0[6:0];
		wire [1:0] select = enable_select ? select1[1:0] : select0[1:0];
//		wire [1:0] q_data[0:63];
		wire enable, enable0, enable1;
		
		assign LEDR[7:0] = x_plot0;
		wire[2:0] x_pos, y_pos;
		assign enable0 = plot_empty || draw_cell || place_disk;
		assign enable = enable_select ? enable1 : enable0;
		
		wire[2:0] old_x, old_y;
		wire[15:0] check_board;
				
		datapath d1(
				.turn_side(turn_side),
				
				.move_up(up), 
				.move_down(ordown), 
				.move_left(left), 
				.move_right(orright),
				
				.plot_empty(plot_empty), 
				.plot_box(draw_cell), 
				.place_disk(place_disk),

				.resetn(restart), 
				.clock(CLOCK_50),
				
				.x(x_pos),
				.y(y_pos),
				.x_plot(x_plot0),
				.y_plot(y_plot0),
				.select(select0),
				.outside(datapath_side)
//				.old_x(old_x),
//				.old_y(old_y)
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
		
		board_ram b1(
				.clock(CLOCK_50), 
				.resetn(restart), 
				.side(datapath_side), 
				.detecten(detect), 
				.writeen(place_disk),
//				.en_plot(place_disk),
				.x(x_pos), 
				.y(y_pos), 
				.q(q_data), 
				.dir(check_dir),
				
				.x_plot(x_plot1),
				.y_plot(y_plot1),
				.select(select1),
				.enable(enable1),
				.check_board(check_board)
				);
		
//		selecter re(
//				.clock(CLOCK_50), 
//				.en(enable_select), 
//				.resetn(restart),
//				
//				.ld_pos(ld_pos),
//				.ld_select_out(ld_select_out),
//				.ld_enable(ld_enable),
//				
//				.q(q_data), 
//				.select0(select0),
//				.enable0(enable0),
//				.x_plot(x_plot0),
//				.y_plot(y_plot0),
//				
//				.enable(enable),
//				.x_pos(x_plot), 
//				.y_pos(y_plot),
//				.select(select)
//				);
		
		hex_decoder H0(
			  .hex_digit(state), 
			  .segments(HEX0)
			  );
        
		hex_decoder H1(
			  .hex_digit(ns), 
			  .segments(HEX1)
			  );
		hex_decoder H2(
			  .hex_digit(check_board[3:0]), 
			  .segments(HEX2)
			  );
		hex_decoder H3(
			  .hex_digit(check_board[7:4]), 
			  .segments(HEX3)
			  );
		hex_decoder H4(
			  .hex_digit(check_board[11:8]), 
			  .segments(HEX4)
			  );
		hex_decoder H5(
			  .hex_digit(check_board[15:12]), 
			  .segments(HEX5)
			  );
				
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