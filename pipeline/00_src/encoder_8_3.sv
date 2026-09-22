//======================================
//Module : Encoder 8-3
//Name   : An
//Date   : 19/06/2026
//======================================
module encoder_8_3 (
    input  logic [7:0] A_i,
    output logic [2:0] Y_o
);
always_comb begin : Encoder_8_3
  Y_o[0] =   A_i[1]  |   A_i[3]  |   A_i[5]  | A_i[7];
  Y_o[1] =   A_i[2]  |   A_i[3]  |   A_i[6]  | A_i[7];
  Y_o[2] =   A_i[4]  |   A_i[5]  |   A_i[6]  | A_i[7];
end
endmodule : encoder_8_3
