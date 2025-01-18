module overdrive #(
     parameter bits_per_level = 12,
               bits_per_gain_frac = 4
)(
     input logic[15: 0] signal_in,
     input logic[15: 0] gain,
     output logic[31:0] signal_out
);
     
     logic[31: 0] ss_signal;
     logic[31: 0] ss_clamped_signal;
     gain #(
          .bits_per_level(bits_per_gain_frac)
     ) i_gain (
          .x(signal_in), 
          .gain_value(gain), 
          .res(ss_signal)
     );
     
     overdrive_clamp #(
               bits_per_level
          ) i_clamp (
               .x(ss_signal), 
               .out(ss_clamped_signal)
          );
     
     assign signal_out = (ss_clamped_signal) / 2;
	//  assign signal_out = shortint'(ss_signal);
	//    assign signal_out = shortint'(signal_in);
     
endmodule 
