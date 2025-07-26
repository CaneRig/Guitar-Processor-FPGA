module complex_multiplier #(
    parameter fractional_size = 12,
    parameter operand_size = 16,
    parameter expansion_size = operand_size
) (
    input  logic signed [operand_size-1:0] i_a_real,  // Real part of first complex number
    input  logic signed [operand_size-1:0] i_a_imag,  // Imaginary part of first complex number
    input  logic signed [operand_size-1:0] i_b_real,  // Real part of second complex number
    input  logic signed [operand_size-1:0] i_b_imag,  // Imaginary part of second complex number
    output logic signed [operand_size+expansion_size-1:0] o_res_real, // Real part of result
    output logic signed [operand_size+expansion_size-1:0] o_res_imag  // Imaginary part of result
);

    // Intermediate products
    logic signed [operand_size+expansion_size-1:0] ac, bd, ad, bc;
    
    // Instantiate fixed_multiply modules for each multiplication needed
    fixed_multiply #(
        .fractional_size(fractional_size),
        .operand_size(operand_size),
        .expansion_size(expansion_size)
    ) mult_ac (
        .i_a(i_a_real),
        .i_b(i_b_real),
        .o_res(ac)
    );
    
    fixed_multiply #(
        .fractional_size(fractional_size),
        .operand_size(operand_size),
        .expansion_size(expansion_size)
    ) mult_bd (
        .i_a(i_a_imag),
        .i_b(i_b_imag),
        .o_res(bd)
    );
    
    fixed_multiply #(
        .fractional_size(fractional_size),
        .operand_size(operand_size),
        .expansion_size(expansion_size)
    ) mult_ad (
        .i_a(i_a_real),
        .i_b(i_b_imag),
        .o_res(ad)
    );
    
    fixed_multiply #(
        .fractional_size(fractional_size),
        .operand_size(operand_size),
        .expansion_size(expansion_size)
    ) mult_bc (
        .i_a(i_a_imag),
        .i_b(i_b_real),
        .o_res(bc)
    );
    
    // Calculate real and imaginary parts of the result
    // Real part: (a_real * b_real) - (a_imag * b_imag)
    assign o_res_real = ac - bd;
    
    // Imaginary part: (a_real * b_imag) + (a_imag * b_real)
    assign o_res_imag = ad + bc;

endmodule