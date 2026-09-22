//======================================
//Module : MUX 2-1
//Name   : An
//Date   : 15/06/2026
//======================================
module mux_2_1 #(
    parameter WIDTH = 4
) (
    input  logic [WIDTH-1:0] A_i,
    input  logic [WIDTH-1:0] B_i,
    input  logic             sel_i,
    output logic [WIDTH-1:0] D_o
);
assign D_o = (sel_i)? B_i : A_i;  
endmodule :mux_2_1