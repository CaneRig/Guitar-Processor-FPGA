module latch16( // rename + parametrise
     input clk,
     // reset
     input  logic[15: 0] data,
     output logic[15: 0] out
);

     logic[15: 0] reg_data;
     always_ff @(posedge clk) begin
          reg_data <= data;
     end

     assign out = reg_data;

endmodule