module gain #(
     parameter bits_per_level = 12
) (
     input  logic[15: 0] x,
     input  logic[15: 0] gain_value,
     output logic[31: 0] res
);
     
     logic[31: 0] a_extended;
     logic[31: 0] gain_value_extended;
     logic[63: 0] big_res;

     signed_expand#(
          .operand_size(16),
          .expansion_size(32 - 16)
     ) i_a_expand (
          .in(x),
          .out(a_extended)
     );
     assign gain_value_extended = {'0, gain_value};

     fixed_multiply #(
          .fractional_size(bits_per_level),
          .operand_size(32)
     ) i_mul (
          .a(a_extended),
          .b(gain_value_extended),
          .c(big_res)
     );

     assign res = big_res[31: 0];

endmodule