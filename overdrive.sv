module overdrive #(
     parameter bits_per_level = 12,
               bits_per_gain_frac = 4
)(
     input clk,

     input logic[15: 0] signal_in,
     input logic[15: 0] gain,
     output logic[31:0] signal_out
);
     // we assume that before `overdrive` flipflop already placed 
     
     logic[31: 0] gained_signal;
     logic[31: 0] clamped_signal;
     wire [31: 0] ff_gain2ovrd_out;

     gain #(
          .bits_per_level(bits_per_gain_frac)
     ) i_gain (
          .x(signal_in), 
          .gain_value(gain), 
          .res(gained_signal)
     );

     flipflop #(
          .size(32)
     ) i_gain2ovrd_ff (
          .clk(clk),
          .valid('1),
          .rst('1),

          .data(gained_signal),
          .out(ff_gain2ovrd_out)
     );
     
     overdrive_clamp #(
               bits_per_level
          ) i_clamp (
               .x(ff_gain2ovrd_out), 
               .out(clamped_signal)
          );
     
     assign signal_out = $signed(ss_clamped_signal);
     
endmodule 
