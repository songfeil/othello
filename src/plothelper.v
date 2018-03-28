module plothelper(plot, x_out, y_out, color, x_in, y_in, select, clock, enable, resetn);
    parameter size = 12;

    output plot;
    output [7:0] x_out;
    output [6:0] y_out;
    output [2:0] color;
    input [7:0] x_in;
    input [6:0] y_in;
    input [1:0] select;
    input clock;
    input enable;
    input resetn;

    wire [7:0] counter_out;
    wire counter_plot;
    wire [3:0] x_adder;
    wire [3:0] y_adder;
    wire [2:0] color_out;

	reg enreg;
	reg enreg1;
	reg enreg2;
	reg enreg3;
	reg enabled;
	reg plotfilter;

    always@(*)
    begin
		if (select == 2'b01 || select == 2'b00) begin
			if ((x_adder == 8'd0 || x_adder == 8'd11) && (y_adder == 8'd0 || y_adder == 8'd11))
				plotfilter = 1;
			else
				plotfilter = 0;
		end else
			plotfilter = 1;
    end
	
	always @(posedge clock, posedge resetn)
	begin
		if (resetn) begin
			enabled <= 0;
		end
		else begin
			if (enreg == 1)
				enreg <= 0;
			if (enreg3 == 1) begin
				enreg2 <= 1;
				enreg3 <= 0;
			end
			if (enreg2 == 1) begin
				enreg1 <= 1;
				enreg2 <= 0;
			end
			if (enreg1 == 1) begin
				enreg <= 1;
				enreg1 <= 0;
			end
			if (enable) begin
				if (~enabled) begin
					enreg3 <= 1;
					enabled <= 1;
				end
			end else begin // not enable
				if (enabled)
					enabled <= 0;
			end
		end
	end

    assign x_out[7:0] = x_in[7:0] + x_adder[3:0];
    assign y_out[6:0] = y_in[6:0] + y_adder[3:0] - 1;
    assign plot = counter_plot & plotfilter;
    assign color[2:0] = color_out[2:0];

    picram_mux pm0 (
        .select(select[1:0]),
        .clk(clock),
        .address(counter_out[7:0]),
        .color(color_out[2:0])
    );

    doublecounter c0 (
        .clock(clock),
        .enable(enreg),
        .resetn(resetn),
        .x(x_adder),
		.y(y_adder),
        .en(counter_plot)
    );
//    defparam biggest = (size == 12) ? 143 : 35;
endmodule

module doublecounter(clock, enable, resetn, x, y, en);
	parameter biggest = 11;

	input clock;
	input enable;
	input resetn;
	output reg [7:0] x;
	output reg [7:0] y;
	
	output reg en;
	
	always@(posedge clock)
	begin
		if (resetn)
		begin
			x <= 7'b0;
			y <= 7'b0;
			en <= 0;
		end

		if (enable)
		begin
			en <= 1;
		end
		
		if (en) begin
			if (y == biggest) begin
				if (x == biggest) begin
					x <= 0;
					y <= 0;
					en <= 0;
				end
				y <= 0;
				x <= x + 1;
			end else
				y <= y + 1;
		end
		
		if (~en) begin
			x <= 0;
			y <= 0;
		end
	end
endmodule


module counter(clock, enable, resetn, q, en);
    parameter biggest = 143;

	input clock;
	input enable;
	input resetn;
	output reg [7:0] q;
	
	output reg en;
	
	always@(posedge clock)
	begin
		if (resetn)
		begin
			q <= 7'b0;
			en <= 0;
		end		
		
		if (en && q == biggest)
			en <= 0;
			
		if (enable)
		begin
			en <= 1;
		end
		
		if (en)
			q <= q + 1;
			
		if (!en)
			q <= 4'b0;
	end
endmodule

module picram_mux(
    input [1:0] select,
    input clk,
    input [7:0] address,
    output reg [2:0] color
);

    wire [2:0] bdisk_color;
    wire [2:0] wdisk_color;
    wire [2:0] empty_color;
    wire [2:0] select_color;
	
	empty_pic_rom p0 (
	.address(address[7:0]),
	.clock(clk),
	.q(empty_color[2:0])
	);

    black_pic_rom p2 (
	.address(address[7:0]),
	.clock(clk),
	.q(bdisk_color[2:0]));

    white_pic_rom p3 (
	.address(address[7:0]),
	.clock(clk),
	.q(wdisk_color[2:0]));

    select_pic_rom p1 (
	.address(address[7:0]),
	.clock(clk),
	.q(select_color[2:0]));

	always @(*)
	begin
    case (select[1:0])
      2'd0: begin
        color[2:0] <= empty_color[2:0]; 
      end
      2'd2: begin
        color[2:0] <= select_color[2:0];
      end
      2'd1: begin
        color[2:0] <= bdisk_color[2:0];
      end
      2'd3: begin
        color[2:0] <= wdisk_color[2:0];
      end
    endcase
	end
	
endmodule
