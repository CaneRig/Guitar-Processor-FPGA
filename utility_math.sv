module multiply #(
     parameter bits_per_level = 12
) (
     input shortint signed a, b,
     output shortint signed res
);

int signed t;
assign t = (int'(a) * int'(b)) >> bits_per_level;
assign res = t;

endmodule