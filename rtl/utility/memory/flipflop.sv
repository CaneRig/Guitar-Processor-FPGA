module flipflop#(
     parameter size = 16
) ( 
     input clk,
     input rst,
     input valid,
     input  logic[size - 1    :0   ] i_data,
     output logic[size - 1    :0   ] o_data
);

     logic[size - 1: 0] reg_data;
     always_ff @(posedge clk) begin
          if(rst)
               reg_data <= '0;
          else if(valid)
               reg_data <= i_data;
     end

     assign o_data = reg_data;

endmodule