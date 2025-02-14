// ou_ans = in_a * in_b
// 'ou_ans' have double width (i.e. operand_size*2)
module fixed_multiply#(
    parameter  fractional_size     = 12,
               operand_size        = 32,
               expansion_size      = operand_size
) (
    input  logic signed[operand_size - 1: 0] in_a, 
    input  logic signed[operand_size - 1: 0] in_b,
    output logic signed[operand_size+expansion_size-1: 0] ou_ans
);

     localparam extension = (expansion_size < fractional_size)? fractional_size : expansion_size;

     logic signed [(operand_size + extension) - 1: 0] a_extended;
     logic signed [(operand_size + extension) - 1: 0] b_extended;

     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(extension)
     ) i_a_expand (
          .in(in_a),
          .out(a_extended)
     );
     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(extension)
     ) i_b_expand (
          .in(in_b),
          .out(b_extended)
     );   

     assign ou_ans = $signed(a_extended * b_extended) >>> fractional_size;

endmodule