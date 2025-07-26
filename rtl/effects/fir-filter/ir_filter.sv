module ir_filter#(
	parameter 	bits_per_level = 12,
                    fxp_size		= 32,
                    window_size    = 64
) (
     input clk,
     input rst,

     input i_valid,
     output o_valid,

     input[fxp_size-1: 0] i_sample,
     output[fxp_size-1: 0] o_sample

);

     ir_weights ins_ir(
          .i_addr(addr_counter),
          .o_weights_re(ir_re),
          .o_weights_im(ir_im)
     );
/// 1) fft
     logic fft_valid;

     logic[fxp_size-1: 0] fft_re;
     logic[fxp_size-1: 0] fft_im;

     logic[fxp_size-1: 0] ir_re;
     logic[fxp_size-1: 0] ir_im;

     logic[fxp_size-1: 0] fft_sample;
     logic i_fft_valid;
     logic zero_epoch;
     logic[$clog2(window_size): 0] addr_counter;

     assign zero_epoch = addr_counter[$clog2(window_size)];
     assign i_fft_valid = i_valid | zero_epoch;
     assign fft_sample = zero_epoch? '0 : i_sample;


     FFT128 #(
          .WIDTH(fxp_size)
     ) ins_fft (
          .clock(clk),  //  Master Clock
          .reset(rst),  //  Active High Asynchronous Reset
          .di_en(i_valid),  //  Input Data Enable
          .di_re(fft_sample),  //  Input Data (Real)
          .di_im('0),  //  Input Data (Imag)
          .do_en(fft_valid),  //  Output Data Enable
          .do_re(fft_re),  //  Output Data (Real)
          .do_im(fft_im)   //  Output Data (Imag)
     );

/// 2) multiply with ir
     logic[fxp_size-1: 0]     mul_re;
     logic[fxp_size-1: 0]     mul_im;
     logic                    mul_valid;

     always_ff @(posedge clk) begin
          if(rst) begin 
               mul_re <= '0;
               mul_im <= '0;
               mul_valid <= '0;
               addr_counter <= '0;
          end else if(fft_valid) begin
               mul_re <= ( mul_re_next) / 7;
               mul_im <= (-mul_im_next) / 7;
               mul_valid <= '1;
               addr_counter <= addr_counter + 'd1;
          end else begin
               mul_valid <= '0;
          end
     end

     logic[fxp_size-1: 0] mul_re_next;
     logic[fxp_size-1: 0] mul_im_next;

     complex_multiplier#(
          .fractional_size(bits_per_level),
          .operand_size(fxp_size)
     ) ins_cmul (
          .i_a_real(fft_re),
          .i_a_imag(fft_im),
          .i_b_real(ir_re),
          .i_b_imag(ir_im),
          .o_res_real(mul_re_next),
          .o_res_imag(mul_im_next)
     );

/// 3) ifft
     logic ifft_valid;
     logic[fxp_size-1: 0] ifft_re;
     // logic[fxp_size-1: 0] fft_im;
     
     FFT128 #(
          .WIDTH(fxp_size)
     ) ins_ifft (
          .clock(clk),  //  Master Clock
          .reset(rst),  //  Active High Asynchronous Reset
          .di_en(mul_valid),  //  Input Data Enable
          .di_re(mul_re),  //  Input Data (Real)
          .di_im(mul_im),  //  Input Data (Imag)
          .do_en(ifft_valid),  //  Output Data Enable
          .do_re(ifft_re)  //  Output Data (Real)
          // .do_im(fft_im)   //  Output Data (Imag)
     );

/// 4) overlay
     localparam overlay_addr_width = $clog2(window_size*2);

     logic[window_size*2-1: 0][fxp_size-1: 0] buffer;
     logic[overlay_addr_width-1: 0] w_addr;
     logic[window_size-1: 0] r_addr;

     always_ff@(posedge clk) begin
          if(rst) begin
               buffer <= '0;
               w_addr <= '0;
               r_addr <= '0;
          end
          else begin
               if(ifft_valid) begin
                    if(w_addr < (overlay_addr_width/2))
                         buffer[w_addr] <= ifft_re + buffer[w_addr];
                    else
                         buffer[w_addr] <= ifft_re;
                    
                    if(w_addr == '1) begin
                         buffer[window_size-1: 0] <= buffer[window_size*2-1:0];
                         buffer[window_size*2-1:0] <= '0;
                    end

                    w_addr <= w_addr + 'd1;
                    r_addr <= r_addr + 'd1;
               end
          end
     end

     assign o_sample = buffer[r_addr];
     assign o_valid = ifft_valid;

endmodule