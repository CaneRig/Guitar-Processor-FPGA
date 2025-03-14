// an flipflop that carries valid flag 

module flipflop_v#(
     parameter size = 16
) ( 
     input clk,
     input rst,
     input valid,
     input                      i_valid,
     input  [size - 1    :0   ] i_data,
     output                     o_valid,
     output [size - 1    :0   ] o_data
);

     logic[size - 1: 0] reg_data;
     logic reg_valid;
     always_ff @(posedge clk) begin
          if(rst) begin
               reg_data <= '0;
               reg_valid <= '0;
          end
          else if(valid) begin
               reg_data <= i_data;
               reg_valid <= i_valid;
          end
     end

     assign o_data = reg_data;
     assign o_valid = reg_valid;

endmodule