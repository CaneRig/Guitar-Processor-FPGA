
module ADC_driver (
	adc_pll_clock_clk,
	adc_pll_locked_export,
	clock_clk,
	reset_sink_reset_n,
	response_valid,
	response_startofpacket,
	response_endofpacket,
	response_empty,
	response_channel,
	response_data,
	sequencer_csr_address,
	sequencer_csr_read,
	sequencer_csr_write,
	sequencer_csr_writedata,
	sequencer_csr_readdata);	

	input		adc_pll_clock_clk;
	input		adc_pll_locked_export;
	input		clock_clk;
	input		reset_sink_reset_n;
	output		response_valid;
	output		response_startofpacket;
	output		response_endofpacket;
	output	[0:0]	response_empty;
	output	[4:0]	response_channel;
	output	[11:0]	response_data;
	input		sequencer_csr_address;
	input		sequencer_csr_read;
	input		sequencer_csr_write;
	input	[31:0]	sequencer_csr_writedata;
	output	[31:0]	sequencer_csr_readdata;
endmodule
