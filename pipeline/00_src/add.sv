//======================================
//Module : Add ( 32-bit)
//Name   : An
//Date   : 17/07/2026
//======================================
module add (
    input  logic [31:0] A_i,
    input  logic [31:0] B_i,
    output logic [31:0] S_o
);

logic [31:0] C_fd;

full_adder u_fa0(.A_i(A_i[0]),.B_i(B_i[0]),.C_i(1'b0),.S_o(S_o[0]),.C_o(C_fd[0]));
full_adder u_fa1(.A_i(A_i[1]),.B_i(B_i[1]),.C_i(C_fd[0]),.S_o(S_o[1]),.C_o(C_fd[1]));
full_adder u_fa2(.A_i(A_i[2]),.B_i(B_i[2]),.C_i(C_fd[1]),.S_o(S_o[2]),.C_o(C_fd[2]));
full_adder u_fa3(.A_i(A_i[3]),.B_i(B_i[3]),.C_i(C_fd[2]),.S_o(S_o[3]),.C_o(C_fd[3]));
full_adder u_fa4(.A_i(A_i[4]),.B_i(B_i[4]),.C_i(C_fd[3]),.S_o(S_o[4]),.C_o(C_fd[4]));
full_adder u_fa5(.A_i(A_i[5]),.B_i(B_i[5]),.C_i(C_fd[4]),.S_o(S_o[5]),.C_o(C_fd[5]));
full_adder u_fa6(.A_i(A_i[6]),.B_i(B_i[6]),.C_i(C_fd[5]),.S_o(S_o[6]),.C_o(C_fd[6]));
full_adder u_fa7(.A_i(A_i[7]),.B_i(B_i[7]),.C_i(C_fd[6]),.S_o(S_o[7]),.C_o(C_fd[7]));
full_adder u_fa8(.A_i(A_i[8]),.B_i(B_i[8]),.C_i(C_fd[7]),.S_o(S_o[8]),.C_o(C_fd[8]));
full_adder u_fa9(.A_i(A_i[9]),.B_i(B_i[9]),.C_i(C_fd[8]),.S_o(S_o[9]),.C_o(C_fd[9]));
full_adder u_fa10(.A_i(A_i[10]),.B_i(B_i[10]),.C_i(C_fd[9]),.S_o(S_o[10]),.C_o(C_fd[10]));
full_adder u_fa11(.A_i(A_i[11]),.B_i(B_i[11]),.C_i(C_fd[10]),.S_o(S_o[11]),.C_o(C_fd[11]));
full_adder u_fa12(.A_i(A_i[12]),.B_i(B_i[12]),.C_i(C_fd[11]),.S_o(S_o[12]),.C_o(C_fd[12]));
full_adder u_fa13(.A_i(A_i[13]),.B_i(B_i[13]),.C_i(C_fd[12]),.S_o(S_o[13]),.C_o(C_fd[13]));
full_adder u_fa14(.A_i(A_i[14]),.B_i(B_i[14]),.C_i(C_fd[13]),.S_o(S_o[14]),.C_o(C_fd[14]));
full_adder u_fa15(.A_i(A_i[15]),.B_i(B_i[15]),.C_i(C_fd[14]),.S_o(S_o[15]),.C_o(C_fd[15]));
full_adder u_fa16(.A_i(A_i[16]),.B_i(B_i[16]),.C_i(C_fd[15]),.S_o(S_o[16]),.C_o(C_fd[16]));
full_adder u_fa17(.A_i(A_i[17]),.B_i(B_i[17]),.C_i(C_fd[16]),.S_o(S_o[17]),.C_o(C_fd[17]));
full_adder u_fa18(.A_i(A_i[18]),.B_i(B_i[18]),.C_i(C_fd[17]),.S_o(S_o[18]),.C_o(C_fd[18]));
full_adder u_fa19(.A_i(A_i[19]),.B_i(B_i[19]),.C_i(C_fd[18]),.S_o(S_o[19]),.C_o(C_fd[19]));
full_adder u_fa20(.A_i(A_i[20]),.B_i(B_i[20]),.C_i(C_fd[19]),.S_o(S_o[20]),.C_o(C_fd[20]));
full_adder u_fa21(.A_i(A_i[21]),.B_i(B_i[21]),.C_i(C_fd[20]),.S_o(S_o[21]),.C_o(C_fd[21]));
full_adder u_fa22(.A_i(A_i[22]),.B_i(B_i[22]),.C_i(C_fd[21]),.S_o(S_o[22]),.C_o(C_fd[22]));
full_adder u_fa23(.A_i(A_i[23]),.B_i(B_i[23]),.C_i(C_fd[22]),.S_o(S_o[23]),.C_o(C_fd[23]));
full_adder u_fa24(.A_i(A_i[24]),.B_i(B_i[24]),.C_i(C_fd[23]),.S_o(S_o[24]),.C_o(C_fd[24]));
full_adder u_fa25(.A_i(A_i[25]),.B_i(B_i[25]),.C_i(C_fd[24]),.S_o(S_o[25]),.C_o(C_fd[25]));
full_adder u_fa26(.A_i(A_i[26]),.B_i(B_i[26]),.C_i(C_fd[25]),.S_o(S_o[26]),.C_o(C_fd[26]));
full_adder u_fa27(.A_i(A_i[27]),.B_i(B_i[27]),.C_i(C_fd[26]),.S_o(S_o[27]),.C_o(C_fd[27]));
full_adder u_fa28(.A_i(A_i[28]),.B_i(B_i[28]),.C_i(C_fd[27]),.S_o(S_o[28]),.C_o(C_fd[28]));
full_adder u_fa29(.A_i(A_i[29]),.B_i(B_i[29]),.C_i(C_fd[28]),.S_o(S_o[29]),.C_o(C_fd[29]));
full_adder u_fa30(.A_i(A_i[30]),.B_i(B_i[30]),.C_i(C_fd[29]),.S_o(S_o[30]),.C_o(C_fd[30]));
full_adder u_fa31(.A_i(A_i[31]),.B_i(B_i[31]),.C_i(C_fd[30]),.S_o(S_o[31]),.C_o(C_fd[31]));
endmodule :add
