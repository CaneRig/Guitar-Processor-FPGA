module overdrive #(
     parameter bits_per_level = 12,
               bits_per_gain_frac = 4
)(
     input clk,

     input  [15: 0] i_sample,
     input  [15: 0] i_gain,
     output [31:0]  o_sample
);
     // we assume that before `overdrive` flipflop already placed 
     
     logic[31: 0] gained_signal;
     logic[31: 0] clamped_signal;
     wire [31: 0] ff_gain2ovrd_out;

     gain #(
          .bits_per_level(bits_per_gain_frac)
     ) ins_gain (
          .i_sample(i_sample), 
          .i_gain(i_gain), 
          .o_sample(gained_signal)
     );

     flipflop #(
          .size(32)
     ) ins_gain2ovrd_ff (
          .clk(clk),
          .valid('1),
          .rst('0),

          .data(gained_signal),
          .out(ff_gain2ovrd_out)
     );
     
     overdrive_clamp #(
               bits_per_level
          ) ins_clamp (
               .i_sample(ff_gain2ovrd_out), 
               .o_sample(clamped_signal)
          );
     
     assign o_sample = $signed(clamped_signal);
     
endmodule 
