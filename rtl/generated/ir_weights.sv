`include "util.svh"

module ir_weights#(
	parameter test_vector_len = 64,
		test_word_width =   16
)(
// 	output[63: 0][15: 0] weights_re,
// 	output[63: 0][15: 0] weights_im

	input [4: 0] i_addr,
	output[15: 0] o_weights_re,
	output[15: 0] o_weights_im
);

	//`STATIC_CHECK(test_vector_len == 64, "Invalid vector length, expected: 64");
	//`STATIC_CHECK(test_word_width == 16, "Invalid word length, expected: 16");


	always_comb begin
		case(i_addr)
			5'd0: begin 
				o_weights_re = 16'h2A52; 
				o_weights_im = 16'h0000; 
			end
			5'd1: begin 
				o_weights_re = 16'h41BB; 
				o_weights_im = 16'hC876; 
			end
			5'd2: begin 
				o_weights_re = 16'h1CF9; 
				o_weights_im = 16'hF741; 
			end
			5'd3: begin 
				o_weights_re = 16'h4C64; 
				o_weights_im = 16'hD491; 
			end
			5'd4: begin 
				o_weights_re = 16'h5ED9; 
				o_weights_im = 16'hD3DA; 
			end
			5'd5: begin 
				o_weights_re = 16'h0DAA; 
				o_weights_im = 16'h9508; 
			end
			5'd6: begin 
				o_weights_re = 16'hD19F; 
				o_weights_im = 16'hCD4C; 
			end
			5'd7: begin 
				o_weights_re = 16'hDEFC; 
				o_weights_im = 16'hF98D; 
			end
			5'd8: begin 
				o_weights_re = 16'hEBE0; 
				o_weights_im = 16'hFDC5; 
			end
			5'd9: begin 
				o_weights_re = 16'hF3A2; 
				o_weights_im = 16'hF9ED; 
			end
			5'd10: begin 
				o_weights_re = 16'hF992; 
				o_weights_im = 16'hFDDA; 
			end
			5'd11: begin 
				o_weights_re = 16'hFAB9; 
				o_weights_im = 16'hFCC6; 
			end
			5'd12: begin 
				o_weights_re = 16'hFCD1; 
				o_weights_im = 16'hFE1C; 
			end
			5'd13: begin 
				o_weights_re = 16'hFD24; 
				o_weights_im = 16'hFBE7; 
			end
			5'd14: begin 
				o_weights_re = 16'hFC2A; 
				o_weights_im = 16'hFF26; 
			end
			5'd15: begin 
				o_weights_re = 16'hFD5B; 
				o_weights_im = 16'hFE01; 
			end
			5'd16: begin 
				o_weights_re = 16'hFF45; 
				o_weights_im = 16'hFE20; 
			end
			5'd17: begin 
				o_weights_re = 16'h0260; 
				o_weights_im = 16'hFFB2; 
			end
			5'd18: begin 
				o_weights_re = 16'h0128; 
				o_weights_im = 16'hFBF7; 
			end
			5'd19: begin 
				o_weights_re = 16'hFEF2; 
				o_weights_im = 16'hFD9D; 
			end
			5'd20: begin 
				o_weights_re = 16'hFF82; 
				o_weights_im = 16'hFFE2; 
			end
			5'd21: begin 
				o_weights_re = 16'h024D; 
				o_weights_im = 16'hFA4A; 
			end
			5'd22: begin 
				o_weights_re = 16'hFDF6; 
				o_weights_im = 16'hFC42; 
			end
			5'd23: begin 
				o_weights_re = 16'hFF57; 
				o_weights_im = 16'hFF3C; 
			end
			5'd24: begin 
				o_weights_re = 16'hFF59; 
				o_weights_im = 16'hFDDB; 
			end
			5'd25: begin 
				o_weights_re = 16'hFE56; 
				o_weights_im = 16'hFDDD; 
			end
			5'd26: begin 
				o_weights_re = 16'hFF63; 
				o_weights_im = 16'hFF3C; 
			end
			5'd27: begin 
				o_weights_re = 16'h000A; 
				o_weights_im = 16'hFFCB; 
			end
			5'd28: begin 
				o_weights_re = 16'hFFB6; 
				o_weights_im = 16'hFF58; 
			end
			5'd29: begin 
				o_weights_re = 16'h007A; 
				o_weights_im = 16'h0020; 
			end
			5'd30: begin 
				o_weights_re = 16'h00BC; 
				o_weights_im = 16'hFF71; 
			end
			5'd31: begin 
				o_weights_re = 16'hFFDB; 
				o_weights_im = 16'hFF47; 
			end
			5'd32: begin 
				o_weights_re = 16'hFFA9; 
				o_weights_im = 16'h0000; 
			end
			5'd33: begin 
				o_weights_re = 16'hFFDB; 
				o_weights_im = 16'h00B9; 
			end
			5'd34: begin 
				o_weights_re = 16'h00BC; 
				o_weights_im = 16'h008F; 
			end
			5'd35: begin 
				o_weights_re = 16'h007A; 
				o_weights_im = 16'hFFE0; 
			end
			5'd36: begin 
				o_weights_re = 16'hFFB6; 
				o_weights_im = 16'h00A8; 
			end
			5'd37: begin 
				o_weights_re = 16'h000A; 
				o_weights_im = 16'h0035; 
			end
			5'd38: begin 
				o_weights_re = 16'hFF63; 
				o_weights_im = 16'h00C4; 
			end
			5'd39: begin 
				o_weights_re = 16'hFE56; 
				o_weights_im = 16'h0223; 
			end
			5'd40: begin 
				o_weights_re = 16'hFF59; 
				o_weights_im = 16'h0225; 
			end
			5'd41: begin 
				o_weights_re = 16'hFF57; 
				o_weights_im = 16'h00C4; 
			end
			5'd42: begin 
				o_weights_re = 16'hFDF6; 
				o_weights_im = 16'h03BE; 
			end
			5'd43: begin 
				o_weights_re = 16'h024D; 
				o_weights_im = 16'h05B6; 
			end
			5'd44: begin 
				o_weights_re = 16'hFF82; 
				o_weights_im = 16'h001E; 
			end
			5'd45: begin 
				o_weights_re = 16'hFEF2; 
				o_weights_im = 16'h0263; 
			end
			5'd46: begin 
				o_weights_re = 16'h0128; 
				o_weights_im = 16'h0409; 
			end
			5'd47: begin 
				o_weights_re = 16'h0260; 
				o_weights_im = 16'h004E; 
			end
			5'd48: begin 
				o_weights_re = 16'hFF45; 
				o_weights_im = 16'h01E0; 
			end
			5'd49: begin 
				o_weights_re = 16'hFD5B; 
				o_weights_im = 16'h01FF; 
			end
			5'd50: begin 
				o_weights_re = 16'hFC2A; 
				o_weights_im = 16'h00DA; 
			end
			5'd51: begin 
				o_weights_re = 16'hFD24; 
				o_weights_im = 16'h0419; 
			end
			5'd52: begin 
				o_weights_re = 16'hFCD1; 
				o_weights_im = 16'h01E4; 
			end
			5'd53: begin 
				o_weights_re = 16'hFAB9; 
				o_weights_im = 16'h033A; 
			end
			5'd54: begin 
				o_weights_re = 16'hF992; 
				o_weights_im = 16'h0226; 
			end
			5'd55: begin 
				o_weights_re = 16'hF3A2; 
				o_weights_im = 16'h0613; 
			end
			5'd56: begin 
				o_weights_re = 16'hEBE0; 
				o_weights_im = 16'h023B; 
			end
			5'd57: begin 
				o_weights_re = 16'hDEFC; 
				o_weights_im = 16'h0673; 
			end
			5'd58: begin 
				o_weights_re = 16'hD19F; 
				o_weights_im = 16'h32B4; 
			end
			5'd59: begin 
				o_weights_re = 16'h0DAA; 
				o_weights_im = 16'h6AF8; 
			end
			5'd60: begin 
				o_weights_re = 16'h5ED9; 
				o_weights_im = 16'h2C26; 
			end
			5'd61: begin 
				o_weights_re = 16'h4C64; 
				o_weights_im = 16'h2B6F; 
			end
			5'd62: begin 
				o_weights_re = 16'h1CF9; 
				o_weights_im = 16'h08BF; 
			end
			5'd63: begin 
				o_weights_re = 16'h41BB; 
				o_weights_im = 16'h378A; 
			end

			default: begin
				o_weights_re = '0;
				o_weights_im = '0;
			end
		endcase
	end
endmodule
