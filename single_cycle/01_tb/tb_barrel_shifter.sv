//======================================
// TB : Barrel shifter
// Name : An
//======================================
`timescale 1ns/1ps

module tb_barrel_shifter;

    logic [31:0] A_i;
    logic [4:0]  Shift_i;
    logic        lr_sel_i;
    logic        la_sel_i;
    logic [31:0] result_o;

    //================================================
    // DUT
    //================================================
    barrel_shifter dut (
        .A_i       (A_i),
        .Shift_i   (Shift_i),
        .lr_sel_i  (lr_sel_i),
        .la_sel_i  (la_sel_i),
        .result_o  (result_o)
    );

    //================================================
    // CHECK TASK
    //================================================
    task automatic check_shift (
        input [31:0] A,
        input [4:0]  shift,
        input        lr_sel,
        input        la_sel,
        input [31:0] expected
    );

        begin
            A_i      = A;
            Shift_i  = shift;
            lr_sel_i = lr_sel;
            la_sel_i = la_sel;

            #1;

            if (result_o === expected) begin

                $display(
                    "PASS | A=%h | Shift=%0d | lr=%b | la=%b | result=%h",
                    A_i,
                    Shift_i,
                    lr_sel_i,
                    la_sel_i,
                    result_o
                );

            end
            else begin

                $display(
                    "FAIL | A=%h | Shift=%0d | lr=%b | la=%b | got=%h | expected=%h",
                    A_i,
                    Shift_i,
                    lr_sel_i,
                    la_sel_i,
                    result_o,
                    expected
                );

            end
        end

    endtask


    //================================================
    // TEST
    //================================================
    initial begin

        $display("==============================================");
        $display("        BARREL SHIFTER TESTBENCH");
        $display("==============================================");


        //================================================
        // SLL
        // lr_sel_i = 1
        // la_sel_i = don't care
        //================================================

        // 1 << 0
        check_shift(
            32'h0000_0001,
            5'd0,
            1'b1,
            1'b0,
            32'h0000_0001
        );

        // 1 << 1
        check_shift(
            32'h0000_0001,
            5'd1,
            1'b1,
            1'b0,
            32'h0000_0002
        );

        // 1 << 4
        check_shift(
            32'h0000_0001,
            5'd4,
            1'b1,
            1'b0,
            32'h0000_0010
        );

        // 1 << 16
        check_shift(
            32'h0000_0001,
            5'd16,
            1'b1,
            1'b0,
            32'h0001_0000
        );

        // 1 << 31
        check_shift(
            32'h0000_0001,
            5'd31,
            1'b1,
            1'b0,
            32'h8000_0000
        );

        // 12345678 << 4
        check_shift(
            32'h1234_5678,
            5'd4,
            1'b1,
            1'b0,
            32'h2345_6780
        );


        //================================================
        // SRL
        // lr_sel_i = 0
        // la_sel_i = 0
        //================================================

        // 80000000 >> 0
        check_shift(
            32'h8000_0000,
            5'd0,
            1'b0,
            1'b0,
            32'h8000_0000
        );

        // 80000000 >> 1
        check_shift(
            32'h8000_0000,
            5'd1,
            1'b0,
            1'b0,
            32'h4000_0000
        );

        // 80000000 >> 4
        check_shift(
            32'h8000_0000,
            5'd4,
            1'b0,
            1'b0,
            32'h0800_0000
        );

        // 80000000 >> 16
        check_shift(
            32'h8000_0000,
            5'd16,
            1'b0,
            1'b0,
            32'h0000_8000
        );

        // 80000000 >> 31
        check_shift(
            32'h8000_0000,
            5'd31,
            1'b0,
            1'b0,
            32'h0000_0001
        );

        // 12345678 >> 4
        check_shift(
            32'h1234_5678,
            5'd4,
            1'b0,
            1'b0,
            32'h0123_4567
        );


        //================================================
        // SRA
        // lr_sel_i = 0
        // la_sel_i = 1
        //================================================

        // 80000000 >>> 0
        check_shift(
            32'h8000_0000,
            5'd0,
            1'b0,
            1'b1,
            32'h8000_0000
        );

        // 80000000 >>> 1
        check_shift(
            32'h8000_0000,
            5'd1,
            1'b0,
            1'b1,
            32'hC000_0000
        );

        // 80000000 >>> 4
        check_shift(
            32'h8000_0000,
            5'd4,
            1'b0,
            1'b1,
            32'hF800_0000
        );

        // 80000000 >>> 16
        check_shift(
            32'h8000_0000,
            5'd16,
            1'b0,
            1'b1,
            32'hFFFF_8000
        );

        // 80000000 >>> 31
        check_shift(
            32'h8000_0000,
            5'd31,
            1'b0,
            1'b1,
            32'hFFFF_FFFF
        );


        //================================================
        // SRA - các số âm khác
        //================================================

        // F0000000 >>> 4
        check_shift(
            32'hF000_0000,
            5'd4,
            1'b0,
            1'b1,
            32'hFF00_0000
        );

        // FFFFFFFF >>> 1
        check_shift(
            32'hFFFF_FFFF,
            5'd1,
            1'b0,
            1'b1,
            32'hFFFF_FFFF
        );

        // FFFFFFFF >>> 31
        check_shift(
            32'hFFFF_FFFF,
            5'd31,
            1'b0,
            1'b1,
            32'hFFFF_FFFF
        );


        //================================================
        // PATTERN TEST
        //================================================

        // AAAAAAAA << 1
        check_shift(
            32'hAAAA_AAAA,
            5'd1,
            1'b1,
            1'b0,
            32'h5555_5554
        );

        // AAAAAAAA >> 1
        check_shift(
            32'hAAAA_AAAA,
            5'd1,
            1'b0,
            1'b0,
            32'h5555_5555
        );

        // AAAAAAAA >>> 1
        check_shift(
            32'hAAAA_AAAA,
            5'd1,
            1'b0,
            1'b1,
            32'hD555_5555
        );


        $display("==============================================");
        $display("           TEST FINISHED");
        $display("==============================================");

        $finish;

    end

endmodule
