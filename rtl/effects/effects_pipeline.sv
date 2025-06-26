module effects_pipeline #(
     parameter bits_per_level 	 = 12,
               bits_per_gain_frac = 4,  // fractional part of input gain
               fxp_size				 = 16
) (
     input clk,
     input rst,

     // effects parameters 
     input  [10: 0] i_par_gain,    // bits_per_gain_frac bits for fraction part, 10 - bits_per_gain_frac bits for integer part


     input          					  valid,
     input  [bits_per_level-1	: 0] i_sample,
     output [fxp_size-1			: 0] o_sample
);

// Extend i_sample from 12 bit to 16
     wire [fxp_size-1   :0   ]   sample_in_extended;
     signed_expand#(
          .operand_size(bits_per_level),
          .expansion_size(fxp_size-bits_per_level)
     ) i_in_sexpand (
          .in(i_sample),
          .out(sample_in_extended)
     );

// Overdrive
     logic [fxp_size-1  :0   ]   overdrive_in;

     flipflop#(
          .size(fxp_size)
     ) ins_overdrive_ff (
          .clk		(clk),
          .rst		(rst),
          .valid	(valid),
          .i_data	(sample_in_extended),
          .o_data	(overdrive_in)
     );

     wire [fxp_size*2-1  :0   ] overdrive_out;
     wire [fxp_size - 1  :0   ] ovrd_gain;

     assign ovrd_gain = {'0, i_par_gain};

     overdrive #(
          .bits_per_level(bits_per_level),
          .bits_per_gain_frac(bits_per_gain_frac),
          .fxp_size(fxp_size)
     ) ins_ovrd (
          .clk(clk),
          .rst(rst),
          
          .i_sample(overdrive_in),
          .i_gain(ovrd_gain),
          .o_sample(overdrive_out)
     );
     //assign overdrive_out = overdrive_in;

// Output
     flipflop#(
          .size(fxp_size)
     ) ins_output_ff (
          .clk(clk),
          .rst(rst),
          .valid(valid),
          .i_data(overdrive_out[fxp_size-1: 0]),
          .o_data(o_sample)
     );
     
endmodule