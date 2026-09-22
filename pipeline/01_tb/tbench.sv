`define RESET_PERIOD 100
`define CLK_PERIOD   2
`define FINISH       40_000




module tbench;

// Clock and reset generator
logic i_clk;
logic i_reset;

initial tsk_clock_gen(i_clk, `CLK_PERIOD);
initial tsk_reset(i_reset, `RESET_PERIOD); // Active Low Reset
initial tsk_timeout(`FINISH);

// Wave dumping
initial begin
    $fsdbDumpfile("dump.fsdb");
    $fsdbDumpvars(0, tbench);
end



logic [31:0]  i_io_sw  ;
logic [31:0]  o_io_ledr;
logic [31:0]  o_io_ledg;
logic [31:0]  o_io_lcd ;
logic [ 6:0]  o_io_hex0;
logic [ 6:0]  o_io_hex1;
logic [ 6:0]  o_io_hex2;
logic [ 6:0]  o_io_hex3;
logic [ 6:0]  o_io_hex4;
logic [ 6:0]  o_io_hex5;
logic [ 6:0]  o_io_hex6;
logic [ 6:0]  o_io_hex7;
logic [31:0]  o_pc_debug;
logic         o_insn_vld;

single_cycle dut (
    .clk_i    (i_clk     ) ,
    .rst_ni   (i_reset   ) ,
    .sw_i     (i_io_sw   ) ,
    .ledr_o   (o_io_ledr ) ,
    .ledg_o   (o_io_ledg ) ,
    .lcd_o    (o_io_lcd  ) ,
    .hex0_o   (o_io_hex0 ) ,
    .hex1_o   (o_io_hex1 ) ,
    .hex2_o   (o_io_hex2 ) ,
    .hex3_o   (o_io_hex3 ) ,
    .hex4_o   (o_io_hex4 ) ,
    .hex5_o   (o_io_hex5 ) ,
    .hex6_o   (o_io_hex6 ) ,
    .hex7_o   (o_io_hex7 ) ,
    .pc_debug_o  (o_pc_debug) ,
    .insn_vld_o  (o_insn_vld)
);




scoreboard scoreboard (
    .i_clk       (i_clk     ) ,
    .i_reset     (i_reset   ) ,
    .i_io_sw     (i_io_sw   ) ,
    .o_io_ledr   (o_io_ledr ) ,
    .o_io_ledg   (o_io_ledg ) ,
    .o_io_lcd    (o_io_lcd  ) ,
    .o_io_hex0   (o_io_hex0 ) ,
    .o_io_hex1   (o_io_hex1 ) ,
    .o_io_hex2   (o_io_hex2 ) ,
    .o_io_hex3   (o_io_hex3 ) ,
    .o_io_hex4   (o_io_hex4 ) ,
    .o_io_hex5   (o_io_hex5 ) ,
    .o_io_hex6   (o_io_hex6 ) ,
    .o_io_hex7   (o_io_hex7 ) ,
    .o_pc_debug  (o_pc_debug) ,
    .o_insn_vld  (o_insn_vld)
);


driver driver(
  .i_clk    (i_clk  ),
  .i_reset  (i_reset),
  .o_sw_data(i_io_sw)
);




endmodule : tbench
