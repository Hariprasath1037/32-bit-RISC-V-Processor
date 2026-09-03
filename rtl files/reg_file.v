`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:12:42 08/26/2026 
// Design Name: 
// Module Name:    reg_file 
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

module reg_file #(
    parameter WIDTH = 32,
    parameter DEPTH = 32
)(
    input clk,
    input reset,

    //==================================================
    // READ PORT 1
    //==================================================

    input [4:0] ReadAddr1,
    output [WIDTH-1:0] ReadData1,

    //==================================================
    // READ PORT 2
    //==================================================

    input [4:0] ReadAddr2,
    output [WIDTH-1:0] ReadData2,

    //==================================================
    // WRITE PORT
    //==================================================

    input [4:0] WriteAddr,
    input [WIDTH-1:0] WriteData,
    input WriteEnable
);


    //==================================================
    // REGISTER ARRAY
    //==================================================

    reg [WIDTH-1:0] registers [0:DEPTH-1];

    integer i;


    //==================================================
    // SYNCHRONOUS WRITE
    //==================================================

    always @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < DEPTH; i = i + 1)
                registers[i] <= {WIDTH{1'b0}};

        end

        else begin

            // x0 is always zero
            registers[0] <= {WIDTH{1'b0}};

            // Write only if enabled
            // and destination is not x0
            if (WriteEnable && (WriteAddr != 5'd0))
                registers[WriteAddr] <= WriteData;

        end

    end


    //==================================================
    // ASYNCHRONOUS READ PORT 1
    //==================================================

    assign ReadData1 =
        (ReadAddr1 == 5'd0) ?
        {WIDTH{1'b0}} :
        registers[ReadAddr1];


    //==================================================
    // ASYNCHRONOUS READ PORT 2
    //==================================================

    assign ReadData2 =
        (ReadAddr2 == 5'd0) ?
        {WIDTH{1'b0}} :
        registers[ReadAddr2];


endmodule