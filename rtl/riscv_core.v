`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:02:14 08/27/2026 
// Design Name: 
// Module Name:    riscv_core 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module riscv_core #(
    parameter WIDTH = 32
)(
    input clk,
    input reset,

    //==================================================
    // DEBUG / MONITOR OUTPUTS
    //==================================================

    output [WIDTH-1:0] PC,
    output [WIDTH-1:0] Instruction,

    output [WIDTH-1:0] ReadData1,
    output [WIDTH-1:0] ReadData2,

    output [WIDTH-1:0] ALU_B,
    output [WIDTH-1:0] ALU_Result,

    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,

    output [3:0] ALU_Opcode,
    output [4:0] Shamt,

    output [WIDTH-1:0] Immediate,

    output ALUSrc,
    output RegWrite,

    output Carry,
    output Zero,
    output Negative,
    output Overflow
);


    //==================================================
    // PROGRAM COUNTER
    //==================================================

    program_counter #(
        .WIDTH(WIDTH)
    ) PC_UNIT (

        .clk(clk),
        .reset(reset),
        .PC(PC)

    );


    //==================================================
    // INSTRUCTION MEMORY
    //==================================================

    instruction_memory #(
        .WIDTH(WIDTH),
        .DEPTH(256)
    ) IMEM (

        .Address(PC),
        .Instruction(Instruction)

    );


    //==================================================
    // INSTRUCTION DECODER
    //==================================================

    instruction_decoder DECODER (

        .instruction(Instruction),

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
    // REGISTER FILE
    //==================================================

    reg_file #(
        .WIDTH(WIDTH),
        .DEPTH(32)
    ) REGFILE (

        .clk(clk),
        .reset(reset),

        .ReadAddr1(rs1),
        .ReadData1(ReadData1),

        .ReadAddr2(rs2),
        .ReadData2(ReadData2),

        .WriteAddr(rd),
        .WriteData(ALU_Result),

        .WriteEnable(RegWrite)

    );


    //==================================================
    // ALU INPUT MUX
    //==================================================

    assign ALU_B = ALUSrc ? Immediate : ReadData2;


    //==================================================
    // ALU
    //==================================================

    alu #(
        .WIDTH(WIDTH)
    ) ALU_UNIT (

        .A(ReadData1),
        .B(ALU_B),

        .Opcode(ALU_Opcode),
        .Shamt(Shamt),

        .Result(ALU_Result),

        .Carry(Carry),
        .Zero(Zero),
        .Negative(Negative),
        .Overflow(Overflow)

    );

endmodule