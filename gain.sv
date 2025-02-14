module gain #(
     parameter bits_per_level = 12
) (
     input  [15: 0] in_sample,
     input  [15: 0] in_gain,
     output [31: 0] ou_sample
);
     
     logic[31: 0] a_extended;
     logic[31: 0] gain_value_extended;
     logic[63: 0] big_res;

     signed_expand#(
          .operand_size(16),
          .expansion_size(32 - 16)
     ) i_a_expand (
          .in(in_sample),
          .out(a_extended)
     );
     assign gain_value_extended = {'0, in_gain};

     fixed_multiply #(
          .fractional_size(bits_per_level),
          .operand_size(32)
     ) i_mul (
          .in_a(a_extended),
          .in_b(gain_value_extended),
          .ou_ans(big_res)
     );

     assign ou_sample = big_res[31: 0];

endmodule