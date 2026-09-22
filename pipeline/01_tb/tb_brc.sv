`timescale 1ns/1ps

module tb_brc;

    logic [31:0] rs1_i;
    logic [31:0] rs2_i;
    logic [4:0]  brc_control_i;
    logic        jump_control_o;

    //----------------------------------
    // DUT
    //----------------------------------
    brc dut(
        .rs1_i(rs1_i),
        .rs2_i(rs2_i),
        .brc_control_i(brc_control_i),
        .jump_control_o(jump_control_o)
    );

    //----------------------------------
    // Task kiểm tra
    //----------------------------------
    task automatic check;
        input [31:0] rs1;
        input [31:0] rs2;
        input [4:0]  control;
        input        expected;

        begin
            rs1_i = rs1;
            rs2_i = rs2;
            brc_control_i = control;
            #10;

            if (jump_control_o === expected)
                $display("PASS  rs1=%0d rs2=%0d ctrl=%b jump=%b",
                         rs1, rs2, control, jump_control_o);
            else
                $display("FAIL  rs1=%0d rs2=%0d ctrl=%b jump=%b expected=%b",
                         rs1, rs2, control, jump_control_o, expected);
        end
    endtask

    //----------------------------------
    // Test
    //----------------------------------
    initial begin

        //----------------------------------
        // No Branch
        //----------------------------------
        check(10,20,5'b00000,0);

        //----------------------------------
        // JAL (Always Jump)
        // control[4:3] = 2'b10
        //----------------------------------
        check(10,20,5'b10000,1);

        //----------------------------------
        // BEQ
        //----------------------------------
        check(20,20,5'b11000,1);
        check(20,15,5'b11000,0);

        //----------------------------------
        // BNE
        //----------------------------------
        check(20,15,5'b11001,1);
        check(20,20,5'b11001,0);

        //----------------------------------
        // BLT (signed)
        //----------------------------------
        check(-5,3,5'b11100,1);
        check(5,3,5'b11100,0);

        //----------------------------------
        // BGE (signed)
        //----------------------------------
        check(5,3,5'b11101,1);
        check(-5,3,5'b11101,0);

        //----------------------------------
        // BLTU (unsigned)
        //----------------------------------
        check(5,10,5'b11110,1);
        check(20,10,5'b11110,0);

        //----------------------------------
        // BGEU (unsigned)
        //----------------------------------
        check(20,10,5'b11111,1);
        check(5,10,5'b11111,0);

        //----------------------------------
        // Một số test biên
        //----------------------------------
        check(32'hFFFFFFFF,32'd1,5'b11100,1); // signed: -1 < 1
        check(32'hFFFFFFFF,32'd1,5'b11110,0); // unsigned: FFFFFFFF > 1

        check(32'd0,32'd0,5'b11000,1);
        check(32'd0,32'd0,5'b11001,0);

        $display("------------------------------------");
        $display("Simulation Finished");
        $display("------------------------------------");

        $finish;
    end

endmodule
