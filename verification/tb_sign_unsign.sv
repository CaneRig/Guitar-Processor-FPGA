`timescale 1ps/1ps
`include "util.svh"

module tb_sign_unsign();

     parameter XLEN = 16;
     localparam w_half_XLEN = 2 ** XLEN / 2;

     // input 
     logic          [XLEN-1: 0]  u2s_input;     
     wire signed    [XLEN-1: 0]  u2s_output;

     logic signed   [XLEN-1: 0]  s2u_input;     
     wire           [XLEN-1: 0]  s2u_output;
     logic fail;

     // module instantiation
     sign2unsign#(
          .size(XLEN)
     ) dut_s2u (
          .in(s2u_input),
          .out(s2u_output)
     );
     unsign2sign#(
          .size(XLEN)
     ) dut_u2s (
          .in(u2s_input),
          .out(u2s_output)
     );

     // subtests
     function logic invertion_test(); // s2u(u2s(x)) = x and u2s(s2u(x)) = x
          $display("\tInvertion subtest[stage 1]");

          for (int i = 0; i < 2**16; i++) begin
               #1;
               u2s_input = i[XLEN-1: 0];
               #1;
               s2u_input = u2s_output;
               #1;
               if(u2s_input != s2u_output) begin
                    $display("Error, invertion test fail, s2u(u2s(x)) != x: \n u2s_input=%d, u2s_output=%d, \ts2u_input=%d, s2u_output=%d\n", 
                              u2s_input, u2s_output, s2u_input, s2u_output);
                    return 0;
               end
          end

          $display("\tInvertion subtest[stage 2]");
          for (int i = 0; i < 2**16; i++) begin
               #1;
               s2u_input = i[XLEN-1: 0];
               #1;
               u2s_input = s2u_output;
               #1;
               if(s2u_input != u2s_output) begin
                    $display("Error, invertion test fail, s2u(u2s(x)) != x: \n s2u_input=%d, s2u_output=%d\tu2s_input=%d, u2s_output=%d\n", 
                              s2u_input, s2u_output, u2s_input, u2s_output);
                    return 0;
               end
          end
          return 1;

     endfunction

     function logic comparison_test();
          logic failure;

          failure = '0;
          for (int i = 0; i < 2**16; i++) begin
               #1;
               u2s_input = i[XLEN-1: 0];
               s2u_input = i[XLEN-1: 0];
               #1;
               if(u2s_output != $signed(i[XLEN-1: 0]) - w_half_XLEN) begin
                    $display("Error, comparison test fail, u2s(x) != x - half: u2s_input=%d, u2s_output=%d, \texpected=%d, stage=%d\n", u2s_input, u2s_output, $signed(i[XLEN-1: 0]) - w_half_XLEN, i);
                    failure = '1;
               end
               if(s2u_output != $signed(i[XLEN-1: 0]) + w_half_XLEN) begin
                    $display("Error, comparison test fail, s2u(x) != x + half: s2u_input=%d, s2u_output=%d, \texpected=%d, stage=%d\n", s2u_input, s2u_output, $signed(i[XLEN-1: 0]) + w_half_XLEN, i);
                    failure = '1;
               end
          end
          return failure;
     endfunction

     initial begin
          $display("sign/unsign - test");
          $dumpfile("test-sign_unsign.vcd");
          $dumpvars;

          $display("Invertion test");
          fail = invertion_test();

          $display("Comparison test");
          fail = fail | comparison_test();
          
          
          if (fail == 1) begin
               $display("[TEST FAILED]");
          end
          else begin
               $display("[TEST PASSED]");
          end
     
          $finish;
     end


endmodule