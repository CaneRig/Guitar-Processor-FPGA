// AO - audio output

module topmodule#(
	parameter 	clk_mhz 	= 50,
					out_res	= 16	// resolution of output signal
			
	)(
	input clk, 
	output AO_mclk,	// GPIO-33
	output AO_bclk,	// GPIO-31
	output AO_lrclk,	// GPIO-27
	output AO_sdata	// GPIO-29
	);

	wire rst;
	assign rstrst = '0;

// IO wires
	wire [out_res-1: 0] out_sound;
	
	
	logic [20: 0] slow_clock;
	always_ff @(posedge clk) begin
		if (rst)
			slow_clock <= '0;
		else
			slow_clock <= slow_clock + '1;
	end
	
	assign out_sound[5] = slow_clock[16];
	

// audio output	
	i2s_audio_out
        # (
            .clk_mhz ( clk_mhz   )
        )
        inst_audio_out
        (
            .clk     ( clk       ),
            .reset   ( rst       ),
            .data_in ( out_sound ),
            .mclk    ( AO_mclk   ), // JP1 pin 38
            .bclk    ( AO_bclk   ), // JP1 pin 36
            .lrclk   ( AO_lrclk  ), // JP1 pin 32
            .sdata   ( AO_sdata  )  // JP1 pin 34
        );                          // JP1 pin 30 - GND, pin 29 - VCC 3.3V (30-45 mA)

endmodule