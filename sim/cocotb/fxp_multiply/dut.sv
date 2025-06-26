`timescale 1ps/1ps

module dut();

     initial $dumpvars;

     localparam int fractional_size     = 12,
                    operand_size        = 32,
                    expansion_size      = operand_size;

     logic[operand_size-1: 0] a;
     logic[operand_size-1: 0] b;
     logic[operand_size*2-1: 0] c;

     fixed_multiply #(
          .fractional_size(fractional_size),
          .operand_size   (operand_size),
          .expansion_size (expansion_size)
     ) i_dut (
          .i_a(a),
          .i_b(b),
          .o_res(c)
     );

endmodule