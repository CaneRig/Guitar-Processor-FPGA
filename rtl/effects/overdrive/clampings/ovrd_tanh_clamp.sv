module ovrd_tanh_clamp #(
	parameter 	bits_per_level = 12,
                    fxp_size		= 32
) (
	input  signed  [fxp_size-1:	0] i_sample,
	output signed  [fxp_size-1:	0] o_sample
);

     pwl_tanh ins_tanh(
          .i_x(i_sample),
          .o_res(o_sample)
     );

endmodule