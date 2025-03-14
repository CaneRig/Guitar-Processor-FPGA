module sign2unsign#(
		parameter size = 16
	) (
		input [size-1	:0	] in, 
		output[size-1	:0	] out
	);
	
	localparam half = 1 << (size - 1);
	
	assign out = in + (size)'(half);

endmodule

module unsign2sign#(
		parameter size = 16
	) (
		input [size-1	:0	] in, 
		output[size-1	:0	] out
	);
	
	localparam half = 1 << (size - 1);
	
	assign out = in - (size)'(half);
 
endmodule