//======================================
//Module : Decoder 3-8
//Name   : An
//Date   : 19/06/2026
//======================================
module decoder3_8 (
    input  logic [2:0] A_i,
    output logic [7:0] Y_o
);
always_comb begin : Decoder_3_8
  
  Y_o[0] = ~(A_i[0]) & ~(A_i[1]) & ~(A_i[2]);
  Y_o[1] =    A_i[0] & ~(A_i[1]) & ~(A_i[2]);
  Y_o[2] = ~(A_i[0]) & A_i[1]    & ~(A_i[2]);
  Y_o[3] =    A_i[0] & A_i[1]    & ~(A_i[2]);

  Y_o[4] = ~(A_i[0]) & ~(A_i[1]) & A_i[2];
  Y_o[5] =    A_i[0] & ~(A_i[1]) & A_i[2];
  Y_o[6] = ~(A_i[0]) & A_i[1]    & A_i[2];
  Y_o[7] =    A_i[0] & A_i[1]    & A_i[2];
end
endmodule : decoder3_8