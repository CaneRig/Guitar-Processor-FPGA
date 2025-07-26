module overdrive #(
     parameter bits_per_level      = 12,
               bits_per_gain_frac  = 4,
               fxp_size 		     = 16
)(
     input clk,
     input rst,
     input i_valid,
     output o_valid,
	  
	  input mode,

     input  [fxp_size - 1: 0] i_sample,
     input  [fxp_size - 1: 0] i_gain,
     output [fxp_size*2-1: 0]  o_sample
);
	  localparam d_fxp_size = fxp_size*2;
     // we assume that before `overdrive` flipflop already placed 
     
     logic[d_fxp_size-1: 0] gained_signal;
     logic[d_fxp_size-1: 0] clamped_signal_0;
     logic[d_fxp_size-1: 0] clamped_signal_1;
     wire [d_fxp_size-1: 0] ff_gain2ovrd_out;

     gain #(
          .bits_per_level	(bits_per_gain_frac),
          .fxp_size			(fxp_size)
     ) ins_gain (
          .i_sample	(i_sample), 
          .i_gain		(i_gain), 
          .o_sample	(gained_signal)
     );
	  
	  //assign o_sample = gained_signal ;

     flipflop #(
          .size	(d_fxp_size)
     ) ins_gain2ovrd_ff (
          .clk		(clk),
          .rst		(rst),
          .valid	(i_valid),

          .i_data	(gained_signal),
          .o_data	(ff_gain2ovrd_out)
     );
     
     ovrd_piecevise_clamp #(
               .bits_per_level(bits_per_level),
               .fxp_size		(fxp_size*2)
     ) ins_clamp_piece (
               .i_sample		(ff_gain2ovrd_out),  // ff_gain2ovrd_out
               .o_sample		(clamped_signal_0)
          );
     ovrd_tanh_clamp ins_clamp_tanh (
               .i_sample		(ff_gain2ovrd_out), 
               .o_sample		(clamped_signal_1)
          );
     
     assign o_sample = $signed(mode? clamped_signal_0: clamped_signal_1);
	//   assign o_overflow = ~((&clamped_signal_0[31:16]) | (&(~clamped_signal_0[31:16])));
     assign o_valid = i_valid;
     
endmodule 
