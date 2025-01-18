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

     logic [(operand_size + fractional_size)*2 - 1: 0] temp_result; // Temporary result to handle overflow
     logic [operand_size + fractional_size - 1: 0] partial_products [operand_size + fractional_size]; // Array to store partial products

     logic [operand_size + fractional_size - 1: 0] a_extended;
     logic [operand_size + fractional_size - 1: 0] b_extended;

     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(fractional_size)
     ) i_a_expand (
          .in(a),
          .out(a_extended)
     );
     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(fractional_size)
     ) i_b_expand (
          .in(b),
          .out(b_extended)
     );   

     // Generate block to calculate partial products
     genvar i;
     generate
          for (i = 0; i < operand_size + fractional_size; i = i + 1) begin : mult_loop
               assign partial_products[i] = b_extended[i] ? (a_extended << i) : 0; // Shift and conditionally select
          end
     endgenerate

     //  sum all partial products
     always_comb begin
          temp_result = 0;  
          for (int j = 0; j < operand_size + fractional_size; j++) begin
               temp_result = temp_result + partial_products[j]; // Accumulate partial products
          end
     end

     // Assign the lower bits to the output
     assign c = temp_result >>> fractional_size;

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