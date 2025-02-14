// c = a * b
// 'c' have double width (i.e. operand_size*2)
module fixed_multiply#(
    parameter  fractional_size     = 12,
               operand_size        = 32,
               expansion_size      = operand_size
) (
    input  logic signed[operand_size - 1: 0] a, 
    input  logic signed[operand_size - 1: 0] b,
    output logic signed[operand_size+expansion_size-1: 0] c
);

     localparam extension = (expansion_size < fractional_size)? fractional_size : expansion_size;

     logic signed [(operand_size + extension) - 1: 0] a_extended;
     logic signed [(operand_size + extension) - 1: 0] b_extended;

     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(extension)
     ) i_a_expand (
          .in(a),
          .out(a_extended)
     );
     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(extension)
     ) i_b_expand (
          .in(b),
          .out(b_extended)
     );   

     assign c = $signed(a_extended * b_extended) >>> fractional_size;

endmodule