module topmodule# (
	parameter bits_per_level = 12
)(
	input logic[16:0] signal,
	input logic[16:0] gain_value,
	output logic[16:0] out_signal
);

shortint signed in, gain, out;

assign in = shortint'(signal);
assign gain = shortint'(gain_value);

distortion #(bits_per_level)
	m_distr(in, gain, out);

assign out_signal = out;
endmodule
