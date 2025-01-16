module overdrive_clamp #(
	parameter bits_per_level = 12
) (
	input int signed x,
	output int signed out
);
	
	localparam one_level = 2 << bits_per_level;
	localparam half_level = one_level / 2;
	
	int signed dx;
	assign dx = int'(x);
	
	int signed clamped_out;
	
	always_comb begin
		if ( dx >= one_level )
			clamped_out = half_level;
		else if ( dx <= -one_level)
			clamped_out = -half_level;
		else
			clamped_out = ((dx*3) + (dx * dx / one_level * dx / one_level)) / 4;
		
		out = clamped_out ;//+ (x & 5'b11111);
	end

endmodule
