module overlay #(
     parameter bucket_size = 16
) (
     input shortint signed A[bucket_size],
     input shortint signed B[bucket_size], 
     output shortint signed C[bucket_size]
);

genvar i;
generate
     for (i=0; i<bucket_size; ++i) begin
          overlay_element mix_el (
               .a(A[i]),
               .b(B[i]),
               .answer(C[i]));
     end
endgenerate

endmodule