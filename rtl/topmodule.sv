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
	
  
  localparam gnd = '0;
  localparam vcc = '1;
  localparam ch_selector = 5'd1;


// IO wires
  wire [out_res-1	     : 0] dac_sample_in;
  wire [11			: 0] adc_sample_out; 
  
// audio input
     audio_input #(
          .bit_depth     (12            ),
          .target_depth  (out_res       )
     ) ins_audio_in (
          .clk(clk),
          .o_sample      (adc_sample_out)
     );

	
// effects
	wire [out_res-1: 0] eff_sample_in;
	wire [out_res-1: 0] eff_sample_out;

	effects_pipeline#(
		.bits_per_level(12  ),
          .bits_per_gain_frac(4   ),  // fractional part of input gain
		.fxp_size      (out_res)
	) ins_effs( 
		.clk		     (clk			     ), 
		.rst		     (gnd			     ),
		.valid	     (vcc			     ),
		.i_par_gain    (10'd1 << 8         ),
		.i_sample	     (eff_sample_in	     ),
		.o_sample      (eff_sample_out     )
	);
	
	// toggle transparent mode
	assign dac_sample_in = SW[3] ? eff_sample_in : eff_sample_out;
	
	
	logic[out_res-1: 0] dac_reg;
	
	always_ff @(posedge clk) begin
		if(rst)
			dac_reg <= '0;
		else
			dac_reg <= dac_sample_in;
	end
	
	
// audio output  
	wire [out_res-1	: 0] dac_unsign_out;
	
  
  	sign2unsign #(
		.size(12)
     ) ins_s2u (
		.in	(dac_reg),
		.out	(dac_unsign_out)
	);
     i2s_audio_out # (
               .clk_mhz ( clk_mhz   )
     ) ins_audio_out (
               .clk     ( clk   	 ),
               .reset   ( rst       	 ),
               .data_in ( dac_unsign_out),
               .mclk    ( AO_mclk   	 ), // JP1 pin 38
               .bclk    ( AO_bclk   	 ), // JP1 pin 36
               .lrclk   ( AO_lrclk  	 ), // JP1 pin 32
               .sdata   ( AO_sdata  	 )  // JP1 pin 34
          );                          // JP1 pin 30 - GND, pin 29 - VCC 3.3V (30-45 mA)

endmodule