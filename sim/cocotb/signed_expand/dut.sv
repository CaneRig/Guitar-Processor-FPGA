`timescale 1ps/1ps

module dut();

     initial $dumpvars;


     localparam int operand_size   = 12,
                    expansion_size = 4;

     logic [operand_size-1:0] inp;
     logic [operand_size+expansion_size-1:0] out;

     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(expansion_size)
     ) ins_dut (
          .in(inp),
          .out(out)
     );

endmodule