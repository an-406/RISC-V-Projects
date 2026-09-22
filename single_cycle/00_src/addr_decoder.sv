//======================================
//Module : address decoder
//Name   : An
//Date   : 18/07/2026
//Update : 02/08/2026
//======================================
module addr_decoder (
    input  logic [31:0] alu_addr_i,
    output logic        sw_cs_o,
    output logic        lcd_cs_o,
    output logic        seg1_cs_o,
    output logic        seg0_cs_o,
    output logic        greled_cs_o,
    output logic        reled_cs_o,
    output logic        mem_cs_o
);

always_comb begin
  sw_cs_o     = alu_addr_i[28] &   alu_addr_i[16]  & ~(alu_addr_i[14]) & ~(alu_addr_i[13]) & ~(alu_addr_i[12]);
  lcd_cs_o    = alu_addr_i[28] & ~(alu_addr_i[16]) &   alu_addr_i[14]  & ~(alu_addr_i[13]) & ~(alu_addr_i[12]);
  seg1_cs_o   = alu_addr_i[28] & ~(alu_addr_i[16]) & ~(alu_addr_i[14]) &   alu_addr_i[13]  &   alu_addr_i[12];
  seg0_cs_o   = alu_addr_i[28] & ~(alu_addr_i[16]) & ~(alu_addr_i[14]) &   alu_addr_i[13]  & ~(alu_addr_i[12]);
  greled_cs_o = alu_addr_i[28] & ~(alu_addr_i[16]) & ~(alu_addr_i[14]) & ~(alu_addr_i[13]) &   alu_addr_i[12];
  reled_cs_o  = alu_addr_i[28] & ~(alu_addr_i[16]) & ~(alu_addr_i[14]) & ~(alu_addr_i[13]) & ~(alu_addr_i[12]);
  mem_cs_o    = ~(alu_addr_i[28]) & ~(alu_addr_i[11]);
end
endmodule : addr_decoder
