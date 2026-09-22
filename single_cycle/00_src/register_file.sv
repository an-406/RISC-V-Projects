//======================================
//Module : register file
//Name   : An
//Date   : 02/07/2026
//======================================
module register_file (
    input  logic        regwrite_i,
    input  logic [4:0]  write_reg_num_i,
    input  logic [4:0]  read_reg_num1_i , read_reg_num2_i,
    input  logic [31:0] reg_data_i,

    input  logic clk_i , rst_ni,
    output logic [31:0] rs1_o , rs2_o
);

logic [31:0] register [31:0] ;
logic [31:0] signal_out , en_reg;

// signal for write
decoder_5_32 u_d0 (
    .A_i(write_reg_num_i),
    .Y_o(signal_out)
);
assign en_reg = signal_out & {32{(regwrite_i)}};

// write data
always_ff @( posedge clk_i or negedge rst_ni) begin 
  if(~rst_ni) begin
    register[0] <= 32'b0; 
  end
  else if(en_reg[write_reg_num_i] && (write_reg_num_i != 5'b0)) begin 
    register[write_reg_num_i] <= reg_data_i;
  end
end

//read data
mux_32_1 # (
    .WIDTH(32)
) u_mu0 (
  .A_i(register),
  .sel_i(read_reg_num1_i),
  .D_o(rs1_o)
);
mux_32_1 # (
    .WIDTH(32)
) u_mu1 (
  .A_i(register),
  .sel_i(read_reg_num2_i),
  .D_o(rs2_o)
);
endmodule : register_file
