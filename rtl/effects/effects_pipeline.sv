module effects_pipeline #(
     parameter bits_per_level = 12,
               bits_per_gain_frac = 4  // fractional part of input gain
) (
     input clk,
     input rst,

     // effects parameters 
	input  [10: 0] i_par_gain,    // bits_per_gain_frac bits for fraction part, 10 - bits_per_gain_frac bits for integer part


     input          valid,
     input  [11: 0] i_sample,
     output [15: 0] o_sample
);

// Extend i_sample from 12 bit to 16
     wire [15   :0   ]   sample_in_extended;
     signed_expand#(
          .operand_size(12),
          .expansion_size(16-12)
     ) i_in_sexpand (
          .in(i_sample),
          .out(sample_in_extended)
     );

// Overdrive
     logic [15  :0   ]   overdrive_in;

     flipflop#(
          .size(16)
     ) ins_overdrive_ff (
          .clk(clk),
          .rst(rst),
          .valid(valid),
          .data(sample_in_extended),
          .out(overdrive_in)
     );

     wire [31  :0   ] overdrive_out;
     wire [15  :0   ] ovrd_gain;

     assign ovrd_gain = {'0, i_par_gain};

     overdrive #(
          .bits_per_level(bits_per_level),
          .bits_per_gain_frac(bits_per_gain_frac)
     ) ins_ovrd (
          .clk(clk),
          .i_sample(overdrive_in),
          .i_gain(ovrd_gain),
          .o_sample(overdrive_out)
     );
     //assign overdrive_out = overdrive_in;

// Output
     flipflop#(
          .size(16)
     ) ins_output_ff (
          .clk(clk),
          .rst(rst),
          .valid(valid),
          .data(overdrive_out[15: 0]),
          .out(o_sample)
     );
     
endmodule