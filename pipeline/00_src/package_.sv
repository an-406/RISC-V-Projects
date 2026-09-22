package package_;
   typedef logic [31:0] bits_32;
   typedef logic [4:0]  bits_5;

   typedef struct packed {
      bits_32 curr_pc;
      bits_32 pc_plus4;
      bits_32 inst;
      logic   insn_vld_o;
   } if_id_reg_t;

   typedef struct packed {
      bits_32     curr_pc;
      bits_32     pc_plus4;

      logic [3:0] alu_control; 
      logic       alu_src1;    
      logic       alu_src2;
      bits_5      branch_control;

      logic       mem_write; 
      logic [2:0] lsu_control;

      logic [1:0] rd_src; 
      logic       regwrite;

      bits_32     rs1;
      bits_32     rs2;
      bits_32     imm;

      bits_5      addr_rd;
      bits_5      addr_rs1;
      bits_5      addr_rs2;
      logic       insn_vld_o; 
   } id_ex_reg_t;

   typedef struct packed {
      bits_32     pc_plus4;

      logic       mem_write; 
      logic [2:0] lsu_control;

      logic [1:0] rd_src; 
      logic       regwrite;

      bits_32     rs2;
      bits_32     imm;
      bits_32     result_alu;

      bits_5      addr_rd;
      logic       insn_vld_o; 
   } ex_mem_reg_t;

   typedef struct packed {
      bits_32     pc_plus4;

      logic [1:0] rd_src; 
      logic       regwrite;

      bits_32     result_alu;
      bits_32     imm;
      bits_32     read_data;

      bits_5      addr_rd;
      logic       insn_vld_o; 
   } mem_wb_reg_t;

endpackage
