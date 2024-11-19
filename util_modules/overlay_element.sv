module overlay_element(
     input shortint a,
     input shortint b,
     output shortint answer
);

assign answer = shortint'((int'(a) + int'(b)) / 2);

endmodule