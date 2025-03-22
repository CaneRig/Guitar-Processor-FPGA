`timescale 1ps/1ps

`include "util.svh"

module signed_expand_tb;

     // Parameters
     parameter operand_size   = 12;
     parameter expansion_size = 4;

     // Signals
     reg  [operand_size-1: 0]                   in;
     wire [operand_size+expansion_size-1: 0]    out;

     // Instantiate the module under test
     signed_expand #(
          .operand_size(operand_size),
          .expansion_size(expansion_size)
     ) uut (
          .in(in),
          .out(out)
     );

     // Testbench logic
     initial begin
          logic [operand_size-1:0] test_value;
     
          // Loop through a range of values to test the sign extension
          for (int i = 0; i < (1 << operand_size); i = i + 1) begin
               test_value = i;
               in = test_value;

               #1;
     
               if (out !== { {expansion_size{test_value[operand_size-1]}}, test_value}) begin
                    $display("\nError: Expected %b, Got %b", { {expansion_size{test_value[operand_size-1]}}, test_value}, out);
                    $display("[FAIL]");
                    $finish;
               end
          end

          // Test some edge cases
          in = {operand_size{1'b0}}; // All zeros
          #1;
          if(out !== (operand_size+expansion_size)'(0)) begin
               $display("\nError: (S1) Expected %b, Got %b", (operand_size+expansion_size)'(0), out);
               $display("[FAIL]");
               $finish;
          end

          in = {operand_size{1'b1}}; // All ones
          #1;
          if(out !== ~(operand_size+expansion_size)'(0)) begin
               $display("\nError: (S0) Expected %b, Got %b", ~(operand_size+expansion_size)'(0), out);
               $display("[FAIL]");
               $finish;
          end
     
          $display("[PASSED]");
          $finish;
     end

endmodule