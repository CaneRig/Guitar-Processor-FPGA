module effects_pipline #(
     parameter its_per_level = 12
) (
     input clk, 
     input logic [15: 0] sample,
     output logic[15: 0] out_sample
);

/// GATE 1
     wire [15: 0] gate1_value;
     latch16 gate1(
          .clk(clk),
          .data(sample),
          .out_signal(gate1_value)
     );
     shortint signed in, gain, out;

     assign distortion_in = shortint'(gate1_value);
     assign gain = shortint'(gain_value);

     wire [15: 0] gate2_in;

     distortion #(bits_per_level)
	     m_distr(distortion_in, gain, gate2_in);



/// GATE 2
     wire [15: 0] gate2_value;
     latch16 gate2(
          .clk(clk),
          .data(gate2_value),
          .out_signal(gate2_value)
     );

     assign out_signal = gate2_value;
     
endmodule