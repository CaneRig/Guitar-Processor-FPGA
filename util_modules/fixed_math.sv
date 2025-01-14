module fixed_multiply#(
    parameter  fractional_size     = 12,
               operand_size        = 32
)(
    input  logic [fractional_size - 1: 0] a, 
    input  logic [fractional_size - 1: 0] b,
    output logic [fractional_size - 1: 0] c
);

    logic [2 * fractional_size - 1: 0] temp_result; // Temporary result to handle overflow
    logic [fractional_size - 1: 0] partial_products [fractional_size]; // Array to store partial products
    genvar i;

    // Generate block to calculate partial products
    generate
        for (i = 0; i < fractional_size; i = i + 1) begin : mult_loop
            assign partial_products[i] = b[i] ? (a << i) : 0; // Shift and conditionally select
        end
    endgenerate

    //  sum all partial products
    always_comb begin
        temp_result = 0;  
        for (int j = 0; j < fractional_size; j++) begin
            temp_result = temp_result + partial_products[j]; // Accumulate partial products
        end
    end

    // Assign the lower bits to the output
    assign c = temp_result[fractional_size + operand_size - 1: operand_size];

endmodule