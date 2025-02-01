
// converts in[operand_size-1: 0] -> out[operand_size+expansion_size-1: 0] according to the sign
module signed_expand #(
     parameter operand_size   = 12,
               expansion_size = 4 
) (
     input logic[operand_size-1: 0]                    in, 
     output logic[operand_size+expansion_size-1: 0]    out
);
     logic sign;
     
     always_comb begin
          sign = (in & ((operand_size)'(1) << (operand_size - 1))) >> (operand_size - 1);

          out = {(expansion_size)'(0) - sign, in};
     end
endmodule