module overlay #(
     parameter bucket_size = 64
) (
     input shortint signed[bucket_size] A,
     input shortint signed[bucket_size] B, 
     output shortint signed[bucket_size] C
);

generate;
     for (int i=0; i<bucket_size; ++i) begin
          overlay_element mix_el (
               .a(A[i]),
               .b(B[i]),
               .answer(C[i]));
     end
endgenerate

endmodule