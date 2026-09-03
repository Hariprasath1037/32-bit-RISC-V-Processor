`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:49:56 08/26/2026
// Design Name:   program_counter
// Module Name:   C:/Users/Hendrick/Desktop/Xilinx projects/alu_32bit/tb_program_counter.v
// Project Name:  alu_32bit
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: program_counter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_program_counter;

    //==================================================
    // SIGNALS
    //==================================================

    reg clk;
    reg reset;

    wire [31:0] PC;


    //==================================================
    // DUT
    //==================================================

    program_counter #(
        .WIDTH(32)
    ) uut (

        .clk(clk),
        .reset(reset),
        .PC(PC)

    );


    //==================================================
    // CLOCK
    //==================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    //==================================================
    // MONITOR
    //==================================================

    initial begin

        $display("");
        $display("==========================================");
        $display(" TIME       RESET       PC");
        $display("==========================================");

        $monitor("%4dns       %b       %h",
                 $time,
                 reset,
                 PC);

    end


    //==================================================
    // TEST
    //==================================================

    initial begin

        // Reset
        reset = 1'b1;

        #12;

        // Release reset
        reset = 1'b0;

        // Allow several clock cycles
        #60;

        // Reset again
        reset = 1'b1;

        #10;

        // Release reset again
        reset = 1'b0;

        #30;

        $display("");
        $display("==========================================");
        $display("PROGRAM COUNTER TEST COMPLETE");
        $display("==========================================");

        $finish;

    end

endmodule