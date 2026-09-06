`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:39:13 08/26/2026 
// Design Name: 
// Module Name:    riscv_datapath 
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
/////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module riscv_datapath #(
    parameter WIDTH = 32
)(
    input clk,
    input reset,

    //==================================================
    // 32-BIT RISC-V INSTRUCTION
    //==================================================

    input [31:0] instruction,

    //==================================================
    // DEBUG OUTPUTS
    //==================================================

    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,

    output [31:0] Immediate,

    output [3:0] ALU_Opcode,

    output [4:0] Shamt,

    output ALUSrc,
    output RegWrite,

    output [WIDTH-1:0] ReadData1,
    output [WIDTH-1:0] ReadData2,

    output [WIDTH-1:0] ALU_B,

    output [WIDTH-1:0] ALU_Result,

    output Carry,
    output Zero,
    output Negative,
    output Overflow
);


    //==================================================
    // INTERNAL REGISTER FILE SIGNALS
    //==================================================

    wire [WIDTH-1:0] reg_data1;
    wire [WIDTH-1:0] reg_data2;


    //==================================================
    // ALU INPUT B
    //==================================================

    reg [WIDTH-1:0] alu_input_b;


    //==================================================
    // ALU SHIFT AMOUNT
    //==================================================

    reg [4:0] alu_shamt;


    //==================================================
    // INSTRUCTION DECODER
    //==================================================

    instruction_decoder DECODER (

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
    // REGISTER FILE
    //==================================================

    reg_file #(
        .WIDTH(WIDTH),
        .DEPTH(32)
    ) RF (

        .clk(clk),
        .reset(reset),

        .ReadAddr1(rs1),
        .ReadData1(reg_data1),

        .ReadAddr2(rs2),
        .ReadData2(reg_data2),

        .WriteAddr(rd),
        .WriteData(ALU_Result),
        .WriteEnable(RegWrite)

    );


    //==================================================
    // ALUSrc MULTIPLEXER
    //
    // ALUSrc = 0 -> Register data
    // ALUSrc = 1 -> Immediate
    //==================================================

    always @(*) begin

        if (ALUSrc)
            alu_input_b = Immediate;
        else
            alu_input_b = reg_data2;

    end


    //==================================================
    // SHIFT AMOUNT SELECTION
    //
    // I-type:
    //     use instruction Shamt
    //
    // R-type:
    //     use lower 5 bits of rs2 value
    //==================================================

    always @(*) begin

        if (ALUSrc)
            alu_shamt = Shamt;
        else
            alu_shamt = reg_data2[4:0];

    end


    //==================================================
    // ALU
    //==================================================

    alu #(
        .WIDTH(WIDTH)
    ) ALU (

        .A(reg_data1),

        .B(alu_input_b),

        .Opcode(ALU_Opcode),

        .Shamt(alu_shamt),

        .Result(ALU_Result),

        .Carry(Carry),

        .Zero(Zero),

        .Negative(Negative),

        .Overflow(Overflow)

    );


    //==================================================
    // DEBUG OUTPUTS
    //==================================================

    assign ReadData1 = reg_data1;

    assign ReadData2 = reg_data2;

    assign ALU_B = alu_input_b;


endmodule