module plothelper(plot, x_out, y_out, color, x_in, y_in, select, clock, enable, resetn);
    parameter size = 12;

    output plot;
    output [7:0] x_out;
    output [6:0] y_out;
    output [5:0] color;
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
    wire [5:0] color_out;

    reg [7:0] x;
    reg [6:0] y;

    always@(posedge enable)
    begin
        x[7:0] <= x_in;
        y[6:0] <= y_in;
    end

    assign x_adder[3:0] = counter_out[7:0] / 4'b10;
    assign y_adder[3:0] = counter_out[7:0] % 4'b10;
    assign x_out[7:0] = x[7:0] + x_adder[3:0];
    assign y_out[6:0] = y[6:0] + y_adder[3:0];
    assign plot = counter_plot;
    assign color[5:0] = color_out[5:0];

    picram_mux pm0 (
        .select(select);
        .clk(clock);
        .address(counter_out[7:0]);
        .color(color_out[5:0]);
    );

    counter c0 (
        .clock(clock),
        .enable(enable),
        .resetn(resetn),
        .q(counter_out),
        .en(counter_plot)
    );
    defparam biggest = (size == 12) ? 143 : 35;
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
		if (!resetn)
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
    input select;
    input clk;
    input [7:0] address;
    output reg [5:0] color;
);

    wire [5:0] bdisk_color;
    wire [5:0] wdisk_color;
    wire [5:0] empty_color;
    wire [5:0] select_color;

    module empty_pic_ram p0 (
	.address(address[7:0]),
	.clock(clk),
	.data(0),
	.wren(0),
	.q(empty_color[5:0]));

    module black_pic_ram p2 (
	.address(address[7:0]),
	.clock(clk),
	.data(0),
	.wren(0),
	.q(bdisk_color[5:0]));

    module white_pic_ram p3 (
	.address(address[7:0]),
	.clock(clk),
	.data(0),
	.wren(0),
	.q(wdisk_color[5:0]));

    module select_pic_ram p1 (
	.address(address[7:0]),
	.clock(clk),
	.data(0),
	.wren(0),
	.q(select_color[5:0]));

    case (select)
      0: begin
        color[5:0] <= empty_color[5:0]; 
      end
      1: begin
        color[5:0] <= select_color[5:0];
      end
      2: begin
        color[5:0] <= bdisk_color[5:0];
      end
      3: begin
        color[5:0] <= wdisk_color[5:0];
      end
      default: color[5:0] <= empty_color[5:0];
    endcase

endmodule