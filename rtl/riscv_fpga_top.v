`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:33 08/28/2026 
// Design Name: 
// Module Name:    riscv_fpga_top 
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
`timescale 1ns / 1ps

module riscv_fpga_top #(
    parameter WIDTH = 32
)(
    input clk,
    input reset,

    output [7:0] LED
);

    //==================================================
    // INTERNAL PROCESSOR SIGNALS
    //==================================================

    wire [WIDTH-1:0] PC;
    wire [WIDTH-1:0] Instruction;

    wire [WIDTH-1:0] ReadData1;
    wire [WIDTH-1:0] ReadData2;

    wire [WIDTH-1:0] ALU_B;
    wire [WIDTH-1:0] ALU_Result;

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [3:0] ALU_Opcode;
    wire [4:0] Shamt;

    wire [WIDTH-1:0] Immediate;

    wire ALUSrc;
    wire RegWrite;

    wire Carry;
    wire Zero;
    wire Negative;
    wire Overflow;


    //==================================================
    // RISC-V CORE
    //==================================================

    riscv_core #(
        .WIDTH(WIDTH)
    ) CORE (

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
    // FPGA OUTPUT
    //==================================================

    assign LED = ALU_Result[7:0];

endmodule