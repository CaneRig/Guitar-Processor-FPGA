module gain #(
     parameter bits_per_level = 12
) (
     input  logic[15: 0] a, b,
     output logic[31: 0] res
);
     
     fixed_multiply #(
          .fractional_size(bits_per_level),
          .operand_size(16)
     ) i_mul (
          .a(a),
          .b(b),
          .c(res)
     );

endmodule