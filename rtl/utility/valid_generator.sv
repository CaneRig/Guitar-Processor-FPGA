// generates short impulse with given frequency
module valid_generator #(
	parameter 	CLK_FREQ = 10_000_000,
					TARET_FREQ = 48_000
) (
	input clk,
	input rst,
	output valid
);
	localparam target_value = CLK_FREQ / TARET_FREQ;
	localparam target_width = $clog2(target_value);
	
	localparam target = (target_width)'(target_value);

	logic[target_width-1: 0] counter = '0;
	logic[target_width-1: 0] counter_next;
	
	always_ff@(posedge clk) begin
		if(rst) counter <= '0;
		else if(counter == target) counter <= '0;
		else counter <= counter_next;
	end
	
	assign counter_next = counter + (target_width)'(1);
	assign valid = counter_next == target;
endmodule