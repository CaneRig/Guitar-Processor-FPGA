module latch16(
     input clk,
     input  logic[15: 0] data,
     output logic[15: 0] out
)

     logic[15: 0] reg_data;
     always_ff @(posedge clk) begin
          reg_data <= data;
     end

     assign out = reg_data;

endmodule