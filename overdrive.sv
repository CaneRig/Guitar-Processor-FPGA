module overdrive #(
     parameter bits_per_level = 12,
               bits_per_gain_frac = 4
)(
     input shortint signed signal_in,
     input shortint signed gain,
     output int signed signal_out
);
     
     int signed ss_signal, ss_clamped_signal;
     gain #(
          .bits_per_level(bits_per_gain_frac)
     ) i_gain (
          .a(signal_in), 
          .b(gain), 
          .res(ss_signal)
     );
     
     overdrive_clamp #(
               bits_per_level
          ) i_clamp (
               .x(ss_signal), 
               .out(ss_clamped_signal)
          );
     
     assign signal_out = shortint'(ss_clamped_signal);
	//  assign signal_out = shortint'(ss_signal);
	//    assign signal_out = shortint'(signal_in);
     
endmodule 
