module distortion #(
     parameter bits_per_level = 12
)(
     input shortint signed in_signal,
     input shortint signed gain,
     output shortint signed out_signal
);

int signed signal, clamped_signal;
gain #(bits_per_level)
     m_gain(.a(in_signal), .b(gain), .res(signal));

distortion_clamp #(bits_per_level)
     m_clamp(.x(signal), .out(clamped_signal));

assign out_signal = shortint'(clamped_signal);
     
endmodule 
