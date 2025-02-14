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