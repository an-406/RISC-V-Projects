//======================================
//Module : Instruction memory
//Name   : An
//Date   : 06/07/2026
//======================================
module imem (
    input  logic [31:0] addr_i,
    output logic [31:0] inst_o
);
logic [31:0] mem [0:8095];
initial begin
    $readmemh("/home/albert/LAB/02_test/isa_4b.hex",mem);
end
assign inst_o = mem[addr_i[31:2]];
endmodule
