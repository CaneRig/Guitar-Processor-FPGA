`timescale 1ps/1ps

module dut();

     initial $dumpvars;

     localparam FXP_SIZE = 16;
	localparam FXP_FRAC = 12;
     localparam cutoff_freq = 10000.0 ;// Частота среза 10 кГц
     localparam sample_rate = 44100   ;// Частота дискретизации (стандартная для аудио)
     localparam order = 4             ;// Порядок фильтра (выше порядок = круче срез)


     logic clk;
     logic i_valid;
     logic o_valid;
     logic rst = '0;
     logic[FXP_SIZE-1: 0] in_sample;
     logic[FXP_SIZE-1: 0] out_sample;

     preprocess_hipass dut(
          .clk(clk),
          .rst(rst),
          .i_valid(i_valid),
          .o_valid(o_valid),
          .i_sample(in_sample),
          .o_sample(out_sample)
     );

     

endmodule