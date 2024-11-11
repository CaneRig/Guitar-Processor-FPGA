module tesbench();

shortint mulA, mulB, mulOut;

multiply m_mul(mulA, mulB, mulOut) ;

initial begin // multiplication
     for (int i=-2**16+1; i<2**16; i+=8) begin
          for (int j=-2**16+2; j<2**16; i+=8) begin
               assign {mulA, mulB} = {i, j};
               #1ns
               if(mulOut !== (i*j / (2**16)))
                    $error("Oopsy-doopsy. The UwU multiplycatinyan is not wowkin (");
          end
     end
end

endmodule