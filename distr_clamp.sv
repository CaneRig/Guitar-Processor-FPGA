module distortion_clamp(
	input int signed x,
	output int signed out
);
 
localparam one_level = 1 << 12;
 
int signed dx = int'(x);
 
always_comb begin
	if ( dx > one_level )
		out = one_level;
	else if ( dx < -one_level)
		out = -one_level;
	else
		out = ((v*3) >> 2) + (((v*v) >> 16)*v >> 16); 
end
 
endmodule
