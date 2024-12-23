module flipflop#(
     .size = 16
)( // rename + parametrise
     input clk,
     input rst,
     input valid,
     input  logic[size - 1    :0   ] data,
     output logic[size - 1    :0   ] out
);

     logic[15: 0] reg_data;
     always_ff @(posedge clk) begin
          if(rst) begin
               reg_data <= '0;
          else if(valid)
               reg_data <= data;
     end

     assign out = reg_data;

endmodule