module effects_pipline #(
     parameter bits_per_level = 12,
               bits_per_gain_frac = 4  // fractional part of input gain
) (
     input clk,
     input rst,

     // effects parameters 
	  input  [10: 0] gain_value,    // bits_per_gain_frac bits for fraction part, 10 - bits_per_gain_frac bits for integer part


     input          valid,
     input  [12: 0] sample_in,
     output [15: 0] sample_out
);

// Overdrive
     logic [15  :0   ]   overdrive_in;

     flipflop#(
          .size(16)
     ) i_overdrive_ff (
          .clk(clk),
          .rst(rst),
          .valid(valid),
          .data(sample_in),
          .out(overdrive_in)
     );

     shortint signed ss_ovrd_in, ss_gain;

     assign ss_ovrd_in   = shortint'(overdrive_in);
     assign ss_gain      = shortint'(gain_value);

     wire [15  :0   ] overdrive_out;
     wire [15  :0   ] overdrive_out_silent;
     overdrive #(
          .bits_per_level(bits_per_level),
          .bits_per_gain_frac(bits_per_gain_frac)
     ) i_ovrd (
          .signal_in(ss_ovrd_in),
          .gain(ss_gain),
          .signal_out(overdrive_out)
     );
     //assign overdrive_out = overdrive_in;

// Output
     flipflop#(
          .size(16)
     ) i_output_ff (
          .clk(clk),
          .rst(rst),
          .valid(valid),
          .data(overdrive_out),
          .out(sample_out)
     );
     
endmodule