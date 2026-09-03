`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:40:08 08/26/2026
// Design Name:   riscv_datapath
// Module Name:   C:/Users/Hendrick/Desktop/Xilinx projects/alu_32bit/tb_riscv_datapath.v
// Project Name:  alu_32bit
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: riscv_datapath
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_riscv_datapath;

    //==================================================
    // CLOCK AND RESET
    //==================================================

    reg clk;
    reg reset;


    //==================================================
    // INSTRUCTION
    //==================================================

    reg [31:0] instruction;


    //==================================================
    // OUTPUTS
    //==================================================

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [31:0] Immediate;

    wire [3:0] ALU_Opcode;

    wire [4:0] Shamt;

    wire ALUSrc;
    wire RegWrite;

    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    wire [31:0] ALU_B;

    wire [31:0] ALU_Result;

    wire Carry;
    wire Zero;
    wire Negative;
    wire Overflow;


    //==================================================
    // DUT
    //==================================================

    riscv_datapath uut (

        .clk(clk),
        .reset(reset),

        .instruction(instruction),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .Immediate(Immediate),

        .ALU_Opcode(ALU_Opcode),

        .Shamt(Shamt),

        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),

        .ReadData1(ReadData1),
        .ReadData2(ReadData2),

        .ALU_B(ALU_B),

        .ALU_Result(ALU_Result),

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
    // VCD
    //==================================================

    initial begin

        $dumpfile("riscv_datapath.vcd");

        $dumpvars(0, tb_riscv_datapath);

    end


    //==================================================
    // MONITOR
    //==================================================

    initial begin

        $display("");
        $display("==========================================================================");
        $display(" TIME   INSTRUCTION   rs1 rs2 rd   A          B          RESULT");
        $display("==========================================================================");

        $monitor("%4dns   %h   %02d  %02d  %02d   %h   %h   %h",
                 $time,
                 instruction,
                 rs1,
                 rs2,
                 rd,
                 ReadData1,
                 ALU_B,
                 ALU_Result);

    end


    //==================================================
    // TEST SEQUENCE
    //==================================================

    initial begin

        //================================================
        // RESET
        //================================================

        reset = 1'b1;

        instruction = 32'b0;

        #12;

        reset = 1'b0;


        //================================================
        // 1. ADDI x1,x0,10
        //
        // x1 = 0 + 10
        //================================================

        @(negedge clk);

        instruction = 32'h00A00093;


        //================================================
        // 2. ADDI x2,x0,20
        //
        // x2 = 0 + 20
        //================================================

        @(negedge clk);

        instruction = 32'h01400113;


        //================================================
        // 3. ADD x3,x1,x2
        //
        // x3 = 10 + 20 = 30
        //================================================

        @(negedge clk);

        instruction = 32'h002081B3;


        //================================================
        // 4. SUB x4,x3,x1
        //
        // x4 = 30 - 10 = 20
        //================================================

        @(negedge clk);

        instruction = 32'h40118233;


        //================================================
        // 5. AND x5,x3,x4
        //
        // 30 AND 20 = 20
        //================================================

        @(negedge clk);

        instruction = 32'h0041F2B3;


        //================================================
        // 6. OR x6,x3,x4
        //
        // 30 OR 20 = 30
        //================================================

        @(negedge clk);

        instruction = 32'h0041E333;


        //================================================
        // 7. XOR x7,x3,x4
        //
        // 30 XOR 20 = 10
        //================================================

        @(negedge clk);

        instruction = 32'h0041C3B3;


        //================================================
        // 8. SLL x8,x7,x2
        //
        // x7 = 10
        // x2 = 20
        //
        // x8 = 10 << 20
        //================================================

        @(negedge clk);

        instruction = 32'h00239433;


        //================================================
        // 9. SRL x9,x8,x1
        //
        // x8 = 00A00000
        // x1 = 10
        //
        // x9 = 00A00000 >> 10
        //================================================

        @(negedge clk);

        instruction = 32'h001454B3;


        //================================================
        // WAIT FOR FINAL WRITE
        //================================================

        @(negedge clk);

        instruction = 32'b0;

        #10;


        //================================================
        // FINAL CHECK
        //================================================

        $display("");
        $display("==========================================================");
        $display("             FINAL DATAPATH CHECK");
        $display("==========================================================");

        $display("Expected:");
        $display("x1 = 0000000A");
        $display("x2 = 00000014");
        $display("x3 = 0000001E");
        $display("x4 = 00000014");
        $display("x5 = 00000014");
        $display("x6 = 0000001E");
        $display("x7 = 0000000A");
        $display("x8 = 00A00000");
        $display("x9 = 00002800");

        $display("==========================================================");


        $finish;

    end

endmodule