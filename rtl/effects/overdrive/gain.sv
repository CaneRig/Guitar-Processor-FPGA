module gain #(
     parameter bits_per_level = 12,
               fxp_size	     = 16
) (
     input  [fxp_size - 1: 0] i_sample,
     input  [fxp_size - 1: 0] i_gain,
     output [fxp_size*2-1: 0] o_sample
);
     
     logic[fxp_size*2-1: 0] a_extended;
     logic[fxp_size*2-1: 0] gain_value_extended;
     logic[fxp_size*4-1: 0] big_res;

     signed_expand#(
          .operand_size		(fxp_size),
          .expansion_size	(fxp_size)
     ) i_a_expand (
          .in	(i_sample),
          .out	(a_extended)
     );
     assign gain_value_extended = {'0, i_gain};

     fixed_multiply #(
          .fractional_size	(bits_per_level),
          .operand_size		(fxp_size*2)
     ) ins_mul (
          .i_a		(a_extended),
          .i_b		(gain_value_extended),
          .o_res	(big_res)
     );

     assign o_sample = big_res[fxp_size*2: 0];

endmodule