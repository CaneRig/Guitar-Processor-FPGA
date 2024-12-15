// AO - audio output

module topmodule#(
  parameter	clk_mhz   = 50,
				out_res  = 16  // resolution of output signal
      
  )(
		input clk, 
		input rst,
		output AO_mclk,  // GPIO-33
		output AO_bclk,  // GPIO-31
		output AO_lrclk,  // GPIO-27
		output AO_sdata,  // GPIO-29
		output led
  );
  
  wire gnd = '0;
  wire vcc = '1;
  localparam ch_selector = 5'd0;


// IO wires
  wire [out_res-1	: 0] dac_in_sample;
  wire [11			: 0] adc_out_sample; 
  
// audio input
	PLL ppl(
		.inclk0	(clk		),
		.c0		(pll_clk	)
	);
	fiftyfivenm_adcblock_top_wrapper ip_adc (
		.chsel				( ch_selector		),
		.soc					( vcc					),
		.usr_pwd				( gnd					),
		.tsen					( gnd					),
		.clkin_from_pll_c0( pll_clk			),
		.dout					( adc_out_sample	)
	);
	
// effects
	wire [out_res-1: 0] eff_in_sample;
	assign eff_in_sample[11: 0] = adc_out_sample;

	/*TODO
	effects_pipline effs( 
		clk, // slow !?!
		eff_in_sample,
		dac_in_sample
	);
	*/
	assign dac_in_sample = eff_in_sample * 4;
	
	

// audio output  
  i2s_audio_out # (
            .clk_mhz ( clk_mhz   )
        ) inst_audio_out (
            .clk     ( clk       	 ),
            .reset   ( rst       	 ),
            .data_in ( dac_in_sample ),
            .mclk    ( AO_mclk   	 ), // JP1 pin 38
            .bclk    ( AO_bclk   	 ), // JP1 pin 36
            .lrclk   ( AO_lrclk  	 ), // JP1 pin 32
            .sdata   ( AO_sdata  	 )  // JP1 pin 34
        );                          // JP1 pin 30 - GND, pin 29 - VCC 3.3V (30-45 mA)

endmodule