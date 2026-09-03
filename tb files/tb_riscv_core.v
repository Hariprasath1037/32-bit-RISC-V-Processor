`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:03:25 08/27/2026
// Design Name:   riscv_core
// Module Name:   C:/Users/Hendrick/Desktop/Xilinx projects/alu_32bit/tb_riscv_core.v
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

`timescale 1ns/1ps

module tb_riscv_core;

    //==================================================
    // CLOCK AND RESET
    //==================================================

    reg clk;
    reg reset;


    //==================================================
    // DEBUG SIGNALS
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


    //==================================================
    // DUT
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
        $display("======================================================================");
        $display(" TIME   PC       INSTRUCTION   rs1 rs2 rd   A        B        RESULT");
        $display("======================================================================");

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
    // TEST
    //==================================================

    initial begin

        //================================================
        // RESET
        //================================================

        reset = 1'b1;

        #12;


        //================================================
        // START PROCESSOR
        //================================================

        reset = 1'b0;


        // Allow instructions to execute
        #120;


        //================================================
        // FINAL CHECK
        //================================================

        $display("");
        $display("==========================================================");
        $display("             FINAL PROCESSOR CHECK");
        $display("==========================================================");

        $display("x1 = %h", uut.REGFILE.registers[1]);
        $display("x2 = %h", uut.REGFILE.registers[2]);
        $display("x3 = %h", uut.REGFILE.registers[3]);
        $display("x4 = %h", uut.REGFILE.registers[4]);
        $display("x5 = %h", uut.REGFILE.registers[5]);
        $display("x6 = %h", uut.REGFILE.registers[6]);
        $display("x7 = %h", uut.REGFILE.registers[7]);
        $display("x8 = %h", uut.REGFILE.registers[8]);
        $display("x9 = %h", uut.REGFILE.registers[9]);

        $display("==========================================================");


        $finish;

    end

endmodule
