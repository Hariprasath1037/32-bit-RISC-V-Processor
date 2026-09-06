# 32-bit RISC-V Processor — Architecture & Module Guide

## 1. Purpose

This document explains how the Verilog RTL modules in this repository work individually and how they are integrated to form the processor.

The implementation is a compact 32-bit RISC-V-based processor datapath. The current instruction decoder supports the R-type and I-type ALU instruction groups shown in this document.

> **Important:** `riscv_core.v` is the main integrated processor path used by `riscv_fpga_top.v`. `riscv_datapath.v` and `riscv_execute_wb.v` are separate reusable datapath/execute-write-back implementations present in the project and are not instantiated by `riscv_core.v`.

---

## 2. High-Level Architecture

The main integrated path is:

```text
                         ┌────────────────────┐
                         │  Program Counter    │
                         │  program_counter.v  │
                         └─────────┬──────────┘
                                   │ PC
                                   ▼
                         ┌────────────────────┐
                         │ Instruction Memory │
                         │ instruction_memory │
                         └─────────┬──────────┘
                                   │ Instruction[31:0]
                                   ▼
                         ┌────────────────────┐
                         │ Instruction        │
                         │ Decoder            │
                         │ instruction_decoder│
                         └──────┬─────┬───────┘
                                │     │
                 rs1/rs2/rd ────┘     └── ALU control / immediate
                                │
                                ▼
                         ┌────────────────────┐
                         │   Register File    │
                         │    reg_file.v      │
                         └──────┬─────┬───────┘
                                │     │
                         ReadData1    ReadData2
                                │     │
                                │     ▼
                                │  ┌─────────────┐
                                │  │   ALU B     │
                                │  │     MUX      │
                                │  └──────┬──────┘
                                │         │
                                └────┬────┘
                                     ▼
                              ┌─────────────┐
                              │     ALU     │
                              │    alu.v    │
                              └──────┬──────┘
                                     │ ALU_Result
                                     ▼
                              Register File
                                Write Data
```

The FPGA wrapper then exposes the low 8 bits of the ALU result on the LEDs:

```text
riscv_fpga_top
       │
       ▼
  riscv_core
       │
       ▼
 ALU_Result[7:0]
       │
       ▼
    LED[7:0]
```

---

# 3. Module Overview

| File | Main responsibility |
|---|---|
| `program_counter.v` | Holds the current instruction address and advances by 4 each clock |
| `instruction_memory.v` | Stores the demonstration program and provides an instruction using the PC |
| `instruction_decoder.v` | Extracts instruction fields and generates ALU/control signals |
| `reg_file.v` | Provides two asynchronous read ports and one synchronous write port |
| `alu.v` | Performs arithmetic, logical, shift, comparison, and additional ALU operations |
| `riscv_datapath.v` | Standalone datapath integrating decoder, register file, ALU and operand selection |
| `riscv_execute_wb.v` | Standalone execute/write-back block with ALU and write-back selection |
| `riscv_core.v` | Main integrated processor core connecting PC, memory, decoder, register file and ALU |
| `riscv_fpga_top.v` | FPGA top-level wrapper and LED output interface |

---

# 4. Program Counter — `program_counter.v`

## Purpose

The program counter (PC) stores the address of the current instruction.

### Inputs

```text
clk
reset
```

### Output

```text
PC[31:0]
```

## Operation

At every positive clock edge:

```verilog
if (reset)
    PC <= 0;
else
    PC <= PC + 4;
```

Therefore:

```text
Reset → PC = 0

Next clock → PC = 4
Next clock → PC = 8
Next clock → PC = 12
...
```

The increment is 4 because each stored instruction is 32 bits = 4 bytes.

## Important limitation

This PC implementation only performs sequential `PC + 4` progression. There is no branch/jump target selection in this module.

---

# 5. Instruction Memory — `instruction_memory.v`

## Purpose

The instruction memory stores a small hard-coded demonstration program.

It is parameterized as:

```text
WIDTH = 32
DEPTH = 256
```

So the memory contains 256 entries of 32 bits.

## Addressing

The instruction is read asynchronously using:

```verilog
assign Instruction = memory[Address[9:2]];
```

The lower two address bits are ignored because instructions are word-aligned.

For example:

```text
PC = 0x00000000 → memory[0]
PC = 0x00000004 → memory[1]
PC = 0x00000008 → memory[2]
PC = 0x0000000C → memory[3]
```

## Program stored in the current implementation

```text
Address       Instruction

0x00          ADDI x1, x0, 10
0x04          ADDI x2, x0, 20
0x08          ADD  x3, x1, x2
0x0C          SUB  x4, x3, x1
0x10          AND  x5, x3, x4
0x14          OR   x6, x3, x4
0x18          XOR  x7, x3, x4
0x1C          SLL  x8, x7, x2
0x20          SRL  x9, x8, x1
```

This gives the project a deterministic demonstration sequence for simulation and FPGA testing.

---

# 6. Instruction Decoder — `instruction_decoder.v`

## Purpose

The decoder converts the 32-bit RISC-V instruction into:

- source register addresses
- destination register address
- immediate value
- ALU operation
- shift amount
- ALU source selection
- register write enable

## Register field extraction

The decoder extracts the standard register fields:

```text
rd  = instruction[11:7]
rs1 = instruction[19:15]
rs2 = instruction[24:20]
```

It also extracts:

```text
opcode = instruction[6:0]
funct3 = instruction[14:12]
funct7 = instruction[31:25]
```

---

## Supported instruction groups

The current decoder explicitly recognizes:

```text
R-type opcode = 0110011
I-type opcode = 0010011
```

### R-type operations

The decoder maps the `funct3`/`funct7` fields to:

```text
ADD
SUB
SLL
SLT
SLTU
XOR
SRL
OR
AND
```

For ADD/SUB, `funct7 = 0100000` selects SUB; otherwise the decoder selects ADD for that `funct3` value.

### I-type operations

The decoder supports:

```text
ADDI
SLLI
SLTI
SLTIU
XORI
SRLI
ORI
ANDI
```

For I-type instructions:

```text
ALUSrc   = 1
RegWrite = 1
```

and the 12-bit immediate is sign-extended to 32 bits:

```verilog
Immediate = {{20{instruction[31]}}, instruction[31:20]};
```

---

# 7. Register File — `reg_file.v`

## Purpose

The register file contains:

```text
32 registers × 32 bits
```

It has:

```text
2 asynchronous read ports
1 synchronous write port
```

### Read ports

```text
ReadAddr1 → ReadData1
ReadAddr2 → ReadData2
```

### Write port

```text
WriteAddr
WriteData
WriteEnable
```

## x0 behavior

RISC-V register `x0` must always read as zero.

The implementation explicitly ensures:

```verilog
if (ReadAddr1 == 0)
    ReadData1 = 0;
```

and similarly for the second read port.

During a clock edge, register 0 is also forced to zero:

```verilog
registers[0] <= 0;
```

A write to `x0` is blocked:

```verilog
if (WriteEnable && (WriteAddr != 0))
    registers[WriteAddr] <= WriteData;
```

This is an important RISC-V architectural behavior.

---

# 8. ALU — `alu.v`

## Purpose

The ALU is the main execution unit.

It accepts:

```text
A[31:0]
B[31:0]
Opcode[3:0]
Shamt[4:0]
```

and produces:

```text
Result[31:0]
Carry
Zero
Negative
Overflow
```

## ALU operation encoding

The implementation defines:

| Opcode | Operation |
|---|---|
| `0000` | ADD |
| `0001` | SUB |
| `0010` | AND |
| `0011` | OR |
| `0100` | XOR |
| `0101` | NOT |
| `0110` | SLL |
| `0111` | SRL |
| `1000` | SLT |
| `1001` | SLTU |
| `1010` | NAND |
| `1011` | NOR |
| `1100` | XNOR |
| `1101` | ROL |
| `1110` | ROR |
| `1111` | PASS B |

The instruction decoder currently uses a subset of these operations.

## Shared ADD/SUB arithmetic

The ALU uses common arithmetic hardware for ADD and SUB.

For subtraction, the B operand is conditionally inverted:

```verilog
B_operand = B ^ {WIDTH{is_sub}};
```

and:

```verilog
A + B_operand + is_sub
```

implements:

```text
ADD: A + B
SUB: A + (~B) + 1
```

This is the standard two's-complement subtraction approach.

## Flags

### Zero

```text
Zero = 1 when Result == 0
```

### Negative

```text
Negative = Result[31]
```

This represents the sign bit for a 32-bit two's-complement result.

### Carry

For ADD/SUB, `Carry` is taken from the extra arithmetic result bit.

### Overflow

The ALU separately calculates signed arithmetic overflow for ADD and SUB.

For example, adding two positive signed numbers and obtaining a negative sign indicates signed overflow.

---

# 9. ALU Source MUX

The ALU's second operand is selected by `ALUSrc`.

```text
ALUSrc = 0
    ALU_B = ReadData2

ALUSrc = 1
    ALU_B = Immediate
```

Therefore:

```text
R-type:
Register A ───────┐
                   ├── ALU
Register B ───────┘

I-type:
Register A ───────┐
                   ├── ALU
Immediate ────────┘
```

This is a key connection between the decoder, register file and ALU.

---

# 10. Shift Amount Selection in `riscv_datapath.v`

The standalone `riscv_datapath.v` contains additional shift-amount selection logic:

```text
ALUSrc = 1 → use decoded Shamt
ALUSrc = 0 → use reg_data2[4:0]
```

So it can provide:

```text
I-type shift → instruction Shamt
R-type shift → lower 5 bits of rs2 value
```

This is separate from the main `riscv_core.v` implementation, where the decoder directly supplies `Shamt` to the ALU.

---

# 11. Datapath — `riscv_datapath.v`

## Purpose

This module is a reusable datapath implementation connecting:

```text
Instruction
    ↓
Instruction Decoder
    ↓
Register File
    ↓
ALU input MUX
    ↓
ALU
```

It exposes many internal signals as outputs, making it particularly useful for simulation and waveform inspection.

### Main flow

```text
instruction
     │
     ▼
decoder
     │
     ├── rs1 ──────────┐
     ├── rs2 ──────────┤
     ├── rd            │
     ├── Immediate     │
     ├── ALU_Opcode    │
     ├── Shamt         │
     ├── ALUSrc        │
     └── RegWrite      │
                        ▼
                  Register File
                  ┌───────────┐
                  │           │
             data1           data2
                  │           │
                  │      ┌────┴────┐
                  │      │   MUX   │
                  │      └────┬────┘
                  │           │
                  └─────┬─────┘
                        ▼
                       ALU
                        │
                        ▼
                   ALU_Result
```

---

# 12. Execute / Write-Back — `riscv_execute_wb.v`

This module is a separate execute/write-back datapath.

It contains:

1. Register file
2. ALU source MUX
3. ALU
4. Write-back MUX

## ALU input selection

```text
ALUSrc = 0 → ReadData2
ALUSrc = 1 → Immediate
```

## Write-back selection

The module provides:

```text
WB_Select = 0 → ALU_Result
WB_Select = 1 → Immediate
```

The selected value is written back to the destination register when:

```text
RegWrite = 1
```

### Important integration note

`riscv_execute_wb.v` is **not instantiated inside `riscv_core.v`** in the current implementation. It is therefore best described as a separate/reusable execute-write-back module rather than as a block in the active `riscv_core` path.

---

# 13. Main Processor Core — `riscv_core.v`

This is the central integration module.

It connects:

```text
Program Counter
Instruction Memory
Instruction Decoder
Register File
ALU input MUX
ALU
```

## Complete signal flow

```text
                 ┌──────────────────┐
                 │ Program Counter  │
                 └────────┬─────────┘
                          │ PC
                          ▼
                 ┌──────────────────┐
                 │ Instruction      │
                 │ Memory           │
                 └────────┬─────────┘
                          │ Instruction
                          ▼
                 ┌──────────────────┐
                 │ Instruction      │
                 │ Decoder          │
                 └───┬────────┬─────┘
                     │        │
              rs1/rs2/rd      │
                     │        │
                     ▼        │
              ┌────────────┐  │
              │ Register   │  │
              │ File       │  │
              └──┬─────┬───┘  │
                 │     │       │
          ReadData1  ReadData2 │
                 │     │       │
                 │     └──┐    │
                 │        ▼    │
                 │   ┌────────┐│
                 │   │  MUX   ││ ALUSrc
                 │   └───┬────┘│
                 │       │     │
                 └───┬───┘     │
                     ▼         ▼
                   ┌─────────────┐
                   │     ALU     │
                   └──────┬──────┘
                          │
                     ALU_Result
                          │
                          ▼
                   Register File
                     WriteData
```

## Register write-back

The core connects:

```verilog
.WriteAddr(rd)
.WriteData(ALU_Result)
.WriteEnable(RegWrite)
```

Therefore, the active core writes the ALU result directly back into the destination register.

---

# 14. FPGA Top Level — `riscv_fpga_top.v`

This is the hardware-facing top-level module.

### Inputs

```text
clk
reset
```

### Output

```text
LED[7:0]
```

It instantiates:

```text
riscv_core
```

and connects the ALU result to the LEDs:

```verilog
assign LED = ALU_Result[7:0];
```

Therefore, the lower eight bits of the current ALU result are displayed on the FPGA LEDs.

---

# 15. How One Instruction Travels Through the Processor

Consider:

```text
ADDI x1, x0, 10
```

## Step 1 — PC

After reset:

```text
PC = 0
```

## Step 2 — Instruction memory

The PC selects:

```text
memory[0]
```

which contains:

```text
32'h00A00093
```

## Step 3 — Decoder

The decoder extracts:

```text
rs1 = x0
rd  = x1
```

and sign-extends:

```text
Immediate = 10
```

It generates:

```text
ALU_Opcode = ADD
ALUSrc     = 1
RegWrite   = 1
```

## Step 4 — Register file

Because:

```text
rs1 = x0
```

the first operand is:

```text
ReadData1 = 0
```

## Step 5 — ALU input MUX

Because:

```text
ALUSrc = 1
```

the second ALU operand becomes:

```text
ALU_B = Immediate = 10
```

## Step 6 — ALU

The ALU performs:

```text
0 + 10 = 10
```

Therefore:

```text
ALU_Result = 10
```

## Step 7 — Write-back

Because:

```text
RegWrite = 1
rd = x1
```

the register file writes:

```text
x1 = 10
```

## Step 8 — PC update

On the next positive clock edge:

```text
PC = PC + 4
```

so:

```text
PC = 4
```

The next instruction is then fetched.

---

# 16. Example: `ADD x3, x1, x2`

After the first two instructions:

```text
x1 = 10
x2 = 20
```

The instruction:

```text
ADD x3, x1, x2
```

causes:

```text
rs1 = x1
rs2 = x2
rd  = x3
```

The register file supplies:

```text
ReadData1 = 10
ReadData2 = 20
```

The decoder selects:

```text
ALU = ADD
ALUSrc = 0
RegWrite = 1
```

The MUX selects:

```text
ALU_B = ReadData2 = 20
```

The ALU performs:

```text
10 + 20 = 30
```

Then:

```text
x3 = 30
```

---

# 17. Complete Demonstration Program

The instruction memory currently executes this sequence:

```text
1. ADDI x1, x0, 10
       ↓
   x1 = 10

2. ADDI x2, x0, 20
       ↓
   x2 = 20

3. ADD x3, x1, x2
       ↓
   x3 = 30

4. SUB x4, x3, x1
       ↓
   x4 = 20

5. AND x5, x3, x4
       ↓
   x5 = 20

6. OR x6, x3, x4
       ↓
   x6 = 30

7. XOR x7, x3, x4
       ↓
   x7 = 10

8. SLL x8, x7, x2
       ↓
   shift x7 using the selected shift amount

9. SRL x9, x8, x1
       ↓
   shift x8 using the selected shift amount
```

The exact shift behavior should be interpreted from the actual RTL path being simulated.

---

# 18. Clock and Reset

The sequential elements are clocked using:

```verilog
always @(posedge clk)
```

The register file and program counter respond to reset.

### PC reset

```text
reset = 1 → PC = 0
```

### Register file reset

```text
reset = 1 → all 32 registers = 0
```

This provides a deterministic starting state for simulation.

---

# 19. Verification Structure

The repository contains dedicated testbenches for the individual blocks and integrated datapath/core.

Typical verification hierarchy:

```text
ALU
  └── tb_alu.v

Instruction Decoder
  └── tb_instruction_decoder.v

Instruction Memory
  └── tb_instruction_memory.v

Program Counter
  └── tb_program_counter.v

Register File
  └── tb_reg.v

Datapath
  └── tb_riscv_datapath.v

Execute / Write-Back
  └── tb_riscv_execute_wb.v

RISC-V Core
  ├── tb_riscv_core.v
  └── tb_riscv_core_final.v
```

The waveform/debug outputs in the design make it possible to observe signals such as:

```text
PC
Instruction
rs1
rs2
rd
ReadData1
ReadData2
ALU_B
ALU_Result
ALU_Opcode
Shamt
Immediate
ALUSrc
RegWrite
Carry
Zero
Negative
Overflow
```

---

# 20. Important Design Observation

There are currently **two related datapath implementations** in the repository:

### Main integrated path

```text
riscv_fpga_top
      ↓
riscv_core
      ↓
PC + Instruction Memory + Decoder
      ↓
Register File + ALU
```

### Separate datapath modules

```text
riscv_datapath
```

and

```text
riscv_execute_wb
```

These are useful for modular development and testing, but they are not both part of the instantiated hierarchy of `riscv_core.v`.

This distinction is useful when explaining the project because it avoids claiming that every `.v` file is directly instantiated in the final top-level design.

---

# 21. Why This Design Is Useful as a Learning Project

The project demonstrates several important RTL concepts:

- Parameterized Verilog modules
- Combinational logic using `always @(*)`
- Sequential logic using `always @(posedge clk)`
- Register arrays
- Asynchronous memory/register reads
- Synchronous register writes
- Multiplexer-based datapath control
- ALU operation decoding
- Two's-complement arithmetic
- Arithmetic flags
- Instruction field extraction
- Immediate sign extension
- Module instantiation
- RTL hierarchy
- Simulation and waveform debugging
- FPGA top-level integration

---

# 22. Suggested Reading Order for This Repository

For someone learning the project, read the source in this order:

```text
1. alu.v
       ↓
2. reg_file.v
       ↓
3. instruction_decoder.v
       ↓
4. instruction_memory.v
       ↓
5. program_counter.v
       ↓
6. riscv_datapath.v
       ↓
7. riscv_execute_wb.v
       ↓
8. riscv_core.v
       ↓
9. riscv_fpga_top.v
       ↓
10. testbenches
```

For understanding the **actual running processor**, focus especially on:

```text
program_counter.v
instruction_memory.v
instruction_decoder.v
reg_file.v
alu.v
riscv_core.v
riscv_fpga_top.v
```

---

# 23. One-Minute Project Explanation

> This project implements a compact 32-bit RISC-V-based processor datapath in Verilog HDL. The program counter generates instruction addresses, which are used to read instructions from an initialized instruction memory. The instruction decoder extracts the RISC-V register fields, immediate, function fields and generates ALU/control signals. The register file provides two asynchronous operands and supports synchronous write-back while maintaining x0 as zero. An ALU source multiplexer selects either the second register operand or an immediate value. The ALU then performs the selected arithmetic, logical, shift or comparison operation and generates status flags. The resulting ALU value is written back to the destination register when RegWrite is asserted. The `riscv_fpga_top` module integrates the core for FPGA use and displays the lower eight bits of the ALU result on LEDs.

---

## 24. Future Extensions

Possible improvements include:

- Branch and jump instructions
- Load/store instructions and data memory
- More complete RV32I support
- Proper branch target and next-PC logic
- Pipeline stages
- Hazard detection and forwarding
- Automated instruction-level verification
- Larger instruction/data memories
- Timing analysis
- FPGA hardware validation
- Area/power optimization
