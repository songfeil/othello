module plothelper(plot, x_out, y_out, color, x_in, y_in, select, clock, enable, resetn);
    parameter size = 12;

    output plot;
    output [7:0] x_out;
    output [6:0] y_out;
    output [17:0] color;
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
    wire [17:0] color_out;

    reg [7:0] x;
    reg [6:0] y;
	reg enreg;
	reg enabled;
	reg plotfilter;

    always@(*)
    begin
        x[7:0] <= x_in;
        y[6:0] <= y_in;
		if (select == 2'b01) begin
			if (counter_out == 8'd0 || counter_out == 8'd11 || counter_out == 8'd132 || counter_out == 8'd143)
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
		
			if (enable) begin
				if (~enabled) begin
					enreg <= 1;
					enabled <= 1;
				end
			end else begin // not enable
				if (enabled)
					enabled <= 0;
			end
		end
	end

    assign x_adder[3:0] = counter_out[7:0] / 8'd12;
    assign y_adder[3:0] = counter_out[7:0] - (counter_out[7:0] / 8'd12) * 8'd12;
    assign x_out[7:0] = x[7:0] + x_adder[3:0];
    assign y_out[6:0] = y[6:0] + y_adder[3:0];
    assign plot = counter_plot & plotfilter;
    assign color[17:0] = color_out[17:0];

    picram_mux pm0 (
        .select(select[1:0]),
        .clk(clock),
        .address(counter_out[7:0]),
        .color(color_out[17:0])
    );

    counter c0 (
        .clock(clock),
        .enable(enreg),
        .resetn(resetn),
        .q(counter_out),
        .en(counter_plot)
    );
//    defparam biggest = (size == 12) ? 143 : 35;
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
    output reg [17:0] color
);

    wire [17:0] bdisk_color;
    wire [17:0] wdisk_color;
    wire [17:0] empty_color;
    wire [17:0] select_color;

    empty_pic_ram p0 (
	.address(address[7:0]),
	.clock(clk),
	.data(0),
	.wren(0),
	.q(empty_color[17:0])
	);

    black_pic_ram p2 (
	.address(address[7:0]),
	.clock(clk),
	.data(0),
	.wren(0),
	.q(bdisk_color[17:0]));

    white_pic_ram p3 (
	.address(address[7:0]),
	.clock(clk),
	.data(0),
	.wren(0),
	.q(wdisk_color[17:0]));

    select_pic_ram p1 (
	.address(address[7:0]),
	.clock(clk),
	.data(0),
	.wren(0),
	.q(select_color[17:0]));

	always @(*)
	begin
    case (select[1:0])
      0: begin
        color[17:0] <= empty_color[17:0]; 
      end
      1: begin
        color[17:0] <= select_color[17:0];
      end
      2: begin
        color[17:0] <= bdisk_color[17:0];
      end
      3: begin
        color[17:0] <= wdisk_color[17:0];
      end
      default: color[17:0] <= empty_color[17:0];
    endcase
	end
	
endmodule
