	ADC_driver u0 (
		.adc_pll_clock_clk       (<connected-to-adc_pll_clock_clk>),       //  adc_pll_clock.clk
		.adc_pll_locked_export   (<connected-to-adc_pll_locked_export>),   // adc_pll_locked.export
		.clock_clk               (<connected-to-clock_clk>),               //          clock.clk
		.reset_sink_reset_n      (<connected-to-reset_sink_reset_n>),      //     reset_sink.reset_n
		.response_valid          (<connected-to-response_valid>),          //       response.valid
		.response_startofpacket  (<connected-to-response_startofpacket>),  //               .startofpacket
		.response_endofpacket    (<connected-to-response_endofpacket>),    //               .endofpacket
		.response_empty          (<connected-to-response_empty>),          //               .empty
		.response_channel        (<connected-to-response_channel>),        //               .channel
		.response_data           (<connected-to-response_data>),           //               .data
		.sequencer_csr_address   (<connected-to-sequencer_csr_address>),   //  sequencer_csr.address
		.sequencer_csr_read      (<connected-to-sequencer_csr_read>),      //               .read
		.sequencer_csr_write     (<connected-to-sequencer_csr_write>),     //               .write
		.sequencer_csr_writedata (<connected-to-sequencer_csr_writedata>), //               .writedata
		.sequencer_csr_readdata  (<connected-to-sequencer_csr_readdata>)   //               .readdata
	);

