`timescale 10s/1s
`include "util.svh"

// TEST gain
module tb_gain();
// settings
     localparam bits_per_level = 12;
     localparam fxp_size = 16;
     localparam max_level = 1 << bits_per_level;

     localparam error_threshold = 4.0 / real'(max_level) ;

// wires
     logic signed[15: 0] gain_argument;
     logic signed[15: 0] sample_argument;
     int signed gain_mulOut;
     real temp;

     real expected;
     real error   ;
     real fx_mo   ;
     int  fp_exp  ;

     gain#(
          .bits_per_level(bits_per_level),
          .fxp_size(fxp_size)
     ) dut (
          .i_sample( sample_argument  ),
          .i_gain  ( gain_argument  ), 
          .o_sample( gain_mulOut)
     );

// test inputs
     task test_particular(input real gain, input real sample);
          expected = gain * sample;
          error    = 0;
          fx_mo    = fx2fp(gain_mulOut, bits_per_level);
          fp_exp   = fp2fx(expected, bits_per_level);

          #1;
          gain_argument <= fp2fx(gain, bits_per_level);
          sample_argument <= fp2fx(sample, bits_per_level);
          #1;
          error = fx2fp(gain_mulOut, bits_per_level) - expected;
          #2;

          if(abs(error) >= error_threshold) begin
               $error("\nGain error=%f: gain=%f, sample=%f, ans=%f, exp=%f;\n\t fx_gain=%d, fx_sample=%d, ans=%d, exp=%d\n\n", error, 
                         gain, sample, fx_mo, expected, 
                         gain_argument, sample_argument, gain_mulOut, fp_exp);
               
               $display("[TEST FAILED]");
               $finish();
          end

     endtask

// arguments
real A, B;
// initial test
     initial begin // gain
          $display("gain - test");
          $dumpfile("test-gain.vcd");
          $dumpvars;

          #1;
          for (int i=0; i<10000; ++i) begin
               B = real'($urandom()) / real'(2**31) - 1.0;
               A = real'($urandom()) / real'(2**30);
               
               #1;

               test_particular(A, B);
          end
          #10;

          $display("[TEST PASSED]");
          $finish();
     end
endmodule