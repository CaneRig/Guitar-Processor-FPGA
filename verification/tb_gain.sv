`timescale 10s/1s

// TEST gain
module tb_gain();
int signed gain_mulA, gain_mulB;
int signed gain_mulOut;
int signed gain_expected;

gain m_gain_mul(gain_mulA, gain_mulB, gain_mulOut) ;

function int abs(input int a);
     if(a < 0)
          return -a;
     else 
          return a;
endfunction

initial begin // gain
     $display("gain - test");
     $dumpfile("test-gain.vcd");
     $dumpvars;

     for (integer signed i=-(2**14+1); i<(2**14); i+=2**7) begin
          for (integer j=0; j<2**14; j+=2**7) begin
               #1
               gain_mulA = $signed(i);
               gain_mulB = $signed(j);
               #1
               gain_expected = ($signed(i*j) / (2**12));
               if(abs(gain_expected - gain_mulOut) > 2) begin
                    $error("The gain, probably, not working (warning, currently there is error +/- 1 in checking the correctiness)");
                    $display("\nA=%d, B=%d, Answer = %d\ni=%d, j=%d, gain_expected = %d", gain_mulA, gain_mulB, gain_mulOut, i, j, gain_expected);
                    $finish;
               end
          end
     end
     #10

     $finish();
end
endmodule