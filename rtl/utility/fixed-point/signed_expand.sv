// converts in[operand_size-1: 0] -> out[operand_size+expansion_size-1: 0] according to the sign
module signed_expand #(
     parameter operand_size   = 12,
               expansion_size = 4 
) (
     input  [operand_size-1: 0]                   in, 
     output [operand_size+expansion_size-1: 0]    out
);
     wire sign;
     
     assign sign = in[operand_size-1];

     assign out = {{expansion_size{sign}}, in};
endmodule