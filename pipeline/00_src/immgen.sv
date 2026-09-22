//======================================
//Module : immgen
//Name   : An
//Date   : 05/07/2026
//======================================
module immgen (
    input  logic  [31:0] inst_i,
    output logic  [31:0] imm_o
);
always_comb begin 
  case (inst_i[6:0])
    // I-type
    7'b0000011,
    7'b1100111,
    7'b0010011: imm_o = {{20{inst_i[31]}},inst_i[31:20]}; 
    // S-type                   
    7'b0100011: imm_o = {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]}; 
    // B-type
    7'b1100011: imm_o = {{19{inst_i[31]}},inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8],1'b0}; 
    // U-type
    7'b0110111, 
    7'b0010111: imm_o = {inst_i[31:12],{12{1'b0}}};   
    // J-type
    7'b1101111: imm_o = {{11{inst_i[31]}},inst_i[31],inst_i[19:12],inst_i[20],inst_i[30:21],1'b0};
    default: imm_o = '0;
  endcase    
end
endmodule : immgen
