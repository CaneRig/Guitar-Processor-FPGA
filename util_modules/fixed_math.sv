// c = a * b
module fixed_multiply#(
    parameter  fractional_size     = 12,
               operand_size        = 32
)(
    input  logic [operand_size - 1: 0] a, 
    input  logic [operand_size - 1: 0] b,
    output logic [operand_size - 1: 0] c
);

     logic [operand_size + fractional_size - 1: 0] temp_result; // Temporary result to handle overflow
     logic [operand_size +fractional_size - 1: 0] partial_products [operand_size + fractional_size]; // Array to store partial products

     logic a_sign, b_sign;

     logic [operand_size + fractional_size - 1: 0] a_extended;
     logic [operand_size + fractional_size - 1: 0] b_extended;


     always_comb begin
          a_sign = (a & ((operand_size)'(1) << (operand_size - 1))) >> (operand_size - 1);
          b_sign = (b & ((operand_size)'(1) << (operand_size - 1))) >> (operand_size - 1);

          a_extended = {(fractional_size)'(0) - a_sign, a};
          b_extended = {(fractional_size)'(0) - b_sign, b};
     end
     

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