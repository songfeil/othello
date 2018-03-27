//module selecter(clock, en, resetn, enable, x_pos, y_pos, select);
//		
//		input clock;
//		input en;
//		input resetn;
//		
////		input [1:0] select0,q;
//////		input [7:0] dir;
////		input ld_pos,ld_select_out,ld_enable;
////				
////		input enable0;
//		input [7:0] x_plot;
//		input [6:0]	y_plot;
//		
//		output enable;
//		output [7:0] x_pos;
//		output [6:0] y_pos;
//		output [1:0] select;
////		output [17:0] color;
//
//		reg[7:0] x_pos;
//		reg[6:0] y_pos;
//		reg [1:0] select;	
//		reg enable;
//		reg [7:0] d; // Declare d
//
//		
//		enableonce e1(
//		.q(detectcontrol),
//		.enable(detecten),
//		.clock(clock),
//		.resetn(resetn)
//		);
//	
//		always @(posedge clock, negedge resetn) // Triggered every time clock rises
//			begin
//				if (resetn == 1'b0) // When reset n is 0
//					begin
//						d <= 'd64; // Set d to 0
//						enable <= 0;
//					end
//				else // Increment d only when enable is 1
//					begin
//					  if (en) // When d is the maximum value for the counter
//							d <= 'd64;
//					  else
//							begin
//								select <= q;
//								x_pos[7:0] <= 7'd13 * d + 7'd9;
//								y_pos[6:0] <= 6'd13 * d + 6'd9;
//								enable <= 1'b1;
//								d <= d - 1'b1 ; // Increment d
//							end
//					end
//			end
//	
////		plothelper plot1(
////					.plot(plot), 
////					.x_out(x_out), 
////					.y_out(y_out), 
////					.color(color), 
////					
////					.x_in(x_in), 
////					.y_in(y_in), 
////					.select(select), 
////					.clock(clock), 
////					.enable(enable), 
////					.resetn(resetn)
////					);
//				
//endmodule
