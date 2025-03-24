`timescale 1ps/1ps

`include "util.svh"

module signed_expand_tb;

     // Parameters
     parameter operand_size   = 12;
     parameter expansion_size = 4;

     // Signals
     reg  [operand_size-1: 0]                   in;
     wire [operand_size+expansion_size-1: 0]    out;
     logic [operand_size-1:0] test_value;
     logic fail;

     // Instantiate the module under test
     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(expansion_size)
     ) dut (
          .in(in),
          .out(out)
     );

     // Testbench logic
     initial begin
          $display("signed_expand - test");
          $dumpfile("signed_expand.vcd");
          $dumpvars;

          fail = '0;
          // Loop through a range of values to test the sign extension
          for (int i = 0; i < (1 << operand_size); i = i + 1) begin
               test_value = i;
               in = test_value;

               #1;
     
               if (out !== { {expansion_size{test_value[operand_size-1]}}, test_value}) begin
                    $display("\nError: Expected %b, Got %b", { {expansion_size{test_value[operand_size-1]}}, test_value}, out);
                    fail = '1;
                    // $finish;
               end
          end

          // Test some edge cases
          in = {operand_size{1'b0}}; // All zeros
          #1;
          if(out !== (operand_size+expansion_size)'(0)) begin
               $display("\nError: (S1) Expected %b, Got %b", (operand_size+expansion_size)'(0), out);
               fail = '1;
          end

          in = {operand_size{1'b1}}; // All ones
          #1;
          if(out !== ~(operand_size+expansion_size)'(0)) begin
               $display("\nError: (S0) Expected %b, Got %b", ~(operand_size+expansion_size)'(0), out);
               fail = '1;
          end
     
          #1;

          if(fail == '1)
               $display("[TEST FAILED]");
          else
               $display("[TEST PASSED]");
          $finish;
     end

endmodule