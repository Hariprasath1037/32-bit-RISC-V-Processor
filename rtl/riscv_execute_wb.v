`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:46:05 08/26/2026 
// Design Name: 
// Module Name:    riscv_execute_wb 
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

module riscv_execute_wb #(
    parameter WIDTH = 32
)(
    input clk,
    input reset,

    //==================================================
    // REGISTER ADDRESSES
    //==================================================

    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,

    //==================================================
    // ALU CONTROL
    //==================================================

    input [3:0] ALU_Opcode,
    input [4:0] Shamt,

    //==================================================
    // IMMEDIATE
    //==================================================

    input [WIDTH-1:0] Immediate,

    //==================================================
    // ALU SOURCE SELECT
    //
    // 0 = Register B
    // 1 = Immediate
    //==================================================

    input ALUSrc,

    //==================================================
    // REGISTER WRITE
    //==================================================

    input RegWrite,

    //==================================================
    // WRITEBACK SELECT
    //
    // 0 = ALU Result
    // 1 = Immediate
    //==================================================

    input WB_Select,

    //==================================================
    // OUTPUTS
    //==================================================

    output [WIDTH-1:0] ReadData1,
    output [WIDTH-1:0] ReadData2,

    output [WIDTH-1:0] ALU_B,

    output [WIDTH-1:0] ALU_Result,

    output [WIDTH-1:0] WriteBackData,

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
    // WRITEBACK DATA
    //==================================================

    reg [WIDTH-1:0] writeback_data;


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
        .WriteData(writeback_data),
        .WriteEnable(RegWrite)

    );


    //==================================================
    // ALU SOURCE MUX
    //==================================================

    always @(*) begin

        if (ALUSrc)
            alu_input_b = Immediate;
        else
            alu_input_b = reg_data2;

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
        .Shamt(Shamt),

        .Result(ALU_Result),

        .Carry(Carry),
        .Zero(Zero),
        .Negative(Negative),
        .Overflow(Overflow)

    );


    //==================================================
    // WRITEBACK MUX
    //==================================================

    always @(*) begin

        if (WB_Select)
            writeback_data = Immediate;
        else
            writeback_data = ALU_Result;

    end


    //==================================================
    // OUTPUT CONNECTIONS
    //==================================================

    assign ReadData1 = reg_data1;

    assign ReadData2 = reg_data2;

    assign ALU_B = alu_input_b;

    assign WriteBackData = writeback_data;


endmodule