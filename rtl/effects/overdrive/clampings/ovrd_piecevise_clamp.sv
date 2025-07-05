/*
 * f(x) = -3/4, x <= -1
 * f(x) =  (3*x+x*x*x), -1<=x<=1
 * f(x) =  3/4, x <=  1
*/

module ovrd_piecevise_clamp #(
	parameter 	bits_per_level = 12,
                    fxp_size		= 32
) (
	input  signed  [fxp_size-1:	0] i_sample,
	output signed  [fxp_size-1:	0] o_sample
);

     localparam FXP_ONE = $signed((fxp_size)'((fxp_size)'(1) << bits_per_level));
     localparam FXP_CLAMED_VALUE = $signed((fxp_size)'(FXP_ONE * 3 / 4));

     initial $display("FXP_ONE = %d, FXP_CLAMPED_VALUE = %d\n\n", FXP_ONE, FXP_CLAMED_VALUE);

     /// Wires 
	logic clamp_lower; // x <= -1
	logic clamp_upper; // x >= 1

     logic signed [fxp_size-1:     0] non_linear_dist; // (3x+x^3)/4
     logic signed [fxp_size-1:     0] non_linear_dist_wide; // (3x+x^3)/4

     logic signed [fxp_size-1:     0] squared_x_trimmed;
     logic signed [fxp_size-1:     0] output_sample;


     logic signed [fxp_size+bits_per_level-1:   0] wide_x;
     logic signed [fxp_size+bits_per_level-1:   0] three_x;
     logic signed [fxp_size+bits_per_level-1:   0] squared_x;
     logic signed [fxp_size+bits_per_level-1:   0] cubed_x;

     assign squared_x_trimmed = squared_x >>> bits_per_level;

     // Expansioins
     signed_expand#(
          .operand_size(fxp_size),
          .expansion_size(bits_per_level)
     ) i_x_expander (
          .in(i_sample),
          .out(wide_x)
     );

     /// Cube calculaiton
     fixed_multiply#(
          .fractional_size(bits_per_level),
          .operand_size(fxp_size),
          .expansion_size(bits_per_level)
     ) ins_square (
          .i_a(i_sample),
          .i_b(i_sample),
          .o_res(squared_x)
     );

     fixed_multiply#(
          .fractional_size(bits_per_level),
          .operand_size(fxp_size),
          .expansion_size(bits_per_level)
     ) ins_cube (
          .i_a(squared_x_trimmed),
          .i_b(i_sample),
          .o_res(cubed_x)
     );
 
     always_comb begin
          clamp_lower = i_sample <= (-FXP_ONE);
          clamp_upper = i_sample >= (FXP_ONE);

          three_x = wide_x + wide_x + wide_x; // 3x
          non_linear_dist_wide = three_x + cubed_x; // 3x + x^3
          non_linear_dist = non_linear_dist_wide >>> 2; // non_linear_dist / 4

          if(clamp_lower) 
               output_sample = -FXP_CLAMED_VALUE;
          else if(clamp_upper) 
               output_sample =  FXP_CLAMED_VALUE;
          else
               output_sample =  non_linear_dist;
     end

     assign o_sample = output_sample;

endmodule
