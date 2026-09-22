//======================================
//Module : Control Unit 
//Name   : An
//Date   : 04/07/2026
//Update : 06/07/2026
//======================================
module control_unit (
	input  logic [31:0] inst_i,        
	output logic [3:0]  alu_control_o, 
	output logic        regwrite_o,
	output logic        alu_src1_o,    // choose src (PC/rs1)
	output logic        alu_src2_o,    // choose src (imm/rs2)
	output logic        mem_write_o, 
	output logic [1:0]  rd_src_o,
	output logic [4:0]  branch_control_o,    //bit 4-3 : signal branch , bit2-0: funct 3
	output logic        insn_vld_o,
	output logic [2:0]  lsu_control_o 
);
//==== rd src ====
//00 : result from alu
//01 : read mem
//10 : PC + 4
//11 : imm
// alu control 

logic [3:0] alu_control_inst , ad_sb_R_type;
assign ad_sb_R_type = (inst_i[30])? 4'b0110 : 4'b0010; // sub : add
always_comb begin
  case (inst_i[14:12]) //funct 3
    3'b000:  alu_control_inst = (inst_i[5])? ad_sb_R_type : 4'b0010; // R-type " I-type" 
    3'b100:  alu_control_inst = 4'b0011;                             // Xor
    3'b110:  alu_control_inst = 4'b0001;                             // Or
    3'b111:  alu_control_inst = 4'b0000;                             // And
    3'b001:  alu_control_inst = 4'b1001;                             // Sll
    3'b101:  alu_control_inst = (inst_i[30])? 4'b1010 : 4'b1000;     // sra : srl
    3'b010:  alu_control_inst = 4'b0111;                             // slt
    3'b011:  alu_control_inst = 4'b0100;                             // sltu
    default: alu_control_inst = 4'b0000;
  endcase
end

always_comb begin : inst_valid
  case(inst_i[6:0])
    7'b0110011,
    7'b0010011,
    7'b0000011,
    7'b0100011,
    7'b1100011,
    7'b1101111,
    7'b0110111,
    7'b0010111: insn_vld_o = 1'b1;
    default: insn_vld_o = 1'b0;
  endcase
end

always_comb begin
  case (inst_i[6:0])
    7'b0110011: begin  // R-type
      regwrite_o       = 1'b1;
      alu_src1_o       = 1'b0;
	  alu_src2_o       = 1'b0;
      mem_write_o      = 1'b0;
      alu_control_o    = alu_control_inst;
	  rd_src_o         = 2'b00;
	  branch_control_o = 5'b00000;
	  lsu_control_o    = 3'b000;
	end
	7'b0010011: begin  // I-type
	  regwrite_o       = 1'b1;
	  alu_src1_o       = 1'b0;
	  alu_src2_o       = 1'b1;
	  mem_write_o      = 1'b0;
	  alu_control_o    = alu_control_inst;
	  rd_src_o         = 2'b00;
	  branch_control_o = 5'b00000;
	  lsu_control_o    = 3'b000;
	end 
	7'b0000011: begin  // I-type (L)
	  regwrite_o       = 1'b1;
	  alu_src1_o       = 1'b0;
	  alu_src2_o       = 1'b1;
	  mem_write_o      = 1'b0;
	  alu_control_o    = 4'b0010; // add 
	  rd_src_o         = 2'b01;
	  branch_control_o = 5'b00000;
	  lsu_control_o    = inst_i[14:12]; // funct3
	end
	7'b0100011: begin  // S-type
	  regwrite_o       = 1'b0;
	  alu_src1_o       = 1'b0;
	  alu_src2_o       = 1'b1;
	  mem_write_o      = 1'b1;
	  alu_control_o    = 4'b0010; // add
	  rd_src_o         = 2'bxx; 
	  branch_control_o = 5'b00000;
	  lsu_control_o    = inst_i[14:12]; // funct3
	end
	7'b1100011: begin  // B-type
	  regwrite_o       = 1'b0;	
	  alu_src1_o       = 1'b1;
	  alu_src2_o       = 1'b1;
	  mem_write_o      = 1'b0;
	  alu_control_o    = 4'b0010; // adđ
	  rd_src_o         = 2'bxx; 
	  branch_control_o = {2'b11,inst_i[14:12]}; //funct3
	  lsu_control_o    = 3'b000;
	end
	7'b1101111: begin  // J-type
	  regwrite_o       = 1'b1;	
	  alu_src1_o       = 1'b1;
	  alu_src2_o       = 1'b1;
	  mem_write_o      = 1'b0;
	  alu_control_o    = 4'b0010; //add
	  rd_src_o         = 2'b10; 
	  branch_control_o = 5'b10000;
	  lsu_control_o    = 3'b000;
	end
	7'b1100111: begin  // I-type (jalr)
	  regwrite_o       = 1'b1;
	  alu_src1_o       = 1'b0;
	  alu_src2_o       = 1'b1;
	  mem_write_o      = 1'b0;
	  alu_control_o    = 4'b0010; // add
	  rd_src_o         = 2'b10; 
	  branch_control_o = 5'b10000;
	  lsu_control_o    = 3'b000;
	end
	7'b0110111,
	7'b0010111: begin  // U-type
	  regwrite_o       = 1'b1;
	  alu_src1_o       = 1'b1;
	  alu_src2_o       = 1'b1;
	  mem_write_o      = 1'b0;
	  alu_control_o    = 4'b0010; // add
	  rd_src_o         = (inst_i[5])? 2'b11 : 2'b00; 
	  branch_control_o = 5'b00000; 
	  lsu_control_o    = 3'b000;
	end
	default:    begin   
	  regwrite_o       = 1'b0;
      alu_src1_o       = 1'b0;
	  alu_src2_o       = 1'b0;
      mem_write_o      = 1'b0;
      alu_control_o    = alu_control_inst;
	  rd_src_o         = 2'b00;
	  branch_control_o = 5'b00000;
	  lsu_control_o    = 3'b000;
	end
  endcase
end
endmodule
