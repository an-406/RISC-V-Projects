//======================================
//Module : Load Store Unit
//Name   : An
//Date   : 10/07/2026
//Update : 26/07/2026
//======================================
module lsu (
    input  logic        clk_i , rst_ni,
    input  logic [31:0] alu_addr_i,  // addr rdata [ rs1 + imm ] from ALU
    input  logic [31:0] writemem_i,
    input  logic [2:0]  lsu_control_i, // funct 3 
    input  logic        memwrite_i, // from Control Unit 
    input  logic [31:0] sw_i,
    output logic [31:0] readdata_o,
    output logic [31:0] ledr_o , ledg_o,
    output logic [31:0] lcd_o,
    output logic [6:0]  hex0_o , hex1_o , hex2_o , hex3_o,
    output logic [6:0]  hex4_o , hex5_o , hex6_o , hex7_o
);
// ================ address decoder ==================
logic        sw_cs , lcd_cs , seg1_cs , seg0_cs , greled_cs , reled_cs , mem_cs;
addr_decoder u_ad0 (
  .alu_addr_i(alu_addr_i),
  .sw_cs_o(sw_cs),
  .lcd_cs_o(lcd_cs),
  .seg1_cs_o(seg1_cs),
  .seg0_cs_o(seg0_cs),
  .greled_cs_o(greled_cs),
  .reled_cs_o(reled_cs),
  .mem_cs_o(mem_cs)
); 
//=====================================================

//===== generate bit mask  =====
logic [3:0]  mask , mask_miss;
logic [31:0] fixed_writemem;
always_comb begin 
  mask           = 4'b0000;
  mask_miss      = 4'b0000;
  fixed_writemem = 32'b0;
  case (lsu_control_i)
    3'b000: begin // store byte
      case (alu_addr_i[1:0])
        2'b00: begin
          mask = 4'b0001;
          fixed_writemem = {{24{1'b0}},writemem_i[7:0]};
        end 
        2'b01: begin
          mask = 4'b0010;
          fixed_writemem = {{16{1'b0}},writemem_i[7:0],{8{1'b0}}};
        end  
        2'b10: begin
          mask = 4'b0100;
          fixed_writemem = {{8{1'b0}},writemem_i[7:0],{16{1'b0}}};
        end  
        2'b11: begin
          mask = 4'b1000; 
          fixed_writemem = {writemem_i[7:0],{24{1'b0}}};
        end 
        default: mask = 4'b0000;
      endcase
    end      
    3'b001: begin // store half word
      case (alu_addr_i[1:0])
        2'b00: begin
          mask = 4'b0011;
          fixed_writemem = {{16{1'b0}},writemem_i[15:0]};
        end 
        2'b01: begin
          mask = 4'b0110;
          fixed_writemem = {{8{1'b0}},writemem_i[15:0],{8{1'b0}}};
        end  
        2'b10: begin
          mask = 4'b1100;
          fixed_writemem = {writemem_i[15:0],{16{1'b0}}};
        end  
        2'b11: begin
          mask = 4'b1000; 
          mask_miss = 4'b0001;
          fixed_writemem = {writemem_i[7:0],{16{1'b0}},writemem_i[15:8]};
        end 
        default: mask = 4'b0000;
      endcase
    end
    3'b010: begin // store word
      case (alu_addr_i[1:0])
        2'b00: begin
          mask = 4'b1111;
          fixed_writemem = writemem_i;
        end 
        2'b01: begin
          mask = 4'b1110;
          mask_miss = 4'b0001;
          fixed_writemem = {writemem_i[23:0],writemem_i[31:24]};
        end  
        2'b10: begin
          mask = 4'b1100;
          mask_miss = 4'b0011;
          fixed_writemem = {writemem_i[15:0],writemem_i[31:16]};
        end  
        2'b11: begin
          mask = 4'b1000;
          mask_miss = 4'b0111; 
          fixed_writemem = {writemem_i[7:0],writemem_i[31:8]};
        end 
        default: mask = 4'b0000;
      endcase
    end
    default: begin
      mask         = 4'b0000;
      mask_miss    = 4'b0000;
    end 
  endcase
end 
//=======================================
//================ LOAD DATA ================
logic [31:0] next_ledg , next_ledr , next_lcd , read_data , read_mdata;
logic [6:0]  next_hex0 , next_hex1 , next_hex2 , next_hex3;
logic [6:0]  next_hex4 , next_hex5 , next_hex6 , next_hex7;
//data memory
data_memory u_dm0 (
  .clk_i(clk_i),
  .rst_ni(rst_ni),
  .memwrite_i(memwrite_i),
  .mem_cs_i(mem_cs),
  .addr_i(alu_addr_i),
  .funct3(lsu_control_i),
  .mask_i(mask),
  .mask_miss_i(mask_miss),
  .writemem_i(fixed_writemem),
  .readdata_o(read_mdata)
); 

logic [31:0] data_prep;
always_comb begin : store_data
  data_prep = writemem_i;
  read_data = '0;
  next_ledr = ledr_o;
  next_ledg = ledg_o;
  next_lcd  = lcd_o;
  next_hex0 = hex0_o;
  next_hex1 = hex1_o;
  next_hex2 = hex2_o;
  next_hex3 = hex3_o;
  next_hex4 = hex4_o;
  next_hex5 = hex5_o;
  next_hex6 = hex6_o;
  next_hex7 = hex7_o;
  if(mem_cs) begin
    if(memwrite_i) begin
      case (mask)
        4'b0001,
        4'b0010,
        4'b0100,
        4'b1000: data_prep = {{24{1'b0}},writemem_i[7:0]};
        4'b0011: data_prep = {{16{1'b0}},writemem_i[15:0]};
        4'b1100: data_prep = {writemem_i[15:0],{16{1'b0}}};
        4'b1111: data_prep = writemem_i;
        default: data_prep = '0;
      endcase
    end
    else begin
      read_data = read_mdata;
    end
  end
  else if(greled_cs & memwrite_i) begin
    next_ledg = data_prep;
  end
  else if(reled_cs & memwrite_i) begin
    next_ledr = data_prep;
  end
  else if(seg0_cs & memwrite_i) begin
    next_hex0 = data_prep[6:0];
    next_hex1 = data_prep[14:8];
    next_hex2 = data_prep[22:16];
    next_hex3 = data_prep[30:24];
  end
  else if(seg1_cs & memwrite_i) begin
    next_hex4 = data_prep[6:0];
    next_hex5 = data_prep[14:8];
    next_hex6 = data_prep[22:16];
    next_hex7 = data_prep[30:24];
  end
  else if(lcd_cs & memwrite_i) begin
    next_lcd = data_prep;
  end
  else if(sw_cs & ~memwrite_i) begin
    read_data = sw_i;
  end
end

always_ff @( posedge clk_i or negedge rst_ni ) begin 
  if(~rst_ni) begin
    ledr_o <= '0;
    ledg_o <= '0;
    lcd_o  <= '0;
    hex0_o <= '0;
    hex1_o <= '0;
    hex2_o <= '0;
    hex3_o <= '0;
    hex4_o <= '0;
    hex5_o <= '0;
    hex6_o <= '0;
    hex7_o <= '0;
  end
  else if ( memwrite_i) begin
    ledr_o <= next_ledr;
    ledg_o <= next_ledg;
    lcd_o  <= next_lcd;
    hex0_o <= next_hex0; 
    hex1_o <= next_hex1; 
    hex2_o <= next_hex2;
    hex3_o <= next_hex3;
    hex4_o <= next_hex4;
    hex5_o <= next_hex5;
    hex6_o <= next_hex6;
    hex7_o <= next_hex7;
  end
end

always_comb begin
  readdata_o = read_data;
end
endmodule : lsu
