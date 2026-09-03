`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:48:11 08/28/2026
// Design Name:   riscv_core
// Module Name:   C:/Users/Hendrick/Desktop/Xilinx projects/alu_32bit/tb_riscv_core_final.v
// Project Name:  alu_32bit
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: riscv_core
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_riscv_core_final;

    //==================================================
    // CLOCK / RESET
    //==================================================

    reg clk;
    reg reset;

    //==================================================
    // CORE OUTPUTS
    //==================================================

    wire [31:0] PC;
    wire [31:0] Instruction;

    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    wire [31:0] ALU_B;
    wire [31:0] ALU_Result;

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [3:0] ALU_Opcode;
    wire [4:0] Shamt;

    wire [31:0] Immediate;

    wire ALUSrc;
    wire RegWrite;

    wire Carry;
    wire Zero;
    wire Negative;
    wire Overflow;

    integer errors;


    //==================================================
    // DEVICE UNDER TEST
    //==================================================

    riscv_core uut (

        .clk(clk),
        .reset(reset),

        .PC(PC),
        .Instruction(Instruction),

        .ReadData1(ReadData1),
        .ReadData2(ReadData2),

        .ALU_B(ALU_B),
        .ALU_Result(ALU_Result),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .ALU_Opcode(ALU_Opcode),
        .Shamt(Shamt),

        .Immediate(Immediate),

        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),

        .Carry(Carry),
        .Zero(Zero),
        .Negative(Negative),
        .Overflow(Overflow)
    );


    //==================================================
    // CLOCK
    //==================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    //==================================================
    // MONITOR
    //==================================================

    initial begin

        $display("");
        $display("==========================================================================");
        $display("             32-BIT RISC-V PROCESSOR VERIFICATION");
        $display("==========================================================================");

        $display("");
        $display("TIME   PC       INSTRUCTION   rs1 rs2 rd   A        B        RESULT");
        $display("--------------------------------------------------------------------------");

        $monitor(
            "%4dns  %h  %h   %d   %d  %d  %h  %h  %h",
            $time,
            PC,
            Instruction,
            rs1,
            rs2,
            rd,
            ReadData1,
            ALU_B,
            ALU_Result
        );

    end


    //==================================================
    // TEST SEQUENCE
    //==================================================

    initial begin

        errors = 0;

        //================================================
        // RESET
        //================================================

        reset = 1'b1;

        #12;

        //================================================
        // RELEASE RESET
        //================================================

        reset = 1'b0;

        //================================================
        // RUN PROGRAM
        //================================================

        #120;


        //================================================
        // FINAL REGISTER CHECK
        //================================================

        $display("");
        $display("==========================================================================");
        $display("                         FINAL PROCESSOR CHECK");
        $display("==========================================================================");

        // x1
        if (uut.REGFILE.registers[1] == 32'h0000000A)
            $display("PASS: x1 = %h", uut.REGFILE.registers[1]);
        else begin
            $display("FAIL: x1 = %h", uut.REGFILE.registers[1]);
            errors = errors + 1;
        end

        // x2
        if (uut.REGFILE.registers[2] == 32'h00000014)
            $display("PASS: x2 = %h", uut.REGFILE.registers[2]);
        else begin
            $display("FAIL: x2 = %h", uut.REGFILE.registers[2]);
            errors = errors + 1;
        end

        // x3 = x1 + x2
        if (uut.REGFILE.registers[3] == 32'h0000001E)
            $display("PASS: x3 = %h", uut.REGFILE.registers[3]);
        else begin
            $display("FAIL: x3 = %h", uut.REGFILE.registers[3]);
            errors = errors + 1;
        end

        // x4 = x3 - x1
        if (uut.REGFILE.registers[4] == 32'h00000014)
            $display("PASS: x4 = %h", uut.REGFILE.registers[4]);
        else begin
            $display("FAIL: x4 = %h", uut.REGFILE.registers[4]);
            errors = errors + 1;
        end

        // x5 = x3 AND x4
        if (uut.REGFILE.registers[5] == 32'h00000014)
            $display("PASS: x5 = %h", uut.REGFILE.registers[5]);
        else begin
            $display("FAIL: x5 = %h", uut.REGFILE.registers[5]);
            errors = errors + 1;
        end

        // x6 = x3 OR x4
        if (uut.REGFILE.registers[6] == 32'h0000001E)
            $display("PASS: x6 = %h", uut.REGFILE.registers[6]);
        else begin
            $display("FAIL: x6 = %h", uut.REGFILE.registers[6]);
            errors = errors + 1;
        end

        // x7 = x3 XOR x4
        if (uut.REGFILE.registers[7] == 32'h0000000A)
            $display("PASS: x7 = %h", uut.REGFILE.registers[7]);
        else begin
            $display("FAIL: x7 = %h", uut.REGFILE.registers[7]);
            errors = errors + 1;
        end

        // x8 = x7 << 2
        if (uut.REGFILE.registers[8] == 32'h00000028)
            $display("PASS: x8 = %h", uut.REGFILE.registers[8]);
        else begin
            $display("FAIL: x8 = %h", uut.REGFILE.registers[8]);
            errors = errors + 1;
        end

        // x9 = x8 >> 1
        if (uut.REGFILE.registers[9] == 32'h00000014)
            $display("PASS: x9 = %h", uut.REGFILE.registers[9]);
        else begin
            $display("FAIL: x9 = %h", uut.REGFILE.registers[9]);
            errors = errors + 1;
        end


        //================================================
        // FINAL RESULT
        //================================================

        $display("");
        $display("==========================================================================");

        if (errors == 0) begin

            $display("                    ALL TESTS PASSED");
            $display("                    PROCESSOR VERIFIED");

        end
        else begin

            $display("                    TEST FAILED");
            $display("                    ERRORS = %d", errors);

        end

        $display("==========================================================================");

        #10;

        $finish;

    end

endmodule