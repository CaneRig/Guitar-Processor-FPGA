module overdrive_clamp #(
	parameter bits_per_level = 12
) (
	input int signed x,
	output int signed out
);
	
	localparam one_level = 1 << bits_per_level;
	localparam half_level = one_level / 2;
	
	int signed dx;
	assign dx = int'(x);
	
	always_comb begin
		if ( dx >= one_level )
			out = half_level;
		else if ( dx <= -one_level)
			out = -half_level;
		else
			out = ((dx*3) + (dx * dx / one_level * dx / one_level)) / 4;
	end

endmodule
