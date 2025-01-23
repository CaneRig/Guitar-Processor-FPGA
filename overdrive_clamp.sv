module overdrive_clamp #(
	parameter bits_per_level = 12
) (
	input  logic[31:	0] x,
	output logic[31:	0] out
);

	localparam one_level = 2 << bits_per_level;
	localparam half_level = one_level / 2;
	
	localparam mid_level  = 32'h80000000; // determines less or more than 0
	localparam pos_one_lv = 32'(one_level);
	localparam neg_one_lv = 32'(-one_level);
	
	logic[31:	0] clamped_out;
	
	logic[31:	0] transformation;

	logic[63:	0] x_cubed; // x^3
	logic[63:	0] x_squared; // x^2


	fixed_multiply#(
		.fractional_size(bits_per_level),
		.operand_size(32)
	) i_mul_sq (
		.a(x),
		.b(x),
		.c(x_squared)
	);

	fixed_multiply#(
		.fractional_size(bits_per_level),
		.operand_size(32)
	) i_mul_cu (
		.a(x_squared[31:	0]),
		.b(x),
		.c(x_cubed)
	);
	
	assign transformation = $signed(x + x + x + x_cubed[31:	0]) >>> 2;

	always_comb begin
		if ( mid_level > x && x >= pos_one_lv ) // x >= 1
			clamped_out = 32'(half_level);
		else if ( mid_level <= x && x <= neg_one_lv ) // x <= 1
			clamped_out = - 32'(half_level);
		else
			clamped_out = transformation; 
		
		out = clamped_out ;//+ (x & 5'b11111);
	end

endmodule
