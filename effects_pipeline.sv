module effects_pipline #(
     parameter bits_per_level = 12
) (
     input clk, 
	  input  [10: 0] gain_value,
     input  [15: 0] sample, // to 12 bits
     output [15: 0] out_sample
);

/// GATE 1
     wire [15: 0] gate1_value;
     flipflop#(
     .size = 16
) i_ff_in(
          .clk(clk),
          .data(sample),
          .out(gate1_value)
     );
     shortint signed distortion_in, gain, out;

     assign distortion_in = shortint'(gate1_value);
     assign gain = shortint'(gain_value);

     wire [15: 0] gate2_in;

     distortion #(bits_per_level)
	     m_distr(distortion_in, gain, gate2_in);



/// GATE 2
     wire [15: 0] gate2_value;
     flipflop#(
     .size = 16
) gate2(
          .clk(clk),
          .data(gate2_in),
          .out(gate2_value)
     );
	  

     assign out_sample = gate2_value;
     
endmodule