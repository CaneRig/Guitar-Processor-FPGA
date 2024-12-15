// AO - audio output

module topmodule#(
<<<<<<< HEAD
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
=======
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
  localparam ch_selector = 5'0;


// IO wires
  wire [out_res-1	: 0] dac_in_sample;
  wire [11			: 0] adc_out_sample; 
  
// audio input
	PLL ppl(
		.inclk0	(clk		),
		.c0		(pll_clk	)
	);
	fiftyfivenm_adcblock_top_wrapper ip_adc (
		.chsel				(ch_selector	),
		.soc					(vcc				),
		.usr_pwd				(gnd				),
		.tsen					(gnd				),
		.clkin_from_pll_c0(pll_clk			),
		.dout					(adc_out_sample)
	);
	
	

// audio output  
  i2s_audio_out
>>>>>>> 44a81d4366013205f106e42982eeb76cb5d73182
        # (
            .clk_mhz ( clk_mhz   )
        )
        inst_audio_out
        (
<<<<<<< HEAD
            .clk     ( clk       ),
            .reset   ( rst       ),
            .data_in ( out_sound ),
            .mclk    ( AO_mclk   ), // JP1 pin 38
            .bclk    ( AO_bclk   ), // JP1 pin 36
            .lrclk   ( AO_lrclk  ), // JP1 pin 32
            .sdata   ( AO_sdata  )  // JP1 pin 34
=======
            .clk     ( clk       	 ),
            .reset   ( rst       	 ),
            .data_in ( dac_in_sample ),
            .mclk    ( AO_mclk   	 ), // JP1 pin 38
            .bclk    ( AO_bclk   	 ), // JP1 pin 36
            .lrclk   ( AO_lrclk  	 ), // JP1 pin 32
            .sdata   ( AO_sdata  	 )  // JP1 pin 34
>>>>>>> 44a81d4366013205f106e42982eeb76cb5d73182
        );                          // JP1 pin 30 - GND, pin 29 - VCC 3.3V (30-45 mA)

endmodule