`timescale 1ps/1ps

module dut();

     initial $dumpvars;

     parameter  	bits_per_level      = 12,
                    fxp_size			= 32;

     logic signed [fxp_size-1:	0] i_sample;
     logic signed [fxp_size-1:	0] o_sample;

     ovrd_piecevise_clamp #(
          .bits_per_level(bits_per_level),
          .fxp_size(fxp_size)
     ) ins_dut (
          .i_sample(i_sample),
          .o_sample(o_sample)
     );

endmodule