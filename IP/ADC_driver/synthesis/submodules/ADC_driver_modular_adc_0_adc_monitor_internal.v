// ADC_driver_modular_adc_0_adc_monitor_internal.v

// This file was auto-generated from altera_trace_adc_monitor_hw.tcl.  If you edit it your changes
// will probably be lost.
// 
// Generated using ACDS version 21.1 850

`timescale 1 ps / 1 ps
module ADC_driver_modular_adc_0_adc_monitor_internal #(
		parameter ADC_DATA_WIDTH        = 12,
		parameter ADC_CHANNEL_WIDTH     = 5,
		parameter CAPTURE_DATA_WIDTH    = 8,
		parameter CONTROL_DATA_WIDTH    = 32,
		parameter CONTROL_ADDRESS_WIDTH = 5,
		parameter COUNT_WIDTH           = 12
	) (
		input  wire        clk_clk,                //      clk.clk
		input  wire        reset_reset,            //    reset.reset
		input  wire [4:0]  adc_data_channel,       // adc_data.channel
		input  wire [11:0] adc_data_data,          //         .data
		input  wire        adc_data_endofpacket,   //         .endofpacket
		input  wire        adc_data_startofpacket, //         .startofpacket
		input  wire        adc_data_valid          //         .valid
	);

	wire         core_capture_valid;               // core:capture_valid -> trace_endpoint:capture_valid
	wire   [7:0] core_capture_data;                // core:capture_data -> trace_endpoint:capture_data
	wire         core_capture_ready;               // trace_endpoint:capture_ready -> core:capture_ready
	wire         core_capture_startofpacket;       // core:capture_startofpacket -> trace_endpoint:capture_startofpacket
	wire         core_capture_endofpacket;         // core:capture_endofpacket -> trace_endpoint:capture_endofpacket
	wire  [31:0] trace_endpoint_control_readdata;  // core:control_readdata -> trace_endpoint:control_readdata
	wire         trace_endpoint_control_read;      // trace_endpoint:control_read -> core:control_read
	wire   [4:0] trace_endpoint_control_address;   // trace_endpoint:control_address -> core:control_address
	wire         trace_endpoint_control_write;     // trace_endpoint:control_write -> core:control_write
	wire  [31:0] trace_endpoint_control_writedata; // trace_endpoint:control_writedata -> core:control_writedata
	wire         rst_controller_reset_out_reset;   // rst_controller:reset_out -> core:reset
	wire         trace_endpoint_debug_reset_reset; // trace_endpoint:reset -> rst_controller:reset_in0

	generate
		// If any of the display statements (or deliberately broken
		// instantiations) within this generate block triggers then this module
		// has been instantiated this module with a set of parameters different
		// from those it was generated for.  This will usually result in a
		// non-functioning system.
		if (ADC_DATA_WIDTH != 12)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					adc_data_width_check ( .error(1'b1) );
		end
		if (ADC_CHANNEL_WIDTH != 5)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					adc_channel_width_check ( .error(1'b1) );
		end
		if (CAPTURE_DATA_WIDTH != 8)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					capture_data_width_check ( .error(1'b1) );
		end
		if (CONTROL_DATA_WIDTH != 32)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					control_data_width_check ( .error(1'b1) );
		end
		if (CONTROL_ADDRESS_WIDTH != 5)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					control_address_width_check ( .error(1'b1) );
		end
		if (COUNT_WIDTH != 12)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					count_width_check ( .error(1'b1) );
		end
	endgenerate

	altera_trace_adc_monitor_core #(
		.ADC_DATA_WIDTH        (12),
		.ADC_CHANNEL_WIDTH     (5),
		.CAPTURE_DATA_WIDTH    (8),
		.CONTROL_DATA_WIDTH    (32),
		.CONTROL_ADDRESS_WIDTH (5),
		.COUNT_WIDTH           (12),
		.DELAY_COUNT_WIDTH     (19),
		.DELAY_COUNT_CYCLES    (500000)
	) core (
		.clk                   (clk_clk),                          //    clock.clk
		.reset                 (rst_controller_reset_out_reset),   //    reset.reset
		.adc_channel           (adc_data_channel),                 // adc_data.channel
		.adc_data              (adc_data_data),                    //         .data
		.adc_endofpacket       (adc_data_endofpacket),             //         .endofpacket
		.adc_startofpacket     (adc_data_startofpacket),           //         .startofpacket
		.adc_valid             (adc_data_valid),                   //         .valid
		.control_address       (trace_endpoint_control_address),   //  control.address
		.control_read          (trace_endpoint_control_read),      //         .read
		.control_write         (trace_endpoint_control_write),     //         .write
		.control_writedata     (trace_endpoint_control_writedata), //         .writedata
		.control_readdata      (trace_endpoint_control_readdata),  //         .readdata
		.capture_data          (core_capture_data),                //  capture.data
		.capture_valid         (core_capture_valid),               //         .valid
		.capture_ready         (core_capture_ready),               //         .ready
		.capture_startofpacket (core_capture_startofpacket),       //         .startofpacket
		.capture_endofpacket   (core_capture_endofpacket)          //         .endofpacket
	);

	altera_trace_monitor_endpoint_wrapper #(
		.TRACE_WIDTH       (8),
		.ADDR_WIDTH        (5),
		.READ_LATENCY      (1),
		.HAS_READDATAVALID (0),
		.PREFER_TRACEID    (""),
		.CLOCK_RATE_CLK    (0)
	) trace_endpoint (
		.clk                   (clk_clk),                          //         clk.clk
		.reset                 (trace_endpoint_debug_reset_reset), // debug_reset.reset
		.capture_ready         (core_capture_ready),               //     capture.ready
		.capture_valid         (core_capture_valid),               //            .valid
		.capture_data          (core_capture_data),                //            .data
		.capture_startofpacket (core_capture_startofpacket),       //            .startofpacket
		.capture_endofpacket   (core_capture_endofpacket),         //            .endofpacket
		.control_write         (trace_endpoint_control_write),     //     control.write
		.control_read          (trace_endpoint_control_read),      //            .read
		.control_address       (trace_endpoint_control_address),   //            .address
		.control_writedata     (trace_endpoint_control_writedata), //            .writedata
		.control_readdata      (trace_endpoint_control_readdata),  //            .readdata
		.capture_empty         (1'b0),                             // (terminated)
		.control_waitrequest   (1'b0),                             // (terminated)
		.control_readdatavalid (1'b0)                              // (terminated)
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (2),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (trace_endpoint_debug_reset_reset), // reset_in0.reset
		.reset_in1      (reset_reset),                      // reset_in1.reset
		.clk            (clk_clk),                          //       clk.clk
		.reset_out      (rst_controller_reset_out_reset),   // reset_out.reset
		.reset_req      (),                                 // (terminated)
		.reset_req_in0  (1'b0),                             // (terminated)
		.reset_req_in1  (1'b0),                             // (terminated)
		.reset_in2      (1'b0),                             // (terminated)
		.reset_req_in2  (1'b0),                             // (terminated)
		.reset_in3      (1'b0),                             // (terminated)
		.reset_req_in3  (1'b0),                             // (terminated)
		.reset_in4      (1'b0),                             // (terminated)
		.reset_req_in4  (1'b0),                             // (terminated)
		.reset_in5      (1'b0),                             // (terminated)
		.reset_req_in5  (1'b0),                             // (terminated)
		.reset_in6      (1'b0),                             // (terminated)
		.reset_req_in6  (1'b0),                             // (terminated)
		.reset_in7      (1'b0),                             // (terminated)
		.reset_req_in7  (1'b0),                             // (terminated)
		.reset_in8      (1'b0),                             // (terminated)
		.reset_req_in8  (1'b0),                             // (terminated)
		.reset_in9      (1'b0),                             // (terminated)
		.reset_req_in9  (1'b0),                             // (terminated)
		.reset_in10     (1'b0),                             // (terminated)
		.reset_req_in10 (1'b0),                             // (terminated)
		.reset_in11     (1'b0),                             // (terminated)
		.reset_req_in11 (1'b0),                             // (terminated)
		.reset_in12     (1'b0),                             // (terminated)
		.reset_req_in12 (1'b0),                             // (terminated)
		.reset_in13     (1'b0),                             // (terminated)
		.reset_req_in13 (1'b0),                             // (terminated)
		.reset_in14     (1'b0),                             // (terminated)
		.reset_req_in14 (1'b0),                             // (terminated)
		.reset_in15     (1'b0),                             // (terminated)
		.reset_req_in15 (1'b0)                              // (terminated)
	);

endmodule
