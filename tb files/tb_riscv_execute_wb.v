`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:46:40 08/26/2026
// Design Name:   riscv_execute_wb
// Module Name:   C:/Users/Hendrick/Desktop/Xilinx projects/alu_32bit/tb_riscv_execute_wb.v
// Project Name:  alu_32bit
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: riscv_execute_wb
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_riscv_execute_wb;

    //==================================================
    // CLOCK AND RESET
    //==================================================

    reg clk;
    reg reset;


    //==================================================
    // REGISTER ADDRESSES
    //==================================================

    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;


    //==================================================
    // ALU CONTROL
    //==================================================

    reg [3:0] ALU_Opcode;
    reg [4:0] Shamt;


    //==================================================
    // IMMEDIATE
    //==================================================

    reg [31:0] Immediate;


    //==================================================
    // CONTROL SIGNALS
    //==================================================

    reg ALUSrc;
    reg RegWrite;
    reg WB_Select;


    //==================================================
    // OUTPUTS
    //==================================================

    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    wire [31:0] ALU_B;

    wire [31:0] ALU_Result;

    wire [31:0] WriteBackData;

    wire Carry;
    wire Zero;
    wire Negative;
    wire Overflow;


    //==================================================
    // DUT
    //==================================================

    riscv_execute_wb uut (

        .clk(clk),
        .reset(reset),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .ALU_Opcode(ALU_Opcode),
        .Shamt(Shamt),

        .Immediate(Immediate),

        .ALUSrc(ALUSrc),

        .RegWrite(RegWrite),

        .WB_Select(WB_Select),

        .ReadData1(ReadData1),
        .ReadData2(ReadData2),

        .ALU_B(ALU_B),

        .ALU_Result(ALU_Result),

        .WriteBackData(WriteBackData),

        .Carry(Carry),
        .Zero(Zero),
        .Negative(Negative),
        .Overflow(Overflow)

    );


    //==================================================
    // CLOCK
    //==================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    //==================================================
    // VCD
    //==================================================

    initial begin

        $dumpfile("riscv_execute_wb.vcd");

        $dumpvars(0, tb_riscv_execute_wb);

    end


    //==================================================
    // MONITOR
    //==================================================

    initial begin

        $display("--------------------------------------------------------------------------------------------");

        $display("TIME rs1 rs2 rd  ALUSrc WB  IMM        A          B          RESULT     WB_DATA");

        $display("--------------------------------------------------------------------------------------------");

        $monitor("%4dns %02d  %02d  %02d    %b    %b  %h  %h  %h  %h  %h",
                 $time,
                 rs1,
                 rs2,
                 rd,
                 ALUSrc,
                 WB_Select,
                 Immediate,
                 ReadData1,
                 ALU_B,
                 ALU_Result,
                 WriteBackData);

    end


    //==================================================
    // TEST SEQUENCE
    //==================================================

    initial begin


        //================================================
        // INITIALIZATION
        //================================================

        reset = 1'b1;

        rs1 = 5'd0;
        rs2 = 5'd0;
        rd  = 5'd0;

        ALU_Opcode = 4'b0000;

        Shamt = 5'd0;

        Immediate = 32'd0;

        ALUSrc = 1'b0;

        RegWrite = 1'b0;

        WB_Select = 1'b0;


        // Reset
        #20;

        reset = 1'b0;


        //================================================
        // TEST 1
        // x1 = 10
        //
        // x1 = x0 + 10
        //================================================

        rs1 = 5'd0;

        rs2 = 5'd0;

        rd = 5'd1;

        ALU_Opcode = 4'b0000;     // ADD

        Immediate = 32'd10;

        ALUSrc = 1'b1;            // Use immediate

        WB_Select = 1'b0;         // Write ALU result

        RegWrite = 1'b1;

        #10;


        //================================================
        // TEST 2
        // x2 = 20
        //
        // x2 = x0 + 20
        //================================================

        rs1 = 5'd0;

        rs2 = 5'd0;

        rd = 5'd2;

        ALU_Opcode = 4'b0000;     // ADD

        Immediate = 32'd20;

        ALUSrc = 1'b1;

        WB_Select = 1'b0;

        RegWrite = 1'b1;

        #10;


        //================================================
        // STOP WRITING
        //================================================

        RegWrite = 1'b0;


        //================================================
        // TEST 3
        // x3 = x1 + x2
        //================================================

        rs1 = 5'd1;

        rs2 = 5'd2;

        rd = 5'd3;

        ALU_Opcode = 4'b0000;     // ADD

        Immediate = 32'd0;

        ALUSrc = 1'b0;            // Use register B

        WB_Select = 1'b0;         // ALU result

        RegWrite = 1'b1;

        #10;


        //================================================
        // STOP WRITING
        //================================================

        RegWrite = 1'b0;


        //================================================
        // TEST 4
        // x4 = x3 - 5
        //================================================

        rs1 = 5'd3;

        rs2 = 5'd0;

        rd = 5'd4;

        ALU_Opcode = 4'b0001;     // SUB

        Immediate = 32'd5;

        ALUSrc = 1'b1;            // Immediate

        WB_Select = 1'b0;

        RegWrite = 1'b1;

        #10;


        //================================================
        // TEST 5
        // x5 = x4 AND immediate
        //================================================

        rs1 = 5'd4;

        rs2 = 5'd0;

        rd = 5'd5;

        ALU_Opcode = 4'b0010;     // AND

        Immediate = 32'h0000000F;

        ALUSrc = 1'b1;

        WB_Select = 1'b0;

        RegWrite = 1'b1;

        #10;


        //================================================
        // TEST 6
        // x6 = x5 << 4
        //================================================

        rs1 = 5'd5;

        rs2 = 5'd0;

        rd = 5'd6;

        ALU_Opcode = 4'b0110;     // SLL

        Shamt = 5'd4;

        Immediate = 32'd0;

        ALUSrc = 1'b0;

        WB_Select = 1'b0;

        RegWrite = 1'b1;

        #10;


        //================================================
        // STOP
        //================================================

        RegWrite = 1'b0;

        #10;


               //================================================
        // FINAL REGISTER CHECK
        //================================================

        RegWrite = 1'b0;

        // Read x1 and x2
        rs1 = 5'd1;
        rs2 = 5'd2;
        #2;

        $display("");
        $display("==========================================");
        $display(" FINAL REGISTER CHECK");
        $display("==========================================");
        $display("x1 = %h   Expected = 0000000A", ReadData1);
        $display("x2 = %h   Expected = 00000014", ReadData2);

        // Read x3 and x4
        rs1 = 5'd3;
        rs2 = 5'd4;
        #2;

        $display("x3 = %h   Expected = 0000001E", ReadData1);
        $display("x4 = %h   Expected = 00000019", ReadData2);

        // Read x5 and x6
        rs1 = 5'd5;
        rs2 = 5'd6;
        #2;

        $display("x5 = %h   Expected = 00000009", ReadData1);
        $display("x6 = %h   Expected = 00000090", ReadData2);

        $display("==========================================");

        $finish;
    end

endmodule