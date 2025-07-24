`include "config.svh"


// assertation checks
`ifdef SIMULATION
     `define STATIC_CHECK(EXPR, MSG) \
          initial assert ((EXPR)) \
               else $error(MSG);
`else 
     `define STATIC_CHECK(EXPR, MSG)
`endif

`define CHECK_POW2(VALUE, MSG) \
          `STATIC_CHECK((1<<$clog2(VALUE)) == VALUE, MSG)   


`ifdef SIMULATION
     function int fp2fx(input real value, input int frac_bits);
     return int'(value * (1 << frac_bits));
     endfunction

     function real fx2fp(int value, int frac_bits);
     return real'(value) / real'(1 << frac_bits);
     endfunction

     function real abs(real a);
          if(a < 0)
               return -a;
          else 
               return a;
     endfunction
`endif