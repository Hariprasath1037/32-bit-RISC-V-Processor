`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:54:20 08/27/2026 
// Design Name: 
// Module Name:    instruction_memory 
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

module instruction_memory #(
    parameter WIDTH = 32,
    parameter DEPTH = 256
)(
    input  [WIDTH-1:0] Address,
    output [WIDTH-1:0] Instruction
);

    //==================================================
    // MEMORY ARRAY
    //==================================================

    reg [WIDTH-1:0] memory [0:DEPTH-1];


    //==================================================
    // INITIALIZE MEMORY
    //==================================================

    integer i;

    initial begin

        // Clear memory
        for (i = 0; i < DEPTH; i = i + 1)
            memory[i] = {WIDTH{1'b0}};


        //================================================
        // PROGRAM
        //================================================

        // Address: 0x00000000
        // ADDI x1,x0,10
        memory[0] = 32'h00A00093;


        // Address: 0x00000004
        // ADDI x2,x0,20
        memory[1] = 32'h01400113;


        // Address: 0x00000008
        // ADD x3,x1,x2
        memory[2] = 32'h002081B3;


        // Address: 0x0000000C
        // SUB x4,x3,x1
        memory[3] = 32'h40118233;


        // Address: 0x00000010
        // AND x5,x3,x4
        memory[4] = 32'h0041F2B3;


        // Address: 0x00000014
        // OR x6,x3,x4
        memory[5] = 32'h0041E333;


        // Address: 0x00000018
        // XOR x7,x3,x4
        memory[6] = 32'h0041C3B3;


        // Address: 0x0000001C
        // SLL x8,x7,x2
        memory[7] = 32'h00239433;


        // Address: 0x00000020
        // SRL x9,x8,x1
        memory[8] = 32'h001454B3;

    end


    //==================================================
    // ASYNCHRONOUS READ
    //==================================================

    assign Instruction = memory[Address[9:2]];

endmodule