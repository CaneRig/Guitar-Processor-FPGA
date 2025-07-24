// o_res = i_a * i_b
// 'o_res' have double width (i.e. operand_size*2)
module fixed_multiply#(
    parameter  fractional_size     = 12,
               operand_size        = 16,
               expansion_size      = operand_size
) (
    input  logic signed[operand_size - 1: 0] i_a, 
    input  logic signed[operand_size - 1: 0] i_b,
    output logic signed[operand_size+expansion_size-1: 0] o_res
);

     localparam extension = (expansion_size < fractional_size)? fractional_size : expansion_size;

     logic signed [(operand_size + extension) - 1: 0] a_extended;
     logic signed [(operand_size + extension) - 1: 0] b_extended;

     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(extension)
     ) ins_a_expand (
          .in(i_a),
          .out(a_extended)
     );
     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(extension)
     ) ins_b_expand (
          .in(i_b),
          .out(b_extended)
     );   

     assign o_res = $signed(a_extended * b_extended) >>> fractional_size;

endmodule