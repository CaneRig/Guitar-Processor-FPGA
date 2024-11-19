`timescale 10s/1s
module tesbench();

shortint signed mulA, mulB;
int mulOut;
int signed expected;

gain m_mul(mulA, mulB, mulOut) ;

initial begin // gain
     $dumpfile("test-gain.vcd");
     $dumpvars(0,mulA);
     $dumpvars(0,mulB);
     $dumpvars(0,mulOut);

     for (shortint i=-shortint'(2**16+1); i<int'(2**14); i+=2**7) begin
          for (shortint j=-shortint'(2**16+2); j<int'(2**14); j+=2**7) begin
               #1
               assign mulA = i;
               assign mulB = j;
               #1
               expected = (int'(i)*int'(j) / (2**12));
               if(mulOut !== expected && mulOut !== expected - 1) begin
                    $error("The gain, probably, not working (warning, currently there is error +/- 1 in checking the correctiness)");
                    $display("\nA=%d, B=%d, Answer = %d\ni=%d, j=%d, Expected = %d", mulA, mulB, mulOut, i, j, expected);
               end
          end
     end
     #10

     $finish();
end

endmodule