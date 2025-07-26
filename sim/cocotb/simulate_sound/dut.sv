`timescale 1ps/1ps

module dut();

     initial $dumpvars;

     parameter bits_per_level 	     = 12,
               bits_per_gain_frac       = 4,  // fractional part of input gain
               fxp_size				= 16;

     logic clk;
     logic rst = '0;

     logic  [10: 0] gain;

     logic [fxp_size-1        : 0] in_sample;
     logic [fxp_size-1		: 0] out_sample;

     logic i_valid;
     logic o_valid;


     effects_pipeline #(
          .bits_per_level(bits_per_level),
          .bits_per_gain_frac(bits_per_gain_frac),
          .fxp_size(fxp_size)
     ) ins_dut (
          .clk(clk),
          .rst(rst),
          .i_par_gain(gain),
          .i_valid(i_valid),
          .o_valid(o_valid),

          .i_sample(in_sample),
          .o_sample(out_sample)
     );


endmodule