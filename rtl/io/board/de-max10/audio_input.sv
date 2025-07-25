module audio_input #(
     parameter bit_depth      = 12,
               target_depth   = 16
               //channel        = 0
) (
     input          clk,
	  input [1:0] channel,
     output      o_pll_clk,

     output     [target_depth-1: 0] o_sample
);
     wire [11			: 0] unsigned_sample; 
     wire [11			: 0] signed_sample; 


     // clock
     PLL ins_pll(
		.inclk0	(clk		),
		.c0		(pll_clk	),
	);
	
	assign  o_pll_clk = pll_clk;

     // read input
	fiftyfivenm_adcblock_top_wrapper ins_ip_adc (
		.chsel				( 2'b10 				),
		.soc					( '1						),
		.usr_pwd				( '0						),
		.tsen				( '0						),
		.clkin_from_pll_c0       ( pll_clk					),
		.dout				( unsigned_sample             )
	);


     // convert unsigend -> signed
     unsign2sign#(
		.size(bit_depth)
     ) ins_u2s (
		.in	(unsigned_sample),
		.out	(signed_sample)
	);


     // convert sample from bit_depth -> target_depth
     signed_expand#(
		.operand_size(bit_depth),
		.expansion_size(target_depth - bit_depth)
	) ins_eff_sample_in_expand (
		.in	(signed_sample),
		.out	(o_sample)
	);
     
endmodule