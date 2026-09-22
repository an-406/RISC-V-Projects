//======================================
//Module : ALU 
//Name   : An
//Date   : 03/07/2026
//Update : 05/07/2026
//======================================
module alu (
    input  logic [31:0] rs1_i,
    input  logic [31:0] rs2_i,
    input  logic [3:0]  alu_control_i,
    output logic [31:0] rd_o
);

logic [31:0] rs2;
assign rs2 = (alu_control_i[2])? ~rs2_i : rs2_i;


// ADD / SUB LOGIC BLOCK 
logic [31:0] add_sub;
logic        c , v;
add_subtract u_as0 (
  .A_i(rs1_i),
  .B_i(rs2),
  .C_i(alu_control_i[2]),
  .S_o(add_sub),
  .C_o(c),
  .V_o(v)
);
// SLT / SLTU LOGIC BLOCK 
logic [31:0] slt , sltu;
assign sltu = {{31{1'b0}},{1{~c}}};
assign slt  = {{31{1'b0}},{1{add_sub[31]^v}}};  
// SLL / SRL / SRA LOGIC BLOCK
logic [31:0] shift_bit;
barrel_shifter u_bs0 (
  .A_i(rs1_i),
  .Shift_i(rs2_i[4:0]),
  .lr_sel_i(alu_control_i[0]), // 0 : srl  1 : sll
  .la_sel_i(alu_control_i[1]), // 0 : srl  1 : sra
  .result_o(shift_bit)
);
always_comb begin : ALU_Logic_Block
  case (alu_control_i)
    4'b0000: rd_o = rs1_i & rs2_i; // AND
    4'b0001: rd_o = rs1_i | rs2_i; // OR 
    4'b0011: rd_o = rs1_i ^ rs2_i; // XOR
    4'b0010: rd_o = add_sub;       // add
    4'b0110: rd_o = add_sub;       // sub
    4'b0111: rd_o = slt;           // set less than 
    4'b0100: rd_o = sltu;          // set less than ( u )
    4'b1001: rd_o = shift_bit;     // sll 
    4'b1000: rd_o = shift_bit;     // srl 
    4'b1010: rd_o = shift_bit;     // sra  
    default: rd_o = '0; 
  endcase
end
endmodule : alu
