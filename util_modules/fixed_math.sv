module fixed_multiply#(
          parameter bits_per_level = 12
     )(
     input int signed a, 
     input int signed b,
     output int signed c
);

assign c = (a*b) >>> bits_per_level;

endmodule