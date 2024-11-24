`timescale 10s/1s

// TEST distortion_clamp
function int multiply(int a, int b);
     multiply = a * b / (2**12);
endfunction

function int distortion_clamp_test(int value);
     localparam One = 2**12;

     if (value <= - One)
          distortion_clamp_test = - One / 2;
     else if (value >= One)
          distortion_clamp_test =   One / 2;
     else
          distortion_clamp_test = (multiply(multiply(value, value), value) + value * 3) / 4;
endfunction

module tb_distortion_clamp();

int distortion_clamp_input;
int distortion_clamp_output;
int distortion_clamp_expected;

distortion_clamp m_distortion_clamp(.x(distortion_clamp_input), .out(distortion_clamp_output));

initial begin
     $display("distortion_clamp - test");
     $dumpfile("test-distortion_clamp.vcd");
     $dumpvars(0, distortion_clamp_input);
     $dumpvars(0, distortion_clamp_output);
     $dumpvars(0, distortion_clamp_expected);

     for (int i = -int'(2**16); i < int'(2**16); i+=2) begin
          distortion_clamp_input = i;
          distortion_clamp_expected = distortion_clamp_test(i);
          #1;
          if(distortion_clamp_output != distortion_clamp_expected) begin
               $error("Error: wrong distortion clamp error at %d: \n Expected:\t%d\n Found:\t%d\n", i, distortion_clamp_expected, distortion_clamp_output);
               $finish();
          end
          #1;
     end
     $finish();
end

endmodule
