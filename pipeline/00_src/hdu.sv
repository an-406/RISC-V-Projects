//======================================
//Module : hazard dectection unit
//Name   : An
//Date   : 14/09/2026
//======================================
module hdu (
    input  logic        is_ex_memread,
    input  logic        id_opcode,
    input  logic [4:0]  id_addr_rs1,
    input  logic [4:0]  id_addr_rs2,
    input  logic [4:0]  ex_addr_rd,
    
    output logic        stalled
);

logic [4:0] zr_rs1 , zr_rs2;
logic       is_zr;
always_comb begin : check_equal_block
  zr_rs1 = id_addr_rs1 ^ ex_addr_rd;
  zr_rs2 = id_addr_rs2 ^ ex_addr_rd; 
end

always_comb begin
  case (id_opcode)
    0010011,
    0000011,
    1100111: is_zr = ~| zr_rs1;
    0110111,
    0010111,
    1101111: is_zr = 1'b0;
    default: is_zr = (~| zr_rs1) | (~| zero_rs2); 
  endcase 
end

logic       is_addr_rd_zero;
assign is_addr_rd_zero = ~| ex_addr_rd;


assign stalled = is_addr_rd_zero & is_zr & is_ex_memread;
endmodule
