module overdrive_clamp #(
	parameter bits_per_level = 12
) (
	input          [31:	0] in_sample,
	output logic   [31:	0] ou_sample
);

	localparam one_level = 2 << bits_per_level;
	localparam half_level = one_level / 2;
	
	localparam mid_level  = 32'h80000000; // determines less or more than 0
	localparam pos_one_lv = 32'(one_level);
	localparam neg_one_lv = 32'(-one_level);
	
	logic[31:	0] clamped_out;
	
	logic[31:	0] transformation;

	logic[63:	0] x_cubed; // in_sample^3
	logic[63:	0] x_squared; // in_sample^2


	fixed_multiply#(
		.fractional_size(bits_per_level),
		.operand_size(32)
	) i_mul_sq (
		.in_a(in_sample),
		.in_b(in_sample),
		.ou_ans(x_squared)
	);

	fixed_multiply#(
		.fractional_size(bits_per_level),
		.operand_size(32)
	) i_mul_cu (
		.in_a(x_squared[31:	0]),
		.in_b(in_sample),
		.ou_ans(x_cubed)
	);
	
	assign transformation = $signed(in_sample + in_sample + in_sample + x_cubed[31:	0]) >>> 2;

	always_comb begin
		if ( mid_level > in_sample && in_sample >= pos_one_lv ) // in_sample >= 1
			clamped_out = 32'(half_level);
		else if ( mid_level <= in_sample && in_sample <= neg_one_lv ) // in_sample <= 1
			clamped_out = - (32'(half_level));
		else
			clamped_out = transformation; 
		
		ou_sample = clamped_out + (in_sample & 5'b11111); // some noise
	end

endmodule
