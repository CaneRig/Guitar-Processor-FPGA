module fixed_multiply#(
    parameter bits_per_level = 12,
    parameter number_length  = 32
)(
    input  logic [number_length - 1: 0] a, 
    input  logic [number_length - 1: 0] b,
    output logic [number_length - 1: 0] c
);

    logic [2 * number_length - 1: 0] temp_result; // Temporary result to handle overflow
    logic [number_length - 1: 0] partial_products [number_length]; // Array to store partial products
    genvar i;

    // Generate block to calculate partial products
    generate
        for (i = 0; i < number_length; i = i + 1) begin : mult_loop
            assign partial_products[i] = b[i] ? (a << i) : 0; // Shift and conditionally select
        end
    endgenerate

    //  sum all partial products
    always_comb begin
        temp_result = 0;  
        for (int j = 0; j < number_length; j++) begin
            temp_result = temp_result + partial_products[j]; // Accumulate partial products
        end
    end

    // Assign the lower bits to the output
    assign c = temp_result[number_length - 1: 0];

endmodule