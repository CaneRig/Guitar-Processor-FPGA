module comb_ir #(
     parameter fxp_size  = 16,
               frac_size = 12,
               window_size = 256
) (
     input clk, 
     input rst,

     input     [fxp_size - 1   :   0] i_data,
     input                            i_valid,

     output    [fxp_size - 1:      0] o_data,
     output                           o_valid
);
/// wires
     wire  [window_size - 1:  0][fxp_size - 1:    0] ir_bus;
     wire  [window_size - 1:  0][fxp_size - 1:    0] convolved;
     wire  valid_conv;
     
     wire [window_size - 1:  0][fxp_size - 1:    0] overlay;

     logic [window_size*2-1:  0][fxp_size - 1:    0] feedback_reg;


/// load ir
     ir_weights#(
          .test_vector_len(window_size),
          .test_word_width(fxp_size)
     ) ins_weights (
          .weights(ir_bus)
     );

/// convolve
     fir_filter_zexpansion #(
          .fxp_size(fxp_size),
          .frac_size(frac_size),
          .window_size(window_size),
          .window_zero_expand(window_size)
     ) ins_fir (
          .clk(clk),
          .rst(rst),

          .i_ir(ir_bus),

          .i_data(i_data),
          .i_valid(i_valid),

          .o_data(convolved),
          .o_valid(valid_conv)
     );

/// overlay
     always_comb begin
          for (int i = 0; i < window_size; i+=1) begin
               overlay[i] = convolved[i + window_size] + feedback_reg[i];
          end
     end


/// feedback reg

     always_ff @(posedge ck) begin
          if(rst) begin
               feedback_reg <= '0;
          end else if (valid_conv) begin
               // TODO: VERIFY BIT ORDER IN FEEDBACK AND OVERLAY
               feedback_reg <= {overlay, convolved[window_size - 1:     0]};
          end
     end

     assign o_data = feedback_reg[0];

endmodule