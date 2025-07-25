// AO - audio output

module topmodule#(
  parameter	clk_mhz   = 13,
				out_res  = 16,  // resolution of output signal
				target_freq  = 48*3  // khz
      
  )(
		input MAX10_CLK1_50,
		input [9: 0] SW,
		input [1: 0] KEY,
		
		output [9: 0] LEDR,
		
		inout [35: 0] GPIO
  );

	wire rst;
	wire clk;
	wire valid = '1;
	wire AO_mclk;  // GPIO-33
	wire AO_bclk;  // GPIO-31
	wire AO_lrclk;  // GPIO-27
	wire AO_sdata;  // GPIO-29

	assign rst = SW[9];
	assign GPIO[33] = AO_mclk;
	assign GPIO[31] = AO_bclk;
	assign GPIO[27] = AO_lrclk;
	assign GPIO[29] = AO_sdata;
	
  
  localparam gnd = '0;
  localparam vcc = '1;
  localparam ch_selector = 5'd1;
  
  
  // gain controll
  localparam gain_increment = 16'd1;
  localparam increment_speed = 18;
  
  
  logic[increment_speed: 0] trigger_counter;
  logic[15: 0] gain_value;
  logic[15: 0] post_gain_value;
  logic[increment_speed: 0] post_trigger_counter;
 
  
  always_ff @(posedge clk) begin
	if(rst) begin 
		trigger_counter <= {1'b1, 20'd0};
		gain_value <= 10'b101001;
	end
	else if (trigger_counter[increment_speed] & SW[0]) begin
		trigger_counter <= '0;
		if(~KEY[0])
			gain_value <= gain_value + gain_increment;
		else if(~KEY[1])
			gain_value <= gain_value - gain_increment;
			
	end else begin
		if(SW[0])
			trigger_counter <= trigger_counter + (increment_speed)'(1);
		else
			trigger_counter <= {1'b1, '0};
	end
  end
  
  always_ff @(posedge clk) begin
	if(rst) begin 
		post_trigger_counter <= {1'b1, '0};
		post_gain_value <= 10'b110;
	end
	else if (post_trigger_counter[increment_speed] & SW[1]) begin
		post_trigger_counter <= '0;
		if(~KEY[0])
			post_gain_value <= post_gain_value + gain_increment;
		else if(~KEY[1])
			post_gain_value <= post_gain_value - gain_increment;
			
	end else begin
		if(SW[1])
			post_trigger_counter <= post_trigger_counter + (increment_speed)'(1);
		else
			post_trigger_counter <= {1'b1, '0};
	end
  end
  
  
  // led display
  	always_comb begin
		if(SW[0])
				LEDR[8:0] = gain_value[9:0];
		else if (SW[1])
				LEDR[8:0] = post_gain_value;
		else	
				LEDR[8:0] = adc_sample_out;
	end
  
	
	valid_generator#(
		.CLK_FREQ(clk_mhz*1000_000),
		.TARET_FREQ(target_freq * 1000)
	) ins_vgen (
		.clk(clk),
		//.valid(valid),
		.rst(rst)
	);


// IO wires
  wire [out_res-1	     : 0] dac_sample_in;
  wire [11			: 0] adc_sample_out; 
  
// audio input
     audio_input #(
          .bit_depth     (12            ),
          .target_depth  (out_res       )
     ) ins_audio_in (
          .clk(MAX10_CLK1_50),
			 .o_pll_clk(clk),
			 .channel(SW[1:0]),
          .o_sample      (adc_sample_out)
     );
	  
	  //assign LEDR[8:0] = adc_sample_out[9:0];
	  
		unsign2sign #(
			.size(16)
		) ins_s2u (
			.in	(adc_sample_out),
			.out	(eff_sample_in)
		);

	
// effects
	wire [out_res-1: 0] eff_sample_in;
	wire [12-1: 0] eff_sample_out;

	effects_pipeline#(
		.bits_per_level(12  ),
          .bits_per_gain_frac(4   ),  // fractional part of input gain
		.fxp_size      (out_res)
	) ins_effs( 
		.clk		     (clk			     ), 
		.rst		     (gnd			     ),
		.ovrd_mode(SW[5]),
		.i_valid	     (valid		     ),
		.i_par_gain    (gain_value),
		.i_sample	     (eff_sample_in	     ),
		.o_sample      (eff_sample_out     ),
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
	wire [out_res-1	: 0] dac_unsign_out_next;
	wire [out_res*2-1	: 0] dac_unsign_out;
	
  
  	sign2unsign #(
		.size(out_res)
     ) ins_u2s (
		.in	(dac_reg),
		.out	(dac_unsign_out_next)
	);
	
	always_ff@(posedge clk)
		if(rst) dac_unsign_out <= '0;
		else dac_unsign_out  <= dac_unsign_out_next;
	
	logic[out_res-1:0] clipped_dac_out;
	localparam big_value = 1 << (out_res-1);
	always_comb begin
		clipped_dac_out = dac_unsign_out * post_gain_value;
		if(clipped_dac_out > big_value)
			clipped_dac_out = big_value;
	end
	
	
	
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