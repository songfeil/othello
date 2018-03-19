module hzmodifier(HEX0, SW, CLOCK_50);
	output [6:0] HEX0;
	input [9:0] SW;
	input CLOCK_50;
	
	wire rdout;
	wire dc_clk;
	reg [27:0] rdin;
	wire [3:0] dc2hex;
	
	always @(*)
	begin
		if (SW[1:0] == 2'b01)
			rdin = 28'd49999999;
		else if (SW[1:0] == 2'b10)
			rdin = 28'd99999999;
		else if (SW[1:0] == 2'b11)
			rdin = 28'd199999999;
		else
			rdin = 28'd0;
	end
	
	assign dc_clk = (SW[1:0] == 2'b00) ? CLOCK_50 : rdout;
	
	ratedriver rd1(
		.out(rdout),
		.data_in(rdin),
		.clock(CLOCK_50),
		.reset_n(SW[9])
	);
	
	displaycounter dc1(
		.out(dc2hex),
		.clock(dc_clk),
		.reset_n(SW[9])
	);
	
	numdec n0(
		.HEXDIS(HEX0),
		.HI(dc2hex)
	);
	
endmodule

module ratedriver(out, data_in, clock, reset_n);
	output out;
	input clock, reset_n;
	input [27:0] data_in;
	
	reg [27:0] q;
	
	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 0;
		else
			begin
				if (q == 1'b0)
					q <= data_in;
				else
					q <= q - 1'b1;
			end
	end
	
	assign out = (q == 0) ? 1 : 0;
	
endmodule

module displaycounter(out, clock, reset_n);
	output [3:0] out;
	input clock, reset_n;
	reg [3:0] qd;
	
	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			qd <= 0;
		else
			begin
				if (qd == 4'b1111)
					qd <= 0;
				else
					qd <= qd + 1'b1;
			end
	end
	
	assign out = qd;
	
endmodule