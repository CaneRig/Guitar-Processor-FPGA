`timescale 10s/1s

// TEST gain
module tb_gain();
shortint signed gain_mulA, gain_mulB;
int gain_mulOut;
int signed gain_expected;

gain m_gain_mul(gain_mulA, gain_mulB, gain_mulOut) ;


initial begin // gain
     $display("gain - test");
     $dumpfile("test-gain.vcd");
     $dumpvars(0,gain_mulA);
     $dumpvars(0,gain_mulB);
     $dumpvars(0,gain_mulOut);

     for (shortint i=-shortint'(2**16+1); i<int'(2**14); i+=2**7) begin
          for (shortint j=-shortint'(2**16+2); j<int'(2**14); j+=2**7) begin
               #1
               gain_mulA = i;
               gain_mulB = j;
               #1
               gain_expected = (int'(i)*int'(j) / (2**12));
               if(gain_mulOut !== gain_expected && gain_mulOut !== gain_expected - 1) begin
                    $error("The gain, probably, not working (warning, currently there is error +/- 1 in checking the correctiness)");
                    $display("\nA=%d, B=%d, Answer = %d\ni=%d, j=%d, gain_expected = %d", gain_mulA, gain_mulB, gain_mulOut, i, j, gain_expected);
               end
          end
     end
     #10

     $finish();
end
endmodule