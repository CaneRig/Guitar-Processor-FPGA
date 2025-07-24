`timescale 1ps/1ps

module dut();

     initial $dumpvars;

     localparam fxp_size = 16;
     localparam fxp_frac = 12;

     logic signed [fxp_size-1:	0] i_sample;
     logic signed [fxp_size-1:	0] o_sample;

     pwl_tanh ins_dut(
          .i_x(i_sample),
          .o_res(o_sample)
     );

endmodule