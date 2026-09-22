`timescale 1ns/1ps

module tb_control_unit;

    logic [31:0] inst_i;

    logic [3:0] alu_control_o;
    logic       regwrite_o;
    logic       alu_src1_o;
    logic       alu_src2_o;
    logic       mem_write_o;
    logic [1:0] rd_src_o;
    logic [4:0] branch_control_o;
    logic [2:0] lsu_control_o;

    //========================================================
    // DUT
    //========================================================
    control_unit dut (
        .inst_i          (inst_i),
        .alu_control_o   (alu_control_o),
        .regwrite_o      (regwrite_o),
        .alu_src1_o      (alu_src1_o),
        .alu_src2_o      (alu_src2_o),
        .mem_write_o     (mem_write_o),
        .rd_src_o        (rd_src_o),
        .branch_control_o(branch_control_o),
        .lsu_control_o   (lsu_control_o)
    );

    //========================================================
    // Encoder functions
    //========================================================

    // R-type
    function automatic [31:0] enc_r(
        input [6:0] funct7,
        input [2:0] funct3
    );
        enc_r = {
            funct7,
            5'd2,          // rs2 = x2
            5'd1,          // rs1 = x1
            funct3,
            5'd3,          // rd = x3
            7'b0110011
        };
    endfunction

    // I-type
    function automatic [31:0] enc_i(
        input [11:0] imm,
        input [2:0]  funct3
    );
        enc_i = {
            imm,
            5'd1,          // rs1 = x1
            funct3,
            5'd3,          // rd = x3
            7'b0010011
        };
    endfunction

    // Load
    function automatic [31:0] enc_load(
        input [2:0] funct3
    );
        enc_load = {
            12'd0,
            5'd1,
            funct3,
            5'd3,
            7'b0000011
        };
    endfunction

    // Store
    function automatic [31:0] enc_s(
        input [2:0] funct3
    );
        enc_s = {
            7'b0000000,
            5'd2,          // rs2 = x2
            5'd1,          // rs1 = x1
            funct3,
            5'b00000,
            7'b0100011
        };
    endfunction

    // Branch
    function automatic [31:0] enc_b(
        input [2:0] funct3
    );
        enc_b = {
            1'b0,          // imm[12]
            6'b000000,     // imm[10:5]
            5'd2,          // rs2
            5'd1,          // rs1
            funct3,
            4'b0100,       // imm[4:1]
            1'b0,          // imm[11]
            7'b1100011
        };
    endfunction

    // JAL
    function automatic [31:0] enc_jal;
        enc_jal = 32'h0080_01EF;
    endfunction

    // JALR
    function automatic [31:0] enc_jalr;
        enc_jalr = 32'h0080_81E7;
    endfunction

    // LUI
    function automatic [31:0] enc_lui;
        enc_lui = 32'h1234_51B7;
    endfunction

    // AUIPC
    function automatic [31:0] enc_auipc;
        enc_auipc = 32'h1234_5197;
    endfunction


    //========================================================
    // Check task
    //========================================================

    task automatic check_control (
        input [31:0] inst,
        input [3:0]  exp_alu,
        input        exp_regwrite,
        input        exp_src1,
        input        exp_src2,
        input        exp_memwrite,
        input [1:0]  exp_rd_src,
        input [4:0]  exp_branch,
        input [2:0]  exp_lsu
    );

        begin
            inst_i = inst;
            #1;

            if (
                alu_control_o    === exp_alu       &&
                regwrite_o       === exp_regwrite  &&
                alu_src1_o       === exp_src1      &&
                alu_src2_o       === exp_src2      &&
                mem_write_o      === exp_memwrite  &&
                rd_src_o         === exp_rd_src    &&
                branch_control_o === exp_branch    &&
                lsu_control_o    === exp_lsu
            ) begin
                $display("PASS: inst = %h", inst);
            end
            else begin
                $display("FAIL: inst = %h", inst);

                $display("  ALU     : got %b expected %b",
                         alu_control_o, exp_alu);

                $display("  REGWRITE: got %b expected %b",
                         regwrite_o, exp_regwrite);

                $display("  SRC1    : got %b expected %b",
                         alu_src1_o, exp_src1);

                $display("  SRC2    : got %b expected %b",
                         alu_src2_o, exp_src2);

                $display("  MEMWRITE: got %b expected %b",
                         mem_write_o, exp_memwrite);

                $display("  RD_SRC  : got %b expected %b",
                         rd_src_o, exp_rd_src);

                $display("  BRANCH  : got %b expected %b",
                         branch_control_o, exp_branch);

                $display("  LSU     : got %b expected %b",
                         lsu_control_o, exp_lsu);
            end
        end

    endtask


    //========================================================
    // TEST
    //========================================================

    initial begin

        $display("==============================================");
        $display("        CONTROL UNIT TESTBENCH");
        $display("==============================================");


        //====================================================
        // R-TYPE
        //====================================================

        // ADD
        check_control(
            enc_r(7'b0000000,3'b000),
            4'b0010, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // SUB
        check_control(
            enc_r(7'b0100000,3'b000),
            4'b0110, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // XOR
        check_control(
            enc_r(7'b0000000,3'b100),
            4'b0011, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // OR
        check_control(
            enc_r(7'b0000000,3'b110),
            4'b0001, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // AND
        check_control(
            enc_r(7'b0000000,3'b111),
            4'b0000, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // SLL
        check_control(
            enc_r(7'b0000000,3'b001),
            4'b1001, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // SRL
        check_control(
            enc_r(7'b0000000,3'b101),
            4'b1000, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // SRA
        check_control(
            enc_r(7'b0100000,3'b101),
            4'b1010, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // SLT
        check_control(
            enc_r(7'b0000000,3'b010),
            4'b0111, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );

        // SLTU
        check_control(
            enc_r(7'b0000000,3'b011),
            4'b0100, 1,0,0,0, 2'b00, 5'b00000, 3'b000
        );


        //====================================================
        // I-TYPE ALU
        //====================================================

        // ADDI
        check_control(
            enc_i(12'd5,3'b000),
            4'b0010, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );

        // XORI
        check_control(
            enc_i(12'd5,3'b100),
            4'b0011, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );

        // ORI
        check_control(
            enc_i(12'd5,3'b110),
            4'b0001, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );

        // ANDI
        check_control(
            enc_i(12'd5,3'b111),
            4'b0000, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );

        // SLLI
        check_control(
            enc_i(12'd5,3'b001),
            4'b1001, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );

        // SRLI
        check_control(
            enc_i(12'h005,3'b101),
            4'b1000, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );

        // SRAI
        check_control(
            32'h4050_D193,
            4'b1010, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );

        // SLTI
        check_control(
            enc_i(12'd5,3'b010),
            4'b0111, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );

        // SLTIU
        check_control(
            enc_i(12'd5,3'b011),
            4'b0100, 1,0,1,0, 2'b00, 5'b00000, 3'b000
        );


        //====================================================
        // LOAD
        //====================================================

        // LB
        check_control(
            enc_load(3'b000),
            4'b0010, 1,0,1,0, 2'b01, 5'b00000, 3'b000
        );

        // LH
        check_control(
            enc_load(3'b001),
            4'b0010, 1,0,1,0, 2'b01, 5'b00000, 3'b001
        );

        // LW
        check_control(
            enc_load(3'b010),
            4'b0010, 1,0,1,0, 2'b01, 5'b00000, 3'b010
        );

        // LBU
        check_control(
            enc_load(3'b100),
            4'b0010, 1,0,1,0, 2'b01, 5'b00000, 3'b100
        );

        // LHU
        check_control(
            enc_load(3'b101),
            4'b0010, 1,0,1,0, 2'b01, 5'b00000, 3'b101
        );


        //====================================================
        // STORE
        //====================================================

        // SB
        check_control(
            enc_s(3'b000),
            4'b0010, 0,0,1,1, 2'bxx, 5'b00000, 3'b000
        );

        // SH
        check_control(
            enc_s(3'b001),
            4'b0010, 0,0,1,1, 2'bxx, 5'b00000, 3'b001
        );

        // SW
        check_control(
            enc_s(3'b010),
            4'b0010, 0,0,1,1, 2'bxx, 5'b00000, 3'b010
        );


        //====================================================
        // BRANCH
        //====================================================

        // BEQ
        check_control(
            enc_b(3'b000),
            4'b0010, 0,1,1,0, 2'bxx, 5'b11000, 3'b000
        );

        // BNE
        check_control(
            enc_b(3'b001),
            4'b0010, 0,1,1,0, 2'bxx, 5'b11001, 3'b000
        );

        // BLT
        check_control(
            enc_b(3'b100),
            4'b0010, 0,1,1,0, 2'bxx, 5'b11100, 3'b000
        );

        // BGE
        check_control(
            enc_b(3'b101),
            4'b0010, 0,1,1,0, 2'bxx, 5'b11101, 3'b000
        );

        // BLTU
        check_control(
            enc_b(3'b110),
            4'b0010, 0,1,1,0, 2'bxx, 5'b11110, 3'b000
        );

        // BGEU
        check_control(
            enc_b(3'b111),
            4'b0010, 0,1,1,0, 2'bxx, 5'b11111, 3'b000
        );


        //====================================================
        // JAL
        //====================================================

        check_control(
            enc_jal(),
            4'b0010, 1,1,1,0, 2'b10, 5'b10000, 3'b000
        );


        //====================================================
        // JALR
        //====================================================

        check_control(
            enc_jalr(),
            4'b0010, 1,0,1,0, 2'b10, 5'b10000, 3'b000
        );


        //====================================================
        // LUI
        //====================================================

        check_control(
            enc_lui(),
            4'b0010, 1,1,1,0, 2'b11, 5'b00000, 3'b000
        );


        //====================================================
        // AUIPC
        //====================================================

        check_control(
            enc_auipc(),
            4'b0010, 1,1,1,0, 2'b00, 5'b00000, 3'b000
        );


        $display("==============================================");
        $display("        TEST FINISHED");
        $display("==============================================");

        $finish;
    end

endmodule
