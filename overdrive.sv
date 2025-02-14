module overdrive #(
     parameter bits_per_level = 12,
               bits_per_gain_frac = 4
)(
     input clk,

     input  [15: 0] in_sample,
     input  [15: 0] in_gain,
     output [31:0]  ou_sample
);
     // we assume that before `overdrive` flipflop already placed 
     
     logic[31: 0] gained_signal;
     logic[31: 0] clamped_signal;
     wire [31: 0] ff_gain2ovrd_out;

     gain #(
          .bits_per_level(bits_per_gain_frac)
     ) i_gain (
          .in_sample(in_sample), 
          .in_gain(in_gain), 
          .ou_sample(gained_signal)
     );

     flipflop #(
          .size(32)
     ) i_gain2ovrd_ff (
          .clk(clk),
          .valid('1),
          .rst('0),

          .data(gained_signal),
          .out(ff_gain2ovrd_out)
     );
     
     overdrive_clamp #(
               bits_per_level
          ) i_clamp (
               .in_sample(ff_gain2ovrd_out), 
               .ou_sample(clamped_signal)
          );
     
     assign ou_sample = $signed(clamped_signal);
     
endmodule 
