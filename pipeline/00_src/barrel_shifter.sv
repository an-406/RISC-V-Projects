//======================================
//Module : Barrel shifter 
//Name   : An
//Date   : 03/07/2026
//======================================
module barrel_shifter (
    input  logic [31:0] A_i,
    input  logic [4:0]  Shift_i,
    input  logic        lr_sel_i , la_sel_i,
    output logic [31:0] result_o
);

logic [31:0] A_store , A_r , s_r;
assign A_r = {A_i[0], A_i[1], A_i[2], A_i[3], A_i[4], A_i[5], A_i[6], A_i[7], A_i[8], A_i[9], A_i[10], A_i[11], A_i[12], A_i[13], A_i[14], A_i[15], A_i[16], A_i[17], A_i[18], A_i[19], A_i[20], A_i[21], A_i[22], A_i[23], A_i[24], A_i[25], A_i[26], A_i[27], A_i[28], A_i[29], A_i[30], A_i[31]};
assign A_store = (lr_sel_i)? A_r : A_i;

logic add_bit_shift;
assign add_bit_shift = la_sel_i & A_i[31]; // srl or sra 

logic [31:0] s0 , s1 , s2 , s3 , s4;
always_comb begin : Shift_Logic_Block
  s0 = (Shift_i[0])? {{1{add_bit_shift}},A_store[31:1]}  : A_store; 
  s1 = (Shift_i[1])? {{2{add_bit_shift}},s0[31:2]}   : s0;
  s2 = (Shift_i[2])? {{4{add_bit_shift}},s1[31:4]}   : s1;
  s3 = (Shift_i[3])? {{8{add_bit_shift}},s2[31:8]}   : s2;
  s4 = (Shift_i[4])? {{16{add_bit_shift}},s3[31:16]} : s3;
end

assign s_r = {s4[0], s4[1], s4[2], s4[3], s4[4], s4[5], s4[6], s4[7], s4[8], s4[9], s4[10], s4[11], s4[12], s4[13], s4[14], s4[15], s4[16], s4[17], s4[18], s4[19], s4[20], s4[21], s4[22], s4[23], s4[24], s4[25], s4[26], s4[27], s4[28], s4[29], s4[30], s4[31]};
assign result_o = (lr_sel_i)? s_r : s4; 
endmodule : barrel_shifter
