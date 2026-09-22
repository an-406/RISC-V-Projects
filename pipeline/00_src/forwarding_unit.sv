//======================================
//Module : forwarding unit 
//Name   : An
//Date   : 17/09/2026
//======================================
module forwarding_unit (
    input  logic [4:0]  ex_addr_rs1,
    input  logic [4:0]  ex_addr_rs2,
    input  logic [4:0]  mem_addr_rd,
    input  logic [4:0]  wb_addr_rd, 

    input  logic        mem_regwrite,
    input  logic        wb_regwrite,
    input  logic [1:0]  rd_src,
    // data forwarding
    input  logic [31:0] result_alu , imm , pc_plus4 , rd,

    output logic [31:0] data_fw_a , data_fw_b,
    output logic [2:0]  fa_sig , fb_sig
);

// ===================== MEM HAZARD =====================
logic [4:0] zero_mem_rs1 , zero_mem_rs2;
logic       zero_rs1 , zero_rs2;
logic       is_addr_mem_zero;
logic       is_mem_hazard_a , is_mem_hazard_b;
always_comb begin : check_equal_mem_block
  // ex_addr_rs1 == mem_addr_rd ?
  zero_mem_rs1[0] = ex_addr_rs1[0]^mem_addr_rd[0];
  zero_mem_rs1[1] = ex_addr_rs1[1]^mem_addr_rd[1];
  zero_mem_rs1[2] = ex_addr_rs1[2]^mem_addr_rd[2];
  zero_mem_rs1[3] = ex_addr_rs1[3]^mem_addr_rd[3];
  zero_mem_rs1[4] = ex_addr_rs1[4]^mem_addr_rd[4];
  // ex_addr_rs2 == mem_addr_rd ?
  zero_mem_rs2[0] = ex_addr_rs2[0]^mem_addr_rd[0];
  zero_mem_rs2[1] = ex_addr_rs2[1]^mem_addr_rd[1];
  zero_mem_rs2[2] = ex_addr_rs2[2]^mem_addr_rd[2];
  zero_mem_rs2[3] = ex_addr_rs2[3]^mem_addr_rd[3];
  zero_mem_rs2[4] = ex_addr_rs2[4]^mem_addr_rd[4];

  zero_rs1 = ~(zero_mem_rs1[0] | zero_mem_rs1[1] | zero_mem_rs1[2] | zero_mem_rs1[3] | zero_mem_rs1[4]); 
  zero_rs2 = ~(zero_mem_rs2[0] | zero_mem_rs2[1] | zero_mem_rs2[2] | zero_mem_rs2[3] | zero_mem_rs2[4]); 
end

// check addr_rd == rs0 ?
assign is_addr_mem_zero = ~|mem_addr_rd;
// is mem_hazard ?
assign is_mem_hazard_a = is_addr_mem_zero & zero_mem_rs1 & mem_regwrite;
assign is_mem_hazard_b = is_addr_mem_zero & zero_mem_rs2 & mem_regwrite;
// ======================================================


// ===================== WB HAZARD =====================
logic [4:0] zero_wb_rs1 , zero_wb_rs2;
logic       zr_rs1 , zr_rs2;
logic       is_addr_wb_zero;
logic       is_wb_hazard_a , is_wb_hazard_b;
always_comb begin : check_equal_wb_block
  // ex_addr_rs1 == mem_addr_rd ?
  zero_wb_rs1[0] = ex_addr_rs1[0]^wb_addr_rd[0];
  zero_wb_rs1[1] = ex_addr_rs1[1]^wb_addr_rd[1];
  zero_wb_rs1[2] = ex_addr_rs1[2]^wb_addr_rd[2];
  zero_wb_rs1[3] = ex_addr_rs1[3]^wb_addr_rd[3];
  zero_wb_rs1[4] = ex_addr_rs1[4]^wb_addr_rd[4];
  // ex_addr_rs2 == mem_addr_rd ?
  zero_wb_rs2[0] = ex_addr_rs2[0]^wb_addr_rd[0];
  zero_wb_rs2[1] = ex_addr_rs2[1]^wb_addr_rd[1];
  zero_wb_rs2[2] = ex_addr_rs2[2]^wb_addr_rd[2];
  zero_wb_rs2[3] = ex_addr_rs2[3]^wb_addr_rd[3];
  zero_wb_rs2[4] = ex_addr_rs2[4]^wb_addr_rd[4];

  zr_rs1 = ~(zero_wb_rs1[0] | zero_wb_rs1[1] | zero_wb_rs1[2] | zero_wb_rs1[3] | zero_wb_rs1[4]); 
  zr_rs2 = ~(zero_wb_rs2[0] | zero_wb_rs2[1] | zero_wb_rs2[2] | zero_wb_rs2[3] | zero_wb_rs2[4]); 
end
// check addr_rd == rs0 ?
assign is_addr_wb_zero = ~|wb_addr_rd;
// is mem_hazard ?
assign is_wb_hazard_a = is_addr_wb_zero & zero_wb_rs1 & wb_regwrite & is_mem_hazard_a;
assign is_wb_hazard_b = is_addr_wb_zero & zero_wb_rs2 & wb_regwrite & is_mem_hazard_b;
// ====================================================


// DATA FORWARDING
logic [31:0] rd_fw;
mux_4_1 # (
    .WIDTH(32)
) mx_1 (
  .A_i(result_alu),
  .B_i('0),//
  .C_i(pc_plus4),
  .D_i(imm),
  .sel_i(rd_src),
  .D_o(rd_fw)
);
assign data_fw_a = (is_mem_hazard_a) ? rd_fw : rd;
assign data_fw_b = (is_mem_hazard_b) ? rd_fw : rd;


// IS FORWARDING ? 
assign fa_sig = is_mem_hazard_a | is_wb_hazard_a;
assign fb_sig = is_mem_hazard_b | is_wb_hazard_b;

endmodule : forwarding_unit
