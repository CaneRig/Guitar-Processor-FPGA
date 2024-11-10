module distortion #(
     parameter bits_per_level = 12
)(
     input shortint signed in_signal,
     input shortint signed gain,
     output shortint signed out_signal
);

int signed signal, clamped_signal;
multiply m_gain#(bits_per_level)(.a(in_signal), .b(gain), .res(signal));

distortion_clamp m_clamp#(bits_per_level)(.x(signal), .out(clamped_signal));

assign out_signal = shortint'(clamped_signal);
     
endmodule