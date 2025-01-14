module gain #(
     parameter bits_per_level = 12
) (
     input shortint signed a, b,
     output int signed res
);
     
     fixed_multiply #(
          .fractional_size(bits_per_level),
          .operand_size(32)
     ) i_mul (
          .a(a),
          .b(b),
          .c(res)
     );

endmodule