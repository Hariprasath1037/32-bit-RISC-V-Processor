`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:13:44 08/26/2026
// Design Name:   reg_file
// Module Name:   C:/Users/Hendrick/Desktop/Xilinx projects/alu_32bit/tb_reg.v
// Project Name:  alu_32bit
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: reg_file
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_reg;

    //==================================================
    // Clock and Reset
    //==================================================

    reg clk;
    reg reset;


    //==================================================
    // READ PORTS
    //==================================================

    reg [4:0] ReadAddr1;
    reg [4:0] ReadAddr2;

    wire [31:0] ReadData1;
    wire [31:0] ReadData2;


    //==================================================
    // WRITE PORT
    //==================================================

    reg [4:0] WriteAddr;
    reg [31:0] WriteData;
    reg WriteEnable;


    //==================================================
    // DUT
    //==================================================

    reg_file #(
        .WIDTH(32),
        .DEPTH(32)
    ) uut (

        .clk(clk),
        .reset(reset),

        .ReadAddr1(ReadAddr1),
        .ReadData1(ReadData1),

        .ReadAddr2(ReadAddr2),
        .ReadData2(ReadData2),

        .WriteAddr(WriteAddr),
        .WriteData(WriteData),
        .WriteEnable(WriteEnable)

    );


    //==================================================
    // CLOCK GENERATION
    //==================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    //==================================================
    // VCD
    //==================================================

    initial begin

        $dumpfile("register_file.vcd");

        $dumpvars(0, tb_reg);

    end


    //==================================================
    // MONITOR
    //==================================================

    initial begin

        $display("--------------------------------------------------------------------------");

        $display("TIME  WE  WA   WD          RA1   RD1         RA2   RD2");

        $display("--------------------------------------------------------------------------");

        $monitor("%4dns  %b   %02d   %h   %02d    %h   %02d    %h",
                 $time,
                 WriteEnable,
                 WriteAddr,
                 WriteData,
                 ReadAddr1,
                 ReadData1,
                 ReadAddr2,
                 ReadData2);

    end


    //==================================================
    // TEST SEQUENCE
    //==================================================

    initial begin


        //================================================
        // INITIAL VALUES
        //================================================

        reset = 1'b1;

        WriteEnable = 1'b0;

        WriteAddr = 5'd0;

        WriteData = 32'h00000000;

        ReadAddr1 = 5'd0;

        ReadAddr2 = 5'd0;


        // Hold reset
        #20;


        // Release reset
        reset = 1'b0;


        //================================================
        // WRITE x1 = 100
        //================================================

        WriteEnable = 1'b1;

        WriteAddr = 5'd1;

        WriteData = 32'h00000064;

        #10;


        //================================================
        // WRITE x2 = 200
        //================================================

        WriteAddr = 5'd2;

        WriteData = 32'h000000C8;

        #10;


        //================================================
        // STOP WRITING
        //================================================

        WriteEnable = 1'b0;


        //================================================
        // READ x1 AND x2
        //================================================

        ReadAddr1 = 5'd1;

        ReadAddr2 = 5'd2;

        #10;


        $display("READ TEST:");
        $display("x1 = %h", ReadData1);
        $display("x2 = %h", ReadData2);


        //================================================
        // WRITE x10
        //================================================

        WriteEnable = 1'b1;

        WriteAddr = 5'd10;

        WriteData = 32'h12345678;

        #10;


        // Stop writing
        WriteEnable = 1'b0;


        //================================================
        // READ x10 AND x1
        //================================================

        ReadAddr1 = 5'd10;

        ReadAddr2 = 5'd1;

        #10;


        $display("x10 = %h", ReadData1);
        $display("x1  = %h", ReadData2);


        //================================================
        // TEST x0
        //================================================

        // Try to write FFFFFFFF to x0

        WriteEnable = 1'b1;

        WriteAddr = 5'd0;

        WriteData = 32'hFFFFFFFF;

        #10;


        // Stop writing
        WriteEnable = 1'b0;


        // Read x0
        ReadAddr1 = 5'd0;

        ReadAddr2 = 5'd0;

        #10;


        $display("x0 = %h", ReadData1);


        //================================================
        // FINISH
        //================================================

        $finish;

    end

endmodule