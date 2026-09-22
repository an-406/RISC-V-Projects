//======================================
//Module : single cycle
//Name   : An
//Date   : 24/07/2026
//======================================
module single_cycle (
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
// ==== Program counter ====
logic [31:0] pc_next_i;
logic [31:0] pc;
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
        pc <= 32'h0000_0000;
    else
        pc <= pc_next_i;
end
assign pc_debug_o = pc;
// ==== instruction memory ====
logic [31:0] inst;
imem u_im0 (
    .addr_i(pc),
    .inst_o(inst)
);
// ==== control unit ==== 
logic [3:0]  alu_control; 
logic        regwrite;
logic        alu_src1;    
logic        alu_src2;    
logic        mem_write; 
logic [1:0]  rd_src;
logic [4:0]  branch_control; 
logic [2:0]  lsu_control;
control_unit u_cu0 (
    .inst_i(inst),
    .alu_control_o(alu_control),
    .regwrite_o(regwrite),
    .alu_src1_o(alu_src1),
    .alu_src2_o(alu_src2),
    .mem_write_o(mem_write),
    .rd_src_o(rd_src),
    .branch_control_o(branch_control),
    .insn_vld_o(insn_vld_o),
    .lsu_control_o(lsu_control)
);  
// ==== register file ==== 
logic [31:0] rd;
logic [31:0] rs1 , rs2 ;
register_file u_rf0 (
    .regwrite_i(regwrite),
    .write_reg_num_i(inst[11:7]),
    .read_reg_num1_i(inst[19:15]),
    .read_reg_num2_i(inst[24:20]),
    .reg_data_i(rd),
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .rs1_o(rs1),
    .rs2_o(rs2)
);
// ==== immgen ====
logic [31:0] imm;
immgen u_ig0 (
    .inst_i(inst),
    .imm_o(imm)
);
// ==== alu ==== 
logic [31:0] src_alu_1 , src_alu_2 ;
assign src_alu_1 = (alu_src1)? pc_debug_o : rs1; // alu src 1
assign src_alu_2 = (alu_src2)? imm  : rs2; // alu src 2
logic [31:0] result_alu ; 
alu u_al0 (
    .rs1_i(src_alu_1),
    .rs2_i(src_alu_2),
    .alu_control_i(alu_control),
    .rd_o(result_alu)
);
// ==== brc ====
logic jump_control;
brc u_br0 (
    .rs1_i(rs1),
    .rs2_i(rs2),
    .brc_control_i(branch_control),
    .jump_control_o(jump_control)
);
logic [31:0] pc_1;
add u_ad0 (
    .A_i(32'h0000_0004),
    .B_i(pc),
    .S_o(pc_1)
);
assign pc_next_i = (jump_control)? result_alu : pc_1;
// ==== load store unit ====
logic [31:0] read_data;
lsu u_ls0 (
    .lsu_control_i(lsu_control),
    .alu_addr_i(result_alu),  
    .writemem_i(rs2),
    .sw_i(sw_i),
    .memwrite_i(mem_write),
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
// ==== rd src ====
mux_4_1 #(
    .WIDTH(32)
) u_mu0 (
    .A_i(result_alu),
    .B_i(read_data),
    .C_i(pc_1),
    .D_i(imm),
    .sel_i(rd_src),
    .D_o(rd)
); 
endmodule : single_cycle
