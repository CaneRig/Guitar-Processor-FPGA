module fir_filter_zexpansion #(
     parameter fxp_size  = 16,
               frac_size = 12,
               window_size = 16,
               window_zero_expand = 0
) (
     input clk, 
     input rst,

     input     [window_size - 1:   0]                  [fxp_size - 1:    0] i_ir,
     
     input     [fxp_size - 1   :   0] i_data,
     input                            i_valid,

     output    [window_size+window_zero_expand-1: 0]   [fxp_size - 1:      0] o_data,
     output                           o_valid
);

localparam zeroes = (window_zero_expand * fxp_size)'(0);
/// wire declaration 
     wire                                              parallel_valid;
     wire [window_size - 1:   0][fxp_size - 1:    0]   sample_bus;

     wire                                              convolution_valid;
     wire [window_size - 1:   0][fxp_size - 1:    0]   convolved_bus;

/// module instatiation
     serial_to_parallel #(
          .XLEN(fxp_size),
          .WIDTH(window_size)
     ) ins_parallelizer (
          .clk(clk),
          .rst(rst),

          .serial_valid(i_valid),
          .serial_data(i_data),

          .parallel_valid(parallel_valid),
          .parallel_data(sample_bus)
     );

     circular_convolution #(
          .QLEN(fxp_size),
          .FRAC_SIZE(frac_size),
          .WINDOW_SIZE(window_size + fxp_size)
     ) ins_convolver (
          .clk(clk),
          .rst(rst),

          .weights({i_ir, zeroes}),

          .in_valid(serial_valid),
          .in_data({sample_bus, zeroes}),

          .out_valid(convolution_valid),
          .out_data(convolved_bus)
     );

     assign o_data = convolved_bus;

     
endmodule