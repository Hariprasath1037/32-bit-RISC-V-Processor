`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:05:57 08/26/2026
// Design Name:   instruction_decoder
// Module Name:   C:/Users/Hendrick/Desktop/Xilinx projects/alu_32bit/tb_instruction_decoder.v
// Project Name:  alu_32bit
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: instruction_decoder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_instruction_decoder;

    reg [31:0] instruction;

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [31:0] Immediate;

    wire [3:0] ALU_Opcode;

    wire [4:0] Shamt;

    wire ALUSrc;
    wire RegWrite;


    //==================================================
    // DUT
    //==================================================

    instruction_decoder uut (

        .instruction(instruction),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .Immediate(Immediate),

        .ALU_Opcode(ALU_Opcode),

        .Shamt(Shamt),

        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)

    );


    //==================================================
    // VCD
    //==================================================

    initial begin

        $dumpfile("instruction_decoder.vcd");

        $dumpvars(0, tb_instruction_decoder);

    end


    //==================================================
    // TEST
    //==================================================

    initial begin

        //================================================
        // ADD x3,x1,x2
        //================================================

        instruction = 32'h002081B3;

        #10;

        $display("ADD  : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // SUB x3,x1,x2
        //================================================

        instruction = 32'h402081B3;

        #10;

        $display("SUB  : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // AND x3,x1,x2
        //================================================

        instruction = 32'h0020F1B3;

        #10;

        $display("AND  : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // OR x3,x1,x2
        //================================================

        instruction = 32'h0020E1B3;

        #10;

        $display("OR   : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // XOR x3,x1,x2
        //================================================

        instruction = 32'h0020C1B3;

        #10;

        $display("XOR  : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // SLT x3,x1,x2
        //================================================

        instruction = 32'h0020A1B3;

        #10;

        $display("SLT  : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // SLTU x3,x1,x2
        //================================================

        instruction = 32'h0020B1B3;

        #10;

        $display("SLTU : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // SLL x3,x1,x2
        //================================================

        instruction = 32'h002091B3;

        #10;

        $display("SLL  : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // SRL x3,x1,x2
        //================================================

        instruction = 32'h0020D1B3;

        #10;

        $display("SRL  : instr=%h rs1=%d rs2=%d rd=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rs2, rd,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // ADDI x1,x0,10
        //================================================

        instruction = 32'h00A00093;

        #10;

        $display("ADDI : instr=%h rs1=%d rd=%d IMM=%h ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rd,
                 Immediate,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // ADDI x2,x0,20
        //================================================

        instruction = 32'h01400113;

        #10;

        $display("ADDI : instr=%h rs1=%d rd=%d IMM=%h ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rd,
                 Immediate,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // ANDI x3,x1,15
        //================================================

        instruction = 32'h00F0F193;

        #10;

        $display("ANDI : instr=%h rs1=%d rd=%d IMM=%h ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rd,
                 Immediate,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // ORI x3,x1,15
        //================================================

        instruction = 32'h00F0E193;

        #10;

        $display("ORI  : instr=%h rs1=%d rd=%d IMM=%h ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rd,
                 Immediate,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // XORI x3,x1,15
        //================================================

        instruction = 32'h00F0C193;

        #10;

        $display("XORI : instr=%h rs1=%d rd=%d IMM=%h ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rd,
                 Immediate,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // SLLI x3,x1,4
        //================================================

        instruction = 32'h00409193;

        #10;

        $display("SLLI : instr=%h rs1=%d rd=%d SHAMT=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rd,
                 Shamt,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // SRLI x3,x1,4
        //================================================

        instruction = 32'h0040D193;

        #10;

        $display("SRLI : instr=%h rs1=%d rd=%d SHAMT=%d ALU=%b SRC=%b WE=%b",
                 instruction, rs1, rd,
                 Shamt,
                 ALU_Opcode, ALUSrc, RegWrite);


        //================================================
        // FINISH
        //================================================

        #10;

        $finish;

    end

endmodule