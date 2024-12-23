// AO - audio output

module topmodule#(
  parameter	clk_mhz   = 50,
				out_res  = 16  // resolution of output signal
      
  )(
		input MAX10_CLK1_50,
		input [9: 0] SW,
		input [1: 0] KEY,
		
		output [9: 0] LEDR,
		
		inout [35: 0] GPIO
  );

  	wire clk;
	wire rst;
	wire AO_mclk;  // GPIO-33
	wire AO_bclk;  // GPIO-31
	wire AO_lrclk;  // GPIO-27
	wire AO_sdata;  // GPIO-29

	assign clk = MAX10_CLK1_50;
	assign rst = SW[9];
	assign GPIO[33] = AO_mclk;
	assign GPIO[31] = AO_bclk;
	assign GPIO[27] = AO_lrclk;
	assign GPIO[29] = AO_sdata;
	
  
  wire gnd = '0;
  wire vcc = '1;
  localparam ch_selector = 5'd1;


// IO wires
  wire [out_res-1	: 0] dac_sample_in;
  wire [11			: 0] adc_sample_out; 
  
// audio input
	PLL pll(
		.inclk0	(clk		),
		.c0		(pll_clk	)
	);
	fiftyfivenm_adcblock_top_wrapper ip_adc (
		.chsel				( SW[1:0] 			),
		.soc				( vcc				),
		.usr_pwd			( gnd				),
		.tsen				( gnd				),
		.clkin_from_pll_c0	( pll_clk			),
		.dout				( adc_sample_out	)
	);
	assign LEDR = adc_sample_out[11-:10];
	
// effects
	wire [out_res-1: 0] eff_sample_in;
	assign eff_sample_in[11: 0] = adc_sample_out;

	effects_pipline i_effs( 
		.clk		(clk			), 
		.rst		(gnd			),
		.valid		(gcc			),
		.gain_value	(10'd20			),
		.sample_in	(eff_sample_in	),
		.sample_out	(eff_sample_out	)
	);
	
	assign dac_sample_in = SW[3] ? eff_sample_in * 4 : eff_sample_out;
	// in/out v konce 
	
	
	logic[15: 0] dac_reg;
	
	always_ff @(posedge clk) begin
		if(rst)
			dac_reg <= '0;
		else
			dac_reg <= dac_sample_in;
	end
	

// audio output  
  i2s_audio_out # (
            .clk_mhz ( clk_mhz   )
        ) inst_audio_out (
            .clk     ( clk   	 ),
            .reset   ( rst       	 ),
            .data_in ( dac_reg		 ),
            .mclk    ( AO_mclk   	 ), // JP1 pin 38
            .bclk    ( AO_bclk   	 ), // JP1 pin 36
            .lrclk   ( AO_lrclk  	 ), // JP1 pin 32
            .sdata   ( AO_sdata  	 )  // JP1 pin 34
        );                          // JP1 pin 30 - GND, pin 29 - VCC 3.3V (30-45 mA)

endmodule