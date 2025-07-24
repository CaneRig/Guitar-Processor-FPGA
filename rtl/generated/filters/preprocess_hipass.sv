
module preprocess_hipass(
	input clk,
	input rst,
	input i_valid,
	output o_valid,
	input  signed[FXP_SIZE-1: 0] i_sample,
	output signed[FXP_SIZE-1: 0] o_sample
);

	localparam FXP_SIZE = 16;
	localparam FXP_FRAC = 12;
	localparam COMP_SIZE = FXP_SIZE + FXP_FRAC; // size of numbers in computations
	
	// for more precision
	wire signed[COMP_SIZE-1] wide_sample;
	signed_expand#(
	     .operand_size  (FXP_SIZE),
	     .expansion_size(FXP_FRAC) 
	) ins_sample_expand (
	     .in(i_sample),
	     .out(wide_sample)
	);
	
	
	wire[COMP_SIZE-1: 0] y_next;
	logic[COMP_SIZE-1:0] y_0;
	logic[COMP_SIZE-1:0] y_1;
	logic[COMP_SIZE-1:0] y_2;
	logic[COMP_SIZE-1:0] y_3;
	logic[COMP_SIZE-1:0] x_0;
	logic[COMP_SIZE-1:0] x_1;
	logic[COMP_SIZE-1:0] x_2;
	logic[COMP_SIZE-1:0] x_3;
	logic[COMP_SIZE-1:0] x_4;

	assign x_0 = wide_sample;
	always_ff@(posedge clk) begin

		if(rst) y_0 <= '0;
		else if(i_valid) y_0 <= y_next;

		if(rst) y_1 <= '0;
		else if(i_valid) y_1 <= y_0;

		if(rst) y_2 <= '0;
		else if(i_valid) y_2 <= y_1;

		if(rst) y_3 <= '0;
		else if(i_valid) y_3 <= y_2;
	end

	always_ff@(posedge clk) begin

		if(rst) x_1 <= '0;
		else if(i_valid) x_1 <= x_0;

		if(rst) x_2 <= '0;
		else if(i_valid) x_2 <= x_1;

		if(rst) x_3 <= '0;
		else if(i_valid) x_3 <= x_2;

		if(rst) x_4 <= '0;
		else if(i_valid) x_4 <= x_3;
	end
	localparam b_0 = 28'b0000000000000000000100011011;
	localparam a_1 = -28'b0000000000000000010111001111;
	localparam b_1 = 28'b0000000000000000010001101101;
	localparam a_2 = 28'b0000000000000000100001110001;
	localparam b_2 = 28'b0000000000000000011010100100;
	localparam a_3 = -28'b0000000000000000000100111111;
	localparam b_3 = 28'b0000000000000000010001101101;
	localparam a_4 = 28'b0000000000000000000001010010;
	localparam b_4 = 28'b0000000000000000000100011011;



	assign y_next = $signed(b_0 * x_0 + b_1 * x_1 + b_2 * x_2 + b_3 * x_3 + b_4 * x_4 - a_1 * y_0 - a_2 * y_1 - a_3 * y_2 - a_4 * y_3) >>> FXP_FRAC;

	assign o_sample = y_0;

	logic[4: 0] valid_reg;
	always_ff @(posedge clk) begin
		if (rst) 
			valid_reg <= '0;
		else if(i_valid)
			valid_reg <= {valid_reg[4:0], 1'b1};
	end
	assign o_valid = valid_reg[4];
endmodule
