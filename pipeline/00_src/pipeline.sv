//======================================
//Module         : pipeline  (forwarding) 
//Control Hazard : Branch not taken
//Name           : An
//Date           : 22/09/2026
//======================================
import package_::*;
module pipeline (
    input  logic        clk_i ,
    input  logic        rst_ni,
    output logic [31:0] pc_debug_o,
    output logic        insn_vld_o,
    output logic [31:0] ledr_o,
    output logic [31:0] ledg_o,
    output logic [6:0]  hex0_o , hex1_o , hex2_o , hex3_o,
    output logic [6:0]  hex4_o , hex5_o , hex6_o , hex7_o,
    output logic [31:0] lcd_o,
    input  logic [31:0] sw_i 
);

if_id_reg_t  if_id_reg , if_id_reg_next;
id_ex_reg_t  id_ex_reg , id_ex_reg_next;
ex_mem_reg_t ex_mem_reg , ex_mem_reg_next;
mem_wb_reg_t mem_wb_reg , mem_wb_reg_next;




logic [31:0] result_alu; 
logic        stalled;
logic        flush;


// ==== Program counter ====
logic [31:0] next_pc ;
logic [31:0] curr_pc;
always_ff @(posedge clk_i or negedge rst_ni) begin
  if (~rst_ni)
    curr_pc <= 32'h0000_0000;
  else if(stalled)
    curr_pc <= curr_pc;
  else
    curr_pc <= next_pc;
end
assign pc_debug_o = curr_pc;
// ==== instruction memory ====
logic [31:0] inst;
imem u_im0 (
    .addr_i(curr_pc),
    .inst_o(inst)
);

// ==== Program counter src ====
logic jump_control;
logic [31:0] pc_plus4;
add u_ad0 (
    .A_i(32'h0000_0004),
    .B_i(curr_pc),
    .S_o(pc_plus4)
);
assign next_pc = (jump_control)? result_alu : pc_plus4;

//======================== IF/ID Register ===========================
always_comb begin 
  if_id_reg_next.curr_pc  = curr_pc;
  if_id_reg_next.pc_plus4 = pc_plus4;
  if_id_reg_next.inst     = inst;
end

always_ff @( posedge clk_i or negedge rst_ni ) begin : IF_ID_Register
  if(~rst_ni | flush) begin // if taken , then flush
    if_id_reg <= 0;
  end   
  else if(stalled) begin
    if_id_reg <= if_id_reg;
  end 
  else begin
    if_id_reg <= if_id_reg_next;
  end
end
//====================================================================


logic [4:0]  addr_rd , addr_rs1 , addr_rs2;
assign addr_rd  = if_id_reg.inst[11:7];
assign addr_rs1 = if_id_reg.inst[19:15];
assign addr_rs2 = if_id_reg.inst[24:20]; 
// ==== hazard detection unit ====
hdu hdu_1 (
  .is_ex_memread(~id_ex_reg.mem_write),
  .id_opcode(if_id_reg_next.inst[6:0]),
  .id_addr_rs1(addr_rs1),
  .id_addr_rs2(addr_rs2),
  .ex_addr_rd(addr_rd),
  .stalled(stalled)
);

// ==== control unit ==== 
// EX
logic [3:0]  alu_control; 
logic        alu_src1;    
logic        alu_src2;
logic [4:0]  branch_control;

//MEM  
logic        mem_write; 
logic [2:0]  lsu_control;

//WB
logic [1:0]  rd_src; 
logic        regwrite;
control_unit u_cu0 (
    .inst_i(if_id_reg.inst),
    .insn_vld_o(insn_vld_o),
    .nop_cu(stalled),
    // EX
    .alu_control_o(alu_control),
    .alu_src1_o(alu_src1),
    .alu_src2_o(alu_src2),
    .branch_control_o(branch_control),

    //MEM
    .mem_write_o(mem_write),
    .lsu_control_o(lsu_control),
    //WB
    .regwrite_o(regwrite),
    .rd_src_o(rd_src)
);  

logic [31:0] rd;
// ==== register file ==== 
logic [31:0] rs1; 
logic [31:0] rs2;

register_file u_rf0 (
    .regwrite_i(mem_wb_reg.regwrite),
    .write_reg_num_i(mem_wb_reg.addr_rd),
    .read_reg_num1_i(addr_rs1),
    .read_reg_num2_i(addr_rs2),
    .reg_data_i(rd),
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .rs1_o(rs1),
    .rs2_o(rs2)
);
// ==== immgen ====
logic [31:0] imm;
immgen u_ig0 (
    .inst_i(if_id_reg.inst),
    .imm_o(imm)
);

//======================== ID/EX Register ===========================
always_comb begin 
  id_ex_reg_next.curr_pc  = if_id_reg.curr_pc;
  id_ex_reg_next.pc_plus4 = if_id_reg.pc_plus4;

  id_ex_reg_next.alu_control    = alu_control;
  id_ex_reg_next.alu_src1       = alu_src1;
  id_ex_reg_next.alu_src2       = alu_src2;
  id_ex_reg_next.branch_control = branch_control;

  id_ex_reg_next.mem_write   = mem_write;
  id_ex_reg_next.lsu_control = lsu_control;
  
  id_ex_reg_next.rd_src   = rd_src;
  id_ex_reg_next.regwrite = regwrite;
  
  id_ex_reg_next.rs1 = rs1;
  id_ex_reg_next.rs2 = rs2;
  id_ex_reg_next.imm = imm;

  id_ex_reg_next.addr_rd    = addr_rd;
  id_ex_reg_next.addr_rs1   = addr_rs1;
  id_ex_reg_next.addr_rs2   = addr_rs2;
  id_ex_reg_next.insn_vld_o = insn_vld_o;
end

always_ff @( posedge clk_i or negedge rst_ni ) begin : ID_EX_Register
    if(~rst_ni | flush) begin // if taken , then flush
        id_ex_reg <= '0;
    end    
    else begin
        id_ex_reg <= id_ex_reg_next;
    end
end
//====================================================================
// ==== forwarding ====
logic [31:0] data_fw_a , data_fw_b;
logic        fa_sig    , fb_sig   ;
forwarding_unit fw_0 (
  .ex_addr_rs1(id_ex_reg.addr_rs1),
  .ex_addr_rs2(id_ex_reg.addr_rs2),
  .mem_addr_rd(ex_mem_reg.addr_rd),
  .wb_addr_rd(mem_wb_reg.addr_rd),

  .mem_regwrite(ex_mem_reg.regwrite),
  .wb_regwrite(mem_wb_reg.regwrite),
  .rd_src(ex_mem_reg.rd_src),

  .result_alu(ex_mem_reg.result_alu),
  .imm(ex_mem_reg.imm),
  .pc_plus4(ex_mem_reg.pc_plus4),
  .rd(rd),

  .data_fw_a(data_fw_a),
  .data_fw_b(data_fw_b),
  .fa_sig(fa_sig),
  .fb_sig(fb_sig)
);
// ==== alu ==== 
logic [31:0] src_alu_1 , src_alu_2 ;

logic [31:0] rs1_data , rs2_data;

assign rs1_data = (fa_sig) ? data_fw_a : id_ex_reg.rs1;
assign rs2_data = (fb_sig) ? data_fw_b : id_ex_reg.rs2;

assign src_alu_1 = (id_ex_reg.alu_src1)? id_ex_reg.curr_pc : rs1_data; // alu src 1
assign src_alu_2 = (id_ex_reg.alu_src2)? id_ex_reg.imm  : rs2_data; // alu src 2

alu u_al0 (
    .rs1_i(src_alu_1),
    .rs2_i(src_alu_2),
    .alu_control_i(id_ex_reg.alu_control),
    .rd_o(result_alu)
);
// ==== brc ====
brc u_br0 (
    .rs1_i(data_fw_a),
    .rs2_i(data_fw_b),
    .brc_control_i(id_ex_reg.branch_control),
    .jump_control_o(jump_control)
);
assign flush = jump_control;
//======================== EX/MEM Register ===========================
always_comb begin 
  ex_mem_reg_next.pc_plus4 = id_ex_reg.pc_plus4;

  ex_mem_reg_next.mem_write   = id_ex_reg.mem_write;
  ex_mem_reg_next.lsu_control = id_ex_reg.lsu_control;
  
  ex_mem_reg_next.rd_src   = id_ex_reg.rd_src;
  ex_mem_reg_next.regwrite = id_ex_reg.regwrite;
  
  ex_mem_reg_next.rs2        = id_ex_reg.rs2;
  ex_mem_reg_next.imm        = id_ex_reg.imm;
  ex_mem_reg_next.result_alu = result_alu;

  ex_mem_reg_next.addr_rd    = id_ex_reg.addr_rd;
  ex_mem_reg_next.insn_vld_o = id_ex_reg.insn_vld_o;
end

always_ff @( posedge clk_i or negedge rst_ni ) begin : EX_MEM_Register
    if(~rst_ni) begin
        ex_mem_reg <= '0;
    end    
    else begin
        ex_mem_reg <= ex_mem_reg_next;
    end
end
//====================================================================

// ==== load store unit ====
logic [31:0] read_data;
lsu u_ls0 (
    .lsu_control_i(ex_mem_reg.lsu_control),
    .alu_addr_i(ex_mem_reg.result_alu),  
    .writemem_i(ex_mem_reg.rs2),
    .sw_i(sw_i),
    .memwrite_i(ex_mem_reg.mem_write),
    .clk_i(clk_i), 
    .rst_ni(rst_ni),
    .readdata_o(read_data),
    .lcd_o(lcd_o),
    .ledr_o(ledr_o),
    .ledg_o(ledg_o),
    .hex0_o(hex0_o),
    .hex1_o(hex1_o),
    .hex2_o(hex2_o),
    .hex3_o(hex3_o),
    .hex4_o(hex4_o),
    .hex5_o(hex5_o),
    .hex6_o(hex6_o),
    .hex7_o(hex7_o)
);

//======================== MEM/WB Register ===========================
always_comb begin 
  mem_wb_reg_next.pc_plus4 = ex_mem_reg.pc_plus4;
  
  mem_wb_reg_next.rd_src   = ex_mem_reg.rd_src;
  mem_wb_reg_next.regwrite = ex_mem_reg.regwrite;
  
  mem_wb_reg_next.imm        = ex_mem_reg.imm;
  mem_wb_reg_next.result_alu = ex_mem_reg.result_alu;
  mem_wb_reg_next.read_data  = read_data;

  mem_wb_reg_next.addr_rd    = ex_mem_reg.addr_rd;
  mem_wb_reg_next.insn_vld_o = ex_mem_reg.insn_vld_o;
end

always_ff @( posedge clk_i or negedge rst_ni ) begin : MEM_WB_Register
    if(~rst_ni) begin
        mem_wb_reg <= '0;
    end    
    else begin
        mem_wb_reg <= mem_wb_reg_next;
    end
end
//====================================================================

// ==== rd src ====
mux_4_1 #(
    .WIDTH(32)
) u_mu0 (
    .A_i(mem_wb_reg.result_alu),
    .B_i(mem_wb_reg.read_data),
    .C_i(mem_wb_reg.pc_plus4),
    .D_i(mem_wb_reg.imm),
    .sel_i(mem_wb_reg.rd_src),
    .D_o(rd)
); 
endmodule : pipeline
