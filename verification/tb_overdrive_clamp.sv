`timescale 10s/1s

// TEST overdrive_clamp
function int multiply(int a, int b);
     multiply = a * b / (2**12);
endfunction

function int overdrive_clamp_test(int value);
     localparam One = 2**12;

     if (value <= - One)
          overdrive_clamp_test = - One / 2;
     else if (value >= One)
          overdrive_clamp_test =   One / 2;
     else
          overdrive_clamp_test = (multiply(multiply(value, value), value) + value * 3) / 4;
endfunction

module tb_overdrive_clamp();

int overdrive_clamp_input;
int overdrive_clamp_output;
int overdrive_clamp_expected;

overdrive_clamp m_overdrive_clamp(.x(overdrive_clamp_input), .out(overdrive_clamp_output));

initial begin
     $display("overdrive_clamp - test");
     $dumpfile("test-overdrive_clamp.vcd");
     $dumpvars(0, overdrive_clamp_input);
     $dumpvars(0, overdrive_clamp_output);
     $dumpvars(0, overdrive_clamp_expected);

     for (integer i = -(2**16); i < (2**16); i+=2) begin
          overdrive_clamp_input = i;
          overdrive_clamp_expected = overdrive_clamp_test(i);
          #1;
          if(overdrive_clamp_output != overdrive_clamp_expected) begin
               $error("Error: wrong overdrive clamp error at %d: \n Expected:\t%d\n Found:\t%d\n", i, overdrive_clamp_expected, overdrive_clamp_output);
               $finish();
          end
          #1;
     end
     $finish();
end

endmodule
