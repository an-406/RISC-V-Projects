//======================================
//Module : data memory
//Name   : An
//Date   : 22/07/2026
//Update : 24/07/2026
//======================================
module data_memory (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        memwrite_i,
    input  logic        mem_cs_i,
    input  logic [31:0] addr_i,
    input  logic [2:0]  funct3,
    input  logic [3:0]  mask_i,
    input  logic [3:0]  mask_miss_i,
    input  logic [31:0] writemem_i,
    output logic [31:0] readdata_o
);
// 512 word data
logic [31:0] mem [0:511];



logic [8:0] offset_dmem , offset_dmem_next;
logic [31:0] data , data_missalign;
assign offset_dmem = addr_i[10:2];
logic [31:0] result;
add plus1_offset (
  .A_i({{23{1'b0}},offset_dmem}),
  .B_i({{31{1'b0}},1'b1}),
  .S_o(result)
);
assign offset_dmem_next = result[8:0];
assign data = mem[offset_dmem];
assign data_missalign = mem[offset_dmem_next];

// write data
always_ff @(posedge clk_i or negedge rst_ni) begin
  if(~rst_ni) begin
    for(int i = 0 ; i < 512 ; i = i  + 1) begin
      mem[i] <= 32'b0;
    end
  end
  else if(memwrite_i & mem_cs_i) begin
    if(mask_i[0]) begin
      mem [offset_dmem] [7:0]   <= writemem_i [7:0];
    end 
    if(mask_i[1]) begin
      mem [offset_dmem] [15:8]  <= writemem_i [15:8];
    end
    if(mask_i[2]) begin
      mem [offset_dmem] [23:16] <= writemem_i [23:16];
    end
    if(mask_i[3]) begin
      mem [offset_dmem] [31:24] <= writemem_i [31:24];
    end
  end
  // miss align    
  if(memwrite_i & mem_cs_i) begin
    if(mask_miss_i[0]) begin
      mem [offset_dmem_next] [7:0]   <= writemem_i [7:0];
    end 
    if(mask_miss_i[1]) begin
      mem [offset_dmem_next] [15:8]  <= writemem_i [15:8];
    end
    if(mask_miss_i[2]) begin
      mem [offset_dmem_next] [23:16] <= writemem_i [23:16];
    end
    if(mask_miss_i[3]) begin
      mem [offset_dmem_next] [31:24] <= writemem_i [31:24];
    end
  end
end

// miss align



//read data
always_comb begin 
  case (funct3)
    3'b000: begin // load byte 
      case (addr_i[1:0])
        2'b00: begin
          readdata_o = {{24{data[7]}},data[7:0]};
        end 
        2'b01: begin
          readdata_o = {{24{data[15]}},data[15:8]};
        end
        2'b10: begin
          readdata_o = {{24{data[23]}},data[23:16]};
        end
        2'b11: begin
          readdata_o = {{24{data[31]}},data[31:24]};
        end
        default: begin
          readdata_o = '0;
        end
      endcase
    end 
    3'b001: begin // load half byte 
      case (addr_i[1:0])
        2'b00: begin
          readdata_o = {{16{data[15]}},data[15:0]};
        end 
        2'b01: begin
          readdata_o = {{16{data[23]}},data[23:8]};
        end
        2'b10: begin
          readdata_o = {{16{data[31]}},data[31:16]};
        end
        2'b11: begin
          readdata_o = {{16{data_missalign[7]}},data_missalign[7:0],data[31:24]};
        end
        default: begin
          readdata_o = '0;
        end
      endcase
    end
    3'b010: begin // load word
      case (addr_i[1:0])
        2'b00: begin
          readdata_o = data;
        end 
        2'b01: begin
          readdata_o = {data_missalign[7:0],data[31:8]};
        end
        2'b10: begin
          readdata_o = {data_missalign[15:0],data[31:16]};
        end
        2'b11: begin
          readdata_o = {data_missalign[23:0],data[31:24]};
        end
        default: begin
          readdata_o = '0;
        end
      endcase
    end
    3'b100: begin // load byte (U)
      case (addr_i[1:0])
        2'b00: begin
          readdata_o = {{24{1'b0}},data[7:0]};
        end 
        2'b01: begin
          readdata_o = {{24{1'b0}},data[15:8]};
        end
        2'b10: begin
          readdata_o = {{24{1'b0}},data[23:16]};
        end
        2'b11: begin
          readdata_o = {{24{1'b0}},data[31:24]};
        end
        default: begin
          readdata_o = '0;
        end
      endcase
    end
    3'b101: begin // load half byte (U)
      case (addr_i[1:0])
        2'b00: begin
          readdata_o = {{16{1'b0}},data[15:0]};
        end 
        2'b01: begin
          readdata_o = {{16{1'b0}},data[23:8]};
        end
        2'b10: begin
          readdata_o = {{16{1'b0}},data[31:16]};
        end
        2'b11: begin
          readdata_o = {{16{1'b0}},data_missalign[7:0],data[31:24]};
        end
        default: begin
          readdata_o = '0;
        end
      endcase
    end
    default: readdata_o = '0;
  endcase
end
endmodule : data_memory
