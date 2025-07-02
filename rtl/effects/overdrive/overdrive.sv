module overdrive #(
     parameter bits_per_level      = 12,
               bits_per_gain_frac  = 4,
               fxp_size 		     = 16
)(
     input clk,
     input rst,

     input  [fxp_size - 1: 0] i_sample,
     input  [fxp_size - 1: 0] i_gain,
     output [fxp_size*2-1: 0]  o_sample
);
	  localparam d_fxp_size = fxp_size*2;
     // we assume that before `overdrive` flipflop already placed 
     
     logic[d_fxp_size-1: 0] gained_signal;
     logic[d_fxp_size-1: 0] clamped_signal;
     wire [d_fxp_size-1: 0] ff_gain2ovrd_out;

     gain #(
          .bits_per_level	(bits_per_gain_frac),
			 .fxp_size			(fxp_size)
     ) ins_gain (
          .i_sample	(i_sample), 
          .i_gain		(i_gain), 
          .o_sample	(gained_signal)
     );

     flipflop #(
          .size	(d_fxp_size)
     ) ins_gain2ovrd_ff (
          .clk		(clk),
          .rst		(rst),
          .valid	('1),

          .i_data	(gained_signal),
          .o_data	(ff_gain2ovrd_out)
     );
     
     ovrd_piecevise_clamp #(
               .bits_per_level(bits_per_level),
               .fxp_size		(fxp_size*2)
          ) ins_clamp (
               .i_sample		(ff_gain2ovrd_out), 
               .o_sample		(clamped_signal)
          );
     
     assign o_sample = $signed(clamped_signal);
     
endmodule 
