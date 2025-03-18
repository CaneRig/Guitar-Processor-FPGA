module overdrive_clamp #(
	parameter 	bits_per_level = 12,
					fxp_size			= 32
) (
	input          [fxp_size-1:	0] i_sample,
	output logic   [fxp_size-1:	0] o_sample
);

	localparam one_level = 2 << bits_per_level;
	localparam half_level = one_level / 2;
	
	localparam mid_level  = (fxp_size)'(1 << (fxp_size-1)); // determines less or more than 0
	localparam pos_one_lv = (fxp_size)'(one_level);
	localparam neg_one_lv = (fxp_size)'(-one_level);
	
	logic[fxp_size - 1:	0] clamped_out;
	
	logic[fxp_size - 1:	0] transformation;

	logic[fxp_size*2-1:	0] x_cubed; // i_sample^3
	logic[fxp_size*2-1:	0] x_squared; // i_sample^2


	fixed_multiply#(
		.fractional_size	(bits_per_level),
		.operand_size		(fxp_size)
     ) ins_mul_sq (
		.i_a	(i_sample),
		.i_b	(i_sample),
		.o_res(x_squared)
	);

	fixed_multiply#(
		.fractional_size	(bits_per_level),
		.operand_size		(fxp_size)
	) ins_mul_cu (
		.i_a	(x_squared[fxp_size-1:	0]),
		.i_b	(i_sample),
		.o_res(x_cubed)
	);
	
	assign transformation = $signed(i_sample + i_sample + i_sample + x_cubed[31:	0]) >>> 2;

	always_comb begin
		if ( mid_level > i_sample && i_sample >= pos_one_lv ) // i_sample >= 1
			clamped_out = (fxp_size)'(half_level);
		else if ( mid_level <= i_sample && i_sample <= neg_one_lv ) // i_sample <= 1
			clamped_out = - ((fxp_size)'(half_level));
		else
			clamped_out = transformation; 
		
		o_sample = clamped_out + (i_sample & 5'b11111); // some noise
	end

endmodule
