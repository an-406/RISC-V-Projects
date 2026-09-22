//======================================
//Module : MUX 4-1
//Name   : An
//Date   : 28/06/2026
//======================================
module mux_4_1 #(
    parameter WIDTH = 4
) (
    input  logic [WIDTH-1:0] A_i,
    input  logic [WIDTH-1:0] B_i,
    input  logic [WIDTH-1:0] C_i,
    input  logic [WIDTH-1:0] D_i,
    input  logic [1:0]       sel_i,
    output logic [WIDTH-1:0] D_o
);
logic [WIDTH-1:0] D1_r , D2_r;

assign D1_r = (sel_i[0])? B_i  :  A_i;
assign D2_r = (sel_i[0])? D_i  :  C_i;

assign D_o  = (sel_i[1])? D2_r : D1_r;

endmodule : mux_4_1 
    
