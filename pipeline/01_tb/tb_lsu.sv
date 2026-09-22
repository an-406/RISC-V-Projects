`timescale 1ns/1ps

module tb_lsu;

    logic        clk_i;
    logic        rst_ni;
    logic [31:0] alu_addr_i;
    logic [31:0] writemem_i;
    logic [2:0]  lsu_control_i;
    logic        memwrite_i;
    logic [31:0] sw_i;

    logic [31:0] readdata_o;
    logic [31:0] ledr_o;
    logic [31:0] ledg_o;
    logic [31:0] lcd_o;

    logic [6:0] hex0_o, hex1_o, hex2_o, hex3_o;
    logic [6:0] hex4_o, hex5_o, hex6_o, hex7_o;


    //=====================================================
    // DUT
    //=====================================================
    lsu dut (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .alu_addr_i     (alu_addr_i),
        .writemem_i     (writemem_i),
        .lsu_control_i  (lsu_control_i),
        .memwrite_i     (memwrite_i),
        .sw_i           (sw_i),

        .readdata_o     (readdata_o),
        .ledr_o         (ledr_o),
        .ledg_o         (ledg_o),
        .lcd_o          (lcd_o),

        .hex0_o         (hex0_o),
        .hex1_o         (hex1_o),
        .hex2_o         (hex2_o),
        .hex3_o         (hex3_o),
        .hex4_o         (hex4_o),
        .hex5_o         (hex5_o),
        .hex6_o         (hex6_o),
        .hex7_o         (hex7_o)
    );


    //=====================================================
    // Clock
    //=====================================================
    initial begin
        clk_i = 1'b0;
        forever #5 clk_i = ~clk_i;
    end


    //=====================================================
    // Task STORE
    //=====================================================
    task store(
        input logic [31:0] addr,
        input logic [31:0] data,
        input logic [2:0]  funct3
    );
    begin
        @(negedge clk_i);

        alu_addr_i    = addr;
        writemem_i    = data;
        lsu_control_i = funct3;
        memwrite_i    = 1'b1;

        @(posedge clk_i);
        #1;

        memwrite_i = 1'b0;

        $display(
            "[STORE] addr = %h | data = %h | funct3 = %03b",
            addr, data, funct3
        );
    end
    endtask


    //=====================================================
    // Task LOAD
    //=====================================================
    task load_check(
        input logic [31:0] addr,
        input logic [2:0]  funct3,
        input logic [31:0] expected
    );
    begin
        @(negedge clk_i);

        alu_addr_i    = addr;
        lsu_control_i = funct3;
        memwrite_i    = 1'b0;

        #1;

        if (readdata_o === expected)
            $display(
                "[PASS] LOAD addr=%h funct3=%03b -> %h",
                addr, funct3, readdata_o
            );
        else
            $display(
                "[FAIL] LOAD addr=%h funct3=%03b -> got %h, expected %h",
                addr, funct3, readdata_o, expected
            );
    end
    endtask


    //=====================================================
    // TEST
    //=====================================================
    initial begin

        // Initial values
        rst_ni       = 1'b0;
        alu_addr_i   = 32'b0;
        writemem_i   = 32'b0;
        lsu_control_i = 3'b000;
        memwrite_i   = 1'b0;
        sw_i         = 32'b0;

        // Reset
        #20;
        rst_ni = 1'b1;

        $display("");
        $display("======================================");
        $display("        LSU TEST START");
        $display("======================================");


        //=================================================
        // TEST 1: STORE WORD
        //=================================================
        $display("");
        $display("------ TEST 1 : SW ------");

        store(
            32'h0000_0000,
            32'h1234_5678,
            3'b010
        );

        load_check(
            32'h0000_0000,
            3'b010,
            32'h1234_5678
        );


        //=================================================
        // TEST 2: STORE BYTE
        //=================================================
        $display("");
        $display("------ TEST 2 : SB ------");

        // offset 00
        store(
            32'h0000_0000,
            32'h0000_00AA,
            3'b000
        );

        // offset 01
        store(
            32'h0000_0001,
            32'h0000_00BB,
            3'b000
        );

        // offset 02
        store(
            32'h0000_0002,
            32'h0000_00CC,
            3'b000
        );

        // offset 03
        store(
            32'h0000_0003,
            32'h0000_00DD,
            3'b000
        );

        // Read whole word
        load_check(
            32'h0000_0000,
            3'b010,
            32'hDDCC_BBAA
        );


        //=================================================
        // TEST 3: LOAD BYTE SIGNED
        //=================================================
        $display("");
        $display("------ TEST 3 : LB ------");

        store(
            32'h0000_0004,
            32'h0000_0080,
            3'b000
        );

        load_check(
            32'h0000_0004,
            3'b000,
            32'hFFFF_FF80
        );


        //=================================================
        // TEST 4: LOAD BYTE UNSIGNED
        //=================================================
        $display("");
        $display("------ TEST 4 : LBU ------");

        load_check(
            32'h0000_0004,
            3'b100,
            32'h0000_0080
        );


        //=================================================
        // TEST 5: STORE HALFWORD
        //=================================================
        $display("");
        $display("------ TEST 5 : SH ------");

        // offset 00
        store(
            32'h0000_0008,
            32'h0000_AABB,
            3'b001
        );

        load_check(
            32'h0000_0008,
            3'b001,
            32'hFFFF_AABB
        );


        //=================================================
        // TEST 6: LOAD HALFWORD UNSIGNED
        //=================================================
        $display("");
        $display("------ TEST 6 : LHU ------");

        load_check(
            32'h0000_0008,
            3'b101,
            32'h0000_AABB
        );


        //=================================================
        // TEST 7: MISALIGNED HALFWORD
        //=================================================
        $display("");
        $display("------ TEST 7 : MISALIGNED SH ------");

        store(
            32'h0000_000B,
            32'h0000_1122,
            3'b001
        );

        load_check(
            32'h0000_000B,
            3'b001,
            32'h0000_1122
        );


        //=================================================
        // TEST 8: MISALIGNED WORD
        //=================================================
        $display("");
        $display("------ TEST 8 : MISALIGNED SW ------");

        store(
            32'h0000_000F,
            32'hAABB_CCDD,
            3'b010
        );

        load_check(
            32'h0000_000F,
            3'b010,
            32'hAABB_CCDD
        );


        //=================================================
        // TEST 9: SWITCH INPUT
        //=================================================
        $display("");
        $display("------ TEST 9 : SWITCH ------");

        sw_i = 32'h1234_5678;

        load_check(
            32'h1001_0000,
            3'b010,
            32'h1234_5678
        );


        //=================================================
        // TEST 10: GREEN LED
        //=================================================
        $display("");
        $display("------ TEST 10 : GREEN LED ------");

        store(
            32'h1000_1000,
            32'hDEAD_BEEF,
            3'b010
        );

        if (ledg_o === 32'hDEAD_BEEF)
            $display("[PASS] GREEN LED = %h", ledg_o);
        else
            $display(
                "[FAIL] GREEN LED = %h, expected DEADBEEF",
                ledg_o
            );


        //=================================================
        // TEST 11: RED LED
        //=================================================
        $display("");
        $display("------ TEST 11 : RED LED ------");

        store(
            32'h1000_0000,
            32'hABCD_1234,
            3'b010
        );

        if (ledr_o === 32'hABCD_1234)
            $display("[PASS] RED LED = %h", ledr_o);
        else
            $display(
                "[FAIL] RED LED = %h, expected ABCD1234 ",
                ledr_o
            );
        //=================================================
        // END
        //=================================================
        #20;

        $display("");
        $display("======================================");
        $display("         LSU TEST FINISHED");
        $display("======================================");

        $finish;
    end

endmodule
