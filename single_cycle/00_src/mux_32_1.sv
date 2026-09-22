//======================================
//Module : MUX 32-1
//Name   : An
//Date   : 18/06/2026
//Update : 02/07/2026
//======================================
module mux_32_1 #(
    parameter WIDTH = 4
) (
    input  logic [WIDTH-1:0]       A_i [31:0], 
    input  logic [4:0]             sel_i,
    output logic [WIDTH-1:0]       D_o
);

// STAGE 1 : 16 MUX 2:1
logic [WIDTH-1:0] D1_r_0,  D2_r_0,  D3_r_0,  D4_r_0,  D5_r_0,  D6_r_0,  D7_r_0,  D8_r_0, D9_r_0,  D10_r_0, D11_r_0, D12_r_0, D13_r_0, D14_r_0, D15_r_0, D16_r_0;
assign D1_r_0  = (sel_i[0]) ? A_i[1]  : A_i[0]; 
assign D2_r_0  = (sel_i[0]) ? A_i[3]  : A_i[2]; 
assign D3_r_0  = (sel_i[0]) ? A_i[5]  : A_i[4];  
assign D4_r_0  = (sel_i[0]) ? A_i[7]  : A_i[6];  
assign D5_r_0  = (sel_i[0]) ? A_i[9]  : A_i[8];  
assign D6_r_0  = (sel_i[0]) ? A_i[11] : A_i[10];
assign D7_r_0  = (sel_i[0]) ? A_i[13] : A_i[12]; 
assign D8_r_0  = (sel_i[0]) ? A_i[15] : A_i[14]; 
assign D9_r_0  = (sel_i[0]) ? A_i[17] : A_i[16]; 
assign D10_r_0 = (sel_i[0]) ? A_i[19] : A_i[18]; 
assign D11_r_0 = (sel_i[0]) ? A_i[21] : A_i[20]; 
assign D12_r_0 = (sel_i[0]) ? A_i[23] : A_i[22]; 
assign D13_r_0 = (sel_i[0]) ? A_i[25] : A_i[24]; 
assign D14_r_0 = (sel_i[0]) ? A_i[27] : A_i[26]; 
assign D15_r_0 = (sel_i[0]) ? A_i[29] : A_i[28]; 
assign D16_r_0 = (sel_i[0]) ? A_i[31] : A_i[30];

// STAGE 2 : 8 MUX 2:1
logic [WIDTH-1:0] D1_r_1, D2_r_1, D3_r_1, D4_r_1, D5_r_1, D6_r_1, D7_r_1, D8_r_1;
assign D1_r_1 = (sel_i[1]) ? D2_r_0  : D1_r_0;
assign D2_r_1 = (sel_i[1]) ? D4_r_0  : D3_r_0;
assign D3_r_1 = (sel_i[1]) ? D6_r_0  : D5_r_0;
assign D4_r_1 = (sel_i[1]) ? D8_r_0  : D7_r_0;
assign D5_r_1 = (sel_i[1]) ? D10_r_0 : D9_r_0;
assign D6_r_1 = (sel_i[1]) ? D12_r_0 : D11_r_0;
assign D7_r_1 = (sel_i[1]) ? D14_r_0 : D13_r_0;
assign D8_r_1 = (sel_i[1]) ? D16_r_0 : D15_r_0;

// STAGE 3 : 4 MUX 2:1
logic [WIDTH-1:0] D1_r_2, D2_r_2, D3_r_2, D4_r_2;
assign D1_r_2 = (sel_i[2]) ? D2_r_1 : D1_r_1;
assign D2_r_2 = (sel_i[2]) ? D4_r_1 : D3_r_1;
assign D3_r_2 = (sel_i[2]) ? D6_r_1 : D5_r_1;
assign D4_r_2 = (sel_i[2]) ? D8_r_1 : D7_r_1;

// STAGE 4 : 2 MUX 2:1 
logic [WIDTH-1:0] D1_r_3, D2_r_3;
assign D1_r_3 = (sel_i[3]) ? D2_r_2 : D1_r_2;
assign D2_r_3 = (sel_i[3]) ? D4_r_2 : D3_r_2;

// STAGE 5 : 1 MUX 2:1 
assign D_o = (sel_i[4]) ? D2_r_3 : D1_r_3;

endmodule : mux_32_1
