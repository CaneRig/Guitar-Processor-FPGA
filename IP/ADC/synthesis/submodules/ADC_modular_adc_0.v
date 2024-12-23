// ADC_modular_adc_0.v

// This file was auto-generated from altera_modular_adc_hw.tcl.  If you edit it your changes
// will probably be lost.
// 
// Generated using ACDS version 21.1 850

`timescale 1 ps / 1 ps
module ADC_modular_adc_0 #(
		parameter is_this_first_or_second_adc = 1
	) (
		input  wire        clock_clk,              //          clock.clk
		input  wire        reset_sink_reset_n,     //     reset_sink.reset_n
		input  wire        adc_pll_clock_clk,      //  adc_pll_clock.clk
		input  wire        adc_pll_locked_export,  // adc_pll_locked.export
		input  wire        command_valid,          //        command.valid
		input  wire [4:0]  command_channel,        //               .channel
		input  wire        command_startofpacket,  //               .startofpacket
		input  wire        command_endofpacket,    //               .endofpacket
		output wire        command_ready,          //               .ready
		output wire        response_valid,         //       response.valid
		output wire [4:0]  response_channel,       //               .channel
		output wire [11:0] response_data,          //               .data
		output wire        response_startofpacket, //               .startofpacket
		output wire        response_endofpacket    //               .endofpacket
	);

	generate
		// If any of the display statements (or deliberately broken
		// instantiations) within this generate block triggers then this module
		// has been instantiated this module with a set of parameters different
		// from those it was generated for.  This will usually result in a
		// non-functioning system.
		if (is_this_first_or_second_adc != 1)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					is_this_first_or_second_adc_check ( .error(1'b1) );
		end
	endgenerate

	altera_modular_adc_control #(
		.clkdiv                          (2),
		.tsclkdiv                        (1),
		.tsclksel                        (1),
		.hard_pwd                        (0),
		.prescalar                       (0),
		.refsel                          (0),
		.device_partname_fivechar_prefix ("10M50"),
		.is_this_first_or_second_adc     (1),
		.analog_input_pin_mask           (1),
		.dual_adc_mode                   (0),
		.enable_usr_sim                  (0),
		.reference_voltage_sim           (49648),
		.simfilename_ch0                 (""),
		.simfilename_ch1                 (""),
		.simfilename_ch2                 (""),
		.simfilename_ch3                 (""),
		.simfilename_ch4                 (""),
		.simfilename_ch5                 (""),
		.simfilename_ch6                 (""),
		.simfilename_ch7                 (""),
		.simfilename_ch8                 (""),
		.simfilename_ch9                 (""),
		.simfilename_ch10                (""),
		.simfilename_ch11                (""),
		.simfilename_ch12                (""),
		.simfilename_ch13                (""),
		.simfilename_ch14                (""),
		.simfilename_ch15                (""),
		.simfilename_ch16                ("")
	) control_internal (
		.clk               (clock_clk),              //         clock.clk
		.cmd_valid         (command_valid),          //       command.valid
		.cmd_channel       (command_channel),        //              .channel
		.cmd_sop           (command_startofpacket),  //              .startofpacket
		.cmd_eop           (command_endofpacket),    //              .endofpacket
		.cmd_ready         (command_ready),          //              .ready
		.rst_n             (reset_sink_reset_n),     //    reset_sink.reset_n
		.rsp_valid         (response_valid),         //      response.valid
		.rsp_channel       (response_channel),       //              .channel
		.rsp_data          (response_data),          //              .data
		.rsp_sop           (response_startofpacket), //              .startofpacket
		.rsp_eop           (response_endofpacket),   //              .endofpacket
		.clk_in_pll_c0     (adc_pll_clock_clk),      // adc_pll_clock.clk
		.clk_in_pll_locked (adc_pll_locked_export),  //   conduit_end.export
		.sync_valid        (),                       //   (terminated)
		.sync_ready        (1'b0)                    //   (terminated)
	);

endmodule
