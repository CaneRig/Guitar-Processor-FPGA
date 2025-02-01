// c = a * b
// 'c' have double width (i.e. operand_size*2)
module fixed_multiply#(
    parameter  fractional_size     = 12,
               operand_size        = 32
) (
    input  logic signed[operand_size - 1: 0] a, 
    input  logic signed[operand_size - 1: 0] b,
    output logic signed[operand_size*2-1: 0] c
);

     logic signed [(operand_size)*2 - 1: 0] a_extended;
     logic signed [(operand_size)*2 - 1: 0] b_extended;

     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(operand_size)
     ) i_a_expand (
          .in(a),
          .out(a_extended)
     );
     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(operand_size)
     ) i_b_expand (
          .in(b),
          .out(b_extended)
     );   

     assign c = $signed(a_extended * b_extended) >>> fractional_size;

endmodule

// converts in[operand_size-1: 0] -> out[operand_size+expansion_size-1: 0] according to the sign
module signed_expand #(
     parameter operand_size   = 12,
               expansion_size = 4 
) (
     input logic[operand_size-1: 0]                    in, 
     output logic[operand_size+expansion_size-1: 0]    out
);
     logic sign;
     
     always_comb begin
          sign = (in & ((operand_size)'(1) << (operand_size - 1))) >> (operand_size - 1);

          out = {(expansion_size)'(0) - sign, in};
     end
endmodule