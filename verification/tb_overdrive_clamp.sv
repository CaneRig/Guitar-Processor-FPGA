`timescale 1ns/1ps
`include "util.svh"

function real oclamp(real real_input);
     if (real_input < -1.0) begin
          return -0.5;
     end else if (real_input > 1.0) begin
          return 0.5;
     end else begin
          return (3 * real_input + real_input ** 3) / 4;
     end
endfunction

module overdrive_clamp_tb();

     // Parameters
     parameter bits_per_level = 12;
     parameter fxp_size = 16;
     
     localparam error_threshold = 0.01;

     // Signals
     logic signed[fxp_size-1:0] i_sample;
     logic signed[fxp_size-1:0] o_sample;

     // Varriables
     real real_input;
     real real_output;
     real expected_output;
     int signed fixed_input;
     int signed fixed_output;
     logic fail;

     overdrive_clamp #(
          .bits_per_level(bits_per_level),
          .fxp_size(fxp_size)
     ) dut (
          .i_sample(i_sample),
          .o_sample(o_sample)
     );

     initial begin
          $display("overdrive_clamp - test");
          $dumpfile("overdrive-clamp.vcd");
          $dumpvars;

          fail = '0;

          for (real_input = -2.0; real_input <= 2.0; real_input += 0.1) begin
               fixed_input = fp2fx(real_input, bits_per_level);
               i_sample = fixed_input;

               #1;

               fixed_output = o_sample;
               real_output = fx2fp(fixed_output, bits_per_level);

               expected_output = oclamp(real_input);

               #1;

               if (abs(real_output - expected_output) >= error_threshold) begin
                    $display("Error: Input = %f | %d, Output = %f, Expected = %f", real_input, fixed_input, real_output, expected_output);
                    fail = '1;
               end
          end

          if(fail)
               $display("[TEST FAILED]");
          else
               $display("[TEST PASSED]");
          $finish;
     end

endmodule