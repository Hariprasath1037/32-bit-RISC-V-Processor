`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:10:16 08/26/2026 
// Design Name: 
// Module Name:    alu 
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

module alu #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    input  [3:0]       Opcode,
    input  [4:0]       Shamt,

    output reg [WIDTH-1:0] Result,
    output reg             Carry,
    output reg             Zero,
    output reg             Negative,
    output reg             Overflow
);

    //==================================================
    // OPCODE DEFINITIONS
    //==================================================

    localparam OP_ADD   = 4'b0000;
    localparam OP_SUB   = 4'b0001;
    localparam OP_AND   = 4'b0010;
    localparam OP_OR    = 4'b0011;
    localparam OP_XOR   = 4'b0100;
    localparam OP_NOT   = 4'b0101;

    localparam OP_SLL   = 4'b0110;
    localparam OP_SRL   = 4'b0111;

    localparam OP_SLT   = 4'b1000;
    localparam OP_SLTU  = 4'b1001;

    localparam OP_NAND  = 4'b1010;
    localparam OP_NOR   = 4'b1011;
    localparam OP_XNOR  = 4'b1100;

    localparam OP_ROL   = 4'b1101;
    localparam OP_ROR   = 4'b1110;

    localparam OP_PASSB = 4'b1111;


    //==================================================
    // SHARED ADD / SUB HARDWARE
    //==================================================

    wire is_sub;

    assign is_sub = (Opcode == OP_SUB);

    wire [WIDTH-1:0] B_operand;

    assign B_operand = B ^ {WIDTH{is_sub}};

    wire [WIDTH:0] arithmetic_result;

    assign arithmetic_result =
            {1'b0, A} +
            {1'b0, B_operand} +
            is_sub;


    //==================================================
    // MAIN ALU
    //==================================================

    always @(*) begin

        // Default values
        Result   = {WIDTH{1'b0}};
        Carry    = 1'b0;
        Overflow = 1'b0;

        case (Opcode)

            //==========================================
            // ADD
            //==========================================

            OP_ADD: begin

                Result = arithmetic_result[WIDTH-1:0];

                Carry = arithmetic_result[WIDTH];

                Overflow =
                    (~A[WIDTH-1] &
                     ~B[WIDTH-1] &
                      Result[WIDTH-1]) |
                    ( A[WIDTH-1] &
                      B[WIDTH-1] &
                     ~Result[WIDTH-1]);

            end


            //==========================================
            // SUB
            //==========================================

            OP_SUB: begin

                Result = arithmetic_result[WIDTH-1:0];

                Carry = arithmetic_result[WIDTH];

                Overflow =
                    (~A[WIDTH-1] &
                      B[WIDTH-1] &
                      Result[WIDTH-1]) |
                    ( A[WIDTH-1] &
                     ~B[WIDTH-1] &
                     ~Result[WIDTH-1]);

            end


            //==========================================
            // BASIC LOGIC
            //==========================================

            OP_AND:
                Result = A & B;

            OP_OR:
                Result = A | B;

            OP_XOR:
                Result = A ^ B;

            OP_NOT:
                Result = ~A;


            //==========================================
            // BARREL SHIFTER
            //==========================================

            OP_SLL:
                Result = A << Shamt;

            OP_SRL:
                Result = A >> Shamt;


            //==========================================
            // SIGNED COMPARISON
            //==========================================

            OP_SLT: begin

                Result = {WIDTH{1'b0}};

                if ($signed(A) < $signed(B))
                    Result[0] = 1'b1;

            end


            //==========================================
            // UNSIGNED COMPARISON
            //==========================================

            OP_SLTU: begin

                Result = {WIDTH{1'b0}};

                if (A < B)
                    Result[0] = 1'b1;

            end


            //==========================================
            // ADDITIONAL LOGIC
            //==========================================

            OP_NAND:
                Result = ~(A & B);

            OP_NOR:
                Result = ~(A | B);

            OP_XNOR:
                Result = ~(A ^ B);


            //==========================================
            // ROTATE LEFT
            //==========================================

            OP_ROL: begin

                if (Shamt == 0)
                    Result = A;
                else
                    Result = (A << Shamt) |
                             (A >> (WIDTH - Shamt));

            end


            //==========================================
            // ROTATE RIGHT
            //==========================================

            OP_ROR: begin

                if (Shamt == 0)
                    Result = A;
                else
                    Result = (A >> Shamt) |
                             (A << (WIDTH - Shamt));

            end


            //==========================================
            // PASS B
            //==========================================

            OP_PASSB:
                Result = B;


            //==========================================
            // DEFAULT
            //==========================================

            default:
                Result = {WIDTH{1'b0}};

        endcase


        //================================================
        // COMMON FLAGS
        //================================================

        Zero     = (Result == {WIDTH{1'b0}});

        Negative = Result[WIDTH-1];

    end

endmodule