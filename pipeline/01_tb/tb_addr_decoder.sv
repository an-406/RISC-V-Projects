`timescale 1ns/1ps

module tb_addr_decoder;

    //==================================
    // DUT signals
    //==================================
    logic [31:0] alu_addr_i;

    logic sw_cs_o;
    logic lcd_cs_o;
    logic seg1_cs_o;
    logic seg0_cs_o;
    logic greled_cs_o;
    logic reled_cs_o;
    logic mem_cs_o;

    //==================================
    // DUT
    //==================================
    addr_decoder dut (
        .alu_addr_i  (alu_addr_i),

        .sw_cs_o     (sw_cs_o),
        .lcd_cs_o    (lcd_cs_o),
        .seg1_cs_o   (seg1_cs_o),
        .seg0_cs_o   (seg0_cs_o),
        .greled_cs_o (greled_cs_o),
        .reled_cs_o  (reled_cs_o),
        .mem_cs_o    (mem_cs_o)
    );


    //==================================
    // Task check output
    //==================================
    task automatic check_decode(
        input string       test_name,
        input logic [31:0] addr,

        input logic exp_sw,
        input logic exp_lcd,
        input logic exp_seg1,
        input logic exp_seg0,
        input logic exp_greled,
        input logic exp_reled,
        input logic exp_mem
    );

        begin

            alu_addr_i = addr;

            #1;

            if (
                sw_cs_o     === exp_sw     &&
                lcd_cs_o    === exp_lcd    &&
                seg1_cs_o   === exp_seg1   &&
                seg0_cs_o   === exp_seg0   &&
                greled_cs_o === exp_greled &&
                reled_cs_o  === exp_reled  &&
                mem_cs_o    === exp_mem
            )
            begin
                $display(
                    "[PASS] %-20s addr = %h",
                    test_name,
                    addr
                );
            end

            else begin
                $display(
                    "[FAIL] %-20s addr = %h",
                    test_name,
                    addr
                );

                $display(
                    "       Expected: SW=%b LCD=%b SEG1=%b SEG0=%b GLED=%b RLED=%b MEM=%b",
                    exp_sw,
                    exp_lcd,
                    exp_seg1,
                    exp_seg0,
                    exp_greled,
                    exp_reled,
                    exp_mem
                );

                $display(
                    "       Actual  : SW=%b LCD=%b SEG1=%b SEG0=%b GLED=%b RLED=%b MEM=%b",
                    sw_cs_o,
                    lcd_cs_o,
                    seg1_cs_o,
                    seg0_cs_o,
                    greled_cs_o,
                    reled_cs_o,
                    mem_cs_o
                );
            end

        end

    endtask


    //==================================
    // Test
    //==================================
    initial begin

        $display("======================================");
        $display("      ADDRESS DECODER TESTBENCH");
        $display("======================================");

        alu_addr_i = 32'b0;

        #5;


        //==================================
        // 1. DATA MEMORY
        //
        // mem_cs =
        // ~addr[28] & ~addr[11]
        //==================================

        check_decode(
            "DMEM address 0",
            32'h0000_0000,

            0, 0, 0, 0, 0, 0, 1
        );

        check_decode(
            "DMEM address 4",
            32'h0000_0004,

            0, 0, 0, 0, 0, 0, 1
        );

        check_decode(
            "DMEM last byte",
            32'h0000_07FF,

            0, 0, 0, 0, 0, 0, 1
        );


        // addr[11] = 1
        // => NOT data memory
        check_decode(
            "Outside DMEM",
            32'h0000_0800,

            0, 0, 0, 0, 0, 0, 0
        );


        //==================================
        // 2. RED LED
        //
        // addr[28] = 1
        // addr[16] = 0
        // addr[14] = 0
        // addr[13] = 0
        // addr[12] = 0
        //==================================

        check_decode(
            "RED LED",
            32'h1000_0000,

            0, 0, 0, 0, 0, 1, 0
        );


        //==================================
        // 3. GREEN LED
        //
        // bit[12] = 1
        //==================================

        check_decode(
            "GREEN LED",
            32'h1000_1000,

            0, 0, 0, 0, 1, 0, 0
        );


        //==================================
        // 4. SEG0
        //
        // bit[13] = 1
        // bit[12] = 0
        //==================================

        check_decode(
            "SEG0",
            32'h1000_2000,

            0, 0, 0, 1, 0, 0, 0
        );


        //==================================
        // 5. SEG1
        //
        // bit[13] = 1
        // bit[12] = 1
        //==================================

        check_decode(
            "SEG1",
            32'h1000_3000,

            0, 0, 1, 0, 0, 0, 0
        );


        //==================================
        // 6. LCD
        //
        // bit[14] = 1
        //==================================

        check_decode(
            "LCD",
            32'h1000_4000,

            0, 1, 0, 0, 0, 0, 0
        );


        //==================================
        // 7. SWITCH
        //
        // bit[16] = 1
        //==================================

        check_decode(
            "SWITCH",
            32'h1001_0000,

            1, 0, 0, 0, 0, 0, 0
        );


        //==================================
        // 8. Random unmapped address
        //==================================

        check_decode(
            "UNMAPPED",
            32'h1000_5000,

            0, 0, 0, 0, 0, 0, 0
        );


        $display("======================================");
        $display("           TEST FINISHED");
        $display("======================================");

        $finish;

    end

endmodule : tb_addr_decoder

