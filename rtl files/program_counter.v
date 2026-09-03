`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:44:32 08/26/2026 
// Design Name: 
// Module Name:    program_counter 
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

module program_counter #(
    parameter WIDTH = 32
)(
    input clk,
    input reset,

    output reg [WIDTH-1:0] PC
);

    always @(posedge clk) begin

        if (reset)
            PC <= {WIDTH{1'b0}};
        else
            PC <= PC + 4;

    end

endmodule
