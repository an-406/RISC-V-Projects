//======================================
//Module : Branch Unit 
//Name   : An
//Date   : 05/07/2026
//Update : 11/07/2026
//======================================
module brc (
    input  logic [31:0] rs1_i,
    input  logic [31:0] rs2_i,
    input  logic [4:0]  brc_control_i,
    output logic        jump_control_o
);
//===bit 2-0 : funct 3===
//000: zero
//001: not zero
//100: set less than 
//101: set greater than or equal 
//110: set less than (U)
//111: set greater than or equal (U)
//=== Variable ===
logic        signal_brc_st;
logic        v , c , zero;
logic [31:0] result;
add_subtract u_as0 (
  .A_i(rs1_i),
  .B_i(~rs2_i),
  .C_i(1'b1),
  .S_o(result),
  .C_o(c),
  .V_o(v)
);
assign zero = ~|result;
always_comb begin
  case (brc_control_i[2:0])
    3'b000: signal_brc_st = zero;
    3'b001: signal_brc_st = ~zero;
    3'b100: signal_brc_st = result[31]^v;
    3'b101: signal_brc_st = ~(result[31]^v);
    3'b110: signal_brc_st = ~c;
    3'b111: signal_brc_st =  c;
    default: signal_brc_st = 1'b0;
  endcase
end
// bit 4-3: branch control 
always_comb begin
  case(brc_control_i[4:3])
  2'b10   : begin
    jump_control_o = 1'b1;
  end
  2'b11   : begin
    jump_control_o = signal_brc_st;
  end
  default : begin
    jump_control_o = 1'b0; 
  end
  endcase
end
endmodule : brc
