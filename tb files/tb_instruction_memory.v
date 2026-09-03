`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:55:27 08/27/2026
// Design Name:   instruction_memory
// Module Name:   C:/Users/Hendrick/Desktop/Xilinx projects/alu_32bit/tb_instruction_memory.v
// Project Name:  alu_32bit
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: instruction_memory
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_instruction_memory;

    reg [31:0] Address;

    wire [31:0] Instruction;


    //==================================================
    // DUT
    //==================================================

    instruction_memory #(
        .WIDTH(32),
        .DEPTH(256)
    ) uut (

        .Address(Address),
        .Instruction(Instruction)

    );


    //==================================================
    // MONITOR
    //==================================================

    initial begin

        $display("");
        $display("==============================================================");
        $display(" ADDRESS       INSTRUCTION");
        $display("==============================================================");

        $monitor(" %h        %h",
                 Address,
                 Instruction);

    end


    //==================================================
    // TEST
    //==================================================

    initial begin

        // Address 0
        Address = 32'h00000000;
        #10;


        // Address 4
        Address = 32'h00000004;
        #10;


        // Address 8
        Address = 32'h00000008;
        #10;


        // Address 12
        Address = 32'h0000000C;
        #10;


        // Address 16
        Address = 32'h00000010;
        #10;


        // Address 20
        Address = 32'h00000014;
        #10;


        // Address 24
        Address = 32'h00000018;
        #10;


        // Address 28
        Address = 32'h0000001C;
        #10;


        // Address 32
        Address = 32'h00000020;
        #10;


        // Unused address
        Address = 32'h00000024;
        #10;


        $display("");
        $display("==============================================================");
        $display("INSTRUCTION MEMORY TEST COMPLETE");
        $display("==============================================================");

        $finish;

    end

endmodule
