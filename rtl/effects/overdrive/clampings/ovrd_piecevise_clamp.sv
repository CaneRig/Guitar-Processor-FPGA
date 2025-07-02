module ovrd_piecevise_clamp #(
	parameter 	bits_per_level = 12,
                    fxp_size			= 32
) (
	input  signed  [fxp_size-1:	0] i_sample,
	output logic   [fxp_size-1:	0] o_sample
);

	localparam one_level = 1 << bits_per_level;
	localparam half_level = one_level / 2;
	
	localparam mid_level  = (fxp_size)'(1 << (fxp_size-1)); // determines less or more than 0
	localparam pos_one_lv = (fxp_size)'(one_level);
	localparam neg_one_lv = (fxp_size)'(-one_level);
	
	logic[fxp_size - 1:	0] clamped_out;
	
	logic[fxp_size + 2:	0] transformation;  // + 3 bits to avoid overflow
     logic[fxp_size*2-1: 0] sample_extended; // to use in cubing

	logic[fxp_size*2-1:	0] x_squared;  // i_sample^2
	logic[fxp_size*4-1:	0] x_cubed;    // i_sample^3
     logic[fxp_size + 2: 0] x_cubed_slice;   // + 3 bits to avoid overflow


     // modules
     signed_expand#(
          .operand_size       (fxp_size),
          .expansion_size     (fxp_size)
     ) ins_sample_expand (
          .in       (i_sample),
          .out      (sample_extended)
     );

	fixed_multiply#(
		.fractional_size	(0), // to be shure that none of infomation is loosed
		.operand_size		(fxp_size),
          .expansion_size     (fxp_size)
     ) ins_mul_sq (
		.i_a	     (i_sample),
		.i_b 	(i_sample),
		.o_res    (x_squared)
	);

	fixed_multiply#(
		.fractional_size	(bits_per_level * 2),
		.operand_size		(fxp_size * 2)
	) ins_mul_cu (
		.i_a 	(x_squared),
		.i_b	     (sample_extended),
		.o_res    (x_cubed)
	);

     // combinational
	assign x_cubed_slice = x_cubed[fxp_size+2:	0];
	assign transformation = $signed(sample_extended[fxp_size+2: 0]*3 + x_cubed_slice) >>> 2;

     logic [3: 0] hhalf_level;

     assign hhalf_level = { mid_level > i_sample, i_sample >= pos_one_lv, mid_level <= i_sample, i_sample <= neg_one_lv };
	always_comb begin
		if ( mid_level > i_sample && i_sample >= pos_one_lv ) // i_sample >= 1
			clamped_out = (fxp_size)'(half_level);
		else if ( mid_level <= i_sample && i_sample < neg_one_lv ) // i_sample <= 1
			clamped_out = - ((fxp_size)'(half_level));
		else
			clamped_out = transformation; 
		
		o_sample = clamped_out;// + (i_sample & 5'b11111); // some noise
	end

endmodule
