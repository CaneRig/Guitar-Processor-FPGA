// ADC_driver.v

// Generated using ACDS version 21.1 850

`timescale 1 ps / 1 ps
module ADC_driver (
		input  wire        adc_pll_clock_clk,       //  adc_pll_clock.clk
		input  wire        adc_pll_locked_export,   // adc_pll_locked.export
		input  wire        clock_clk,               //          clock.clk
		input  wire        reset_sink_reset_n,      //     reset_sink.reset_n
		output wire        response_valid,          //       response.valid
		output wire        response_startofpacket,  //               .startofpacket
		output wire        response_endofpacket,    //               .endofpacket
		output wire [0:0]  response_empty,          //               .empty
		output wire [4:0]  response_channel,        //               .channel
		output wire [11:0] response_data,           //               .data
		input  wire        sequencer_csr_address,   //  sequencer_csr.address
		input  wire        sequencer_csr_read,      //               .read
		input  wire        sequencer_csr_write,     //               .write
		input  wire [31:0] sequencer_csr_writedata, //               .writedata
		output wire [31:0] sequencer_csr_readdata   //               .readdata
	);

	ADC_driver_modular_adc_0 #(
		.is_this_first_or_second_adc (1)
	) modular_adc_0 (
		.clock_clk               (clock_clk),               //          clock.clk
		.reset_sink_reset_n      (reset_sink_reset_n),      //     reset_sink.reset_n
		.adc_pll_clock_clk       (adc_pll_clock_clk),       //  adc_pll_clock.clk
		.adc_pll_locked_export   (adc_pll_locked_export),   // adc_pll_locked.export
		.sequencer_csr_address   (sequencer_csr_address),   //  sequencer_csr.address
		.sequencer_csr_read      (sequencer_csr_read),      //               .read
		.sequencer_csr_write     (sequencer_csr_write),     //               .write
		.sequencer_csr_writedata (sequencer_csr_writedata), //               .writedata
		.sequencer_csr_readdata  (sequencer_csr_readdata),  //               .readdata
		.response_valid          (response_valid),          //       response.valid
		.response_startofpacket  (response_startofpacket),  //               .startofpacket
		.response_endofpacket    (response_endofpacket),    //               .endofpacket
		.response_empty          (response_empty),          //               .empty
		.response_channel        (response_channel),        //               .channel
		.response_data           (response_data)            //               .data
	);

endmodule
