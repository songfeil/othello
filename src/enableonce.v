module enableonce(
	input enable,
	input clock,
	input resetn,
	output reg q
	);
	
	reg enabled;
	
	always @(posedge clock, posedge resetn)
	begin
		if (resetn) begin
			enabled <= 0;
			q <= 0;
		end
		else begin
			if (q == 1)
				q <= 0;
		
			if (enable) begin
				if (~enabled) begin
					q <= 1;
					enabled <= 1;
				end
			end else begin // not enable
				if (enabled)
					enabled <= 0;
			end
		end
	end

endmodule