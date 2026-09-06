`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:01:48 08/26/2026 
// Design Name: 
// Module Name:    instruction_decoder 
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

module instruction_decoder (

    input [31:0] instruction,

    // Register fields
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,

    // Immediate
    output reg [31:0] Immediate,

    // ALU control
    output reg [3:0] ALU_Opcode,

    // Shift amount
    output reg [4:0] Shamt,

    // Control signals
    output reg ALUSrc,
    output reg RegWrite
);

    //==================================================
    // RISC-V OPCODES
    //==================================================

    localparam OPCODE_RTYPE = 7'b0110011;
    localparam OPCODE_ITYPE = 7'b0010011;


    //==================================================
    // ALU OPCODES
    //==================================================

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;

    localparam ALU_SLL  = 4'b0110;
    localparam ALU_SRL  = 4'b0111;

    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;


    //==================================================
    // EXTRACT REGISTER FIELDS
    //==================================================

    assign rd  = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];


    //==================================================
    // INTERNAL INSTRUCTION FIELDS
    //==================================================

    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];


    //==================================================
    // DECODER
    //==================================================

    always @(*) begin

        // Default values

        Immediate = 32'b0;

        ALU_Opcode = ALU_ADD;

        Shamt = 5'b0;

        ALUSrc = 1'b0;

        RegWrite = 1'b0;


        case (opcode)

            //================================================
            // R-TYPE
            //================================================

            OPCODE_RTYPE: begin

                RegWrite = 1'b1;
                ALUSrc = 1'b0;

                case (funct3)

                    // ADD / SUB
                    3'b000: begin

                        if (funct7 == 7'b0100000)
                            ALU_Opcode = ALU_SUB;
                        else
                            ALU_Opcode = ALU_ADD;

                    end


                    // SLL
                    3'b001: begin
							  ALU_Opcode = ALU_SLL;
							  Shamt = instruction[24:20];
						  end


                    // SLT
                    3'b010: begin
                        ALU_Opcode = ALU_SLT;
                    end


                    // SLTU
                    3'b011: begin
                        ALU_Opcode = ALU_SLTU;
                    end


                    // XOR
                    3'b100: begin
                        ALU_Opcode = ALU_XOR;
                    end


                    // SRL
                    3'b101: begin
								ALU_Opcode = ALU_SRL;
								Shamt = instruction[24:20];
						  end


                    // OR
                    3'b110: begin
                        ALU_Opcode = ALU_OR;
                    end


                    // AND
                    3'b111: begin
                        ALU_Opcode = ALU_AND;
                    end


                    default: begin
                        ALU_Opcode = ALU_ADD;
                        RegWrite = 1'b0;
                    end

                endcase

            end


            //================================================
            // I-TYPE
            //================================================

            OPCODE_ITYPE: begin

                RegWrite = 1'b1;
                ALUSrc = 1'b1;

                // Sign extend 12-bit immediate

                Immediate = {{20{instruction[31]}},
                             instruction[31:20]};


                case (funct3)

                    // ADDI
                    3'b000: begin
                        ALU_Opcode = ALU_ADD;
                    end


                    // SLLI
                    3'b001: begin

                        ALU_Opcode = ALU_SLL;

                        Shamt = instruction[24:20];

                    end


                    // SLTI
                    3'b010: begin
                        ALU_Opcode = ALU_SLT;
                    end


                    // SLTIU
                    3'b011: begin
                        ALU_Opcode = ALU_SLTU;
                    end


                    // XORI
                    3'b100: begin
                        ALU_Opcode = ALU_XOR;
                    end


                    // SRLI
                    3'b101: begin

                        ALU_Opcode = ALU_SRL;

                        Shamt = instruction[24:20];

                    end


                    // ORI
                    3'b110: begin
                        ALU_Opcode = ALU_OR;
                    end


                    // ANDI
                    3'b111: begin
                        ALU_Opcode = ALU_AND;
                    end


                    default: begin
                        ALU_Opcode = ALU_ADD;
                        RegWrite = 1'b0;
                    end

                endcase

            end


            //================================================
            // UNSUPPORTED INSTRUCTION
            //================================================

            default: begin

                Immediate = 32'b0;

                ALU_Opcode = ALU_ADD;

                Shamt = 5'b0;

                ALUSrc = 1'b0;

                RegWrite = 1'b0;

            end

        endcase

    end

endmodule