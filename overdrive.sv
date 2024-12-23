module overdrive #(
     parameter bits_per_level = 12
)(
     input shortint signed signal_in,
     input shortint signed gain,
     output shortint signed signal_out
);
     
     int signed ss_signal, ss_clamped_signal;
     gain #(bits_per_level)
          m_gain(.a(signal_in), .b(gain), .res(ss_signal));
     
     overdrive_clamp #(bits_per_level)
          m_clamp(.x(ss_signal), .out(ss_clamped_signal));
     
     assign signal_out = shortint'(ss_clamped_signal);
     
endmodule 
