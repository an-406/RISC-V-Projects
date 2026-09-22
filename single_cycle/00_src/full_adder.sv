//======================================
//Module : FullAdder
//Name   : An
//Date   : 15/06/2026
//======================================
module full_adder(
    input  logic A_i, 
    input  logic B_i, 
    input  logic C_i, 
    output logic S_o,
    output logic C_o
);
always_comb begin : Full_Adder
  S_o = A_i ^ B_i ^ C_i;
  C_o = (A_i&C_i)|(A_i&B_i)|(B_i&C_i);
end
endmodule : full_adder
