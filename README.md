# 16-bit RISC CPU

A complete 6-stage non-pipelined 16-bit CPU architecture that runs in [Vivado](https://www.xilinx.com/products/design-tools/vivado.html) simulation. This CPU has 6 components: a register file, a decoder, an ALU, a control unit, a program counter, and ram/memory.

ISA layout, instructions, and naming instructions were in part inspired by the ARM7 ISA.

**Brief overview:**
* opcode is 4 bits
* 14 different instructions implemented
* 8 general purpose registers
* RRR-type instructions are the largest, and take up 9 bits in register addresses
* 1 bit is a condition bit
* 2 bits unused
* simulated clock runs at a 10ns period or 100Mhz
* simulated memory is 512 bytes

## Component Block Diagrams

Register file:

![Register file](https://i.imgur.com/iIh0AwH.png)

Decoder:

![Decoder](https://i.imgur.com/xAYbRCn.png)

ALU:

![ALU](https://i.imgur.com/hfScN2B.png)

Control Unit:

![Control Unit](https://i.imgur.com/MY0VlIn.png)

PC:

![PC](https://i.imgur.com/idDgfdk.png)

RAM/Memory:

![RAM/Memory](https://i.imgur.com/9YgZSrn.png)

## ISA
### Instructions
<pre>
Terms:
R = register
U = unused
rD = destination register
rM = first operand register
rN = second operand register
c = condition bit
I(8)/(5) = immediate data bits, 8 or 5
</pre>

| Instruction | Form | Implementation | Condition bit | OPCODE |
| --- | --- | --- | --- | --- |
| ADD | RRR |	rD = rM + rN | c: 1/0 = signed/unsigned | 0000
| SUB |	RRR	| rD = rM - rN | c: 1/0 = signed/unsigned | 0001
| NOT |	RRU	| rD = not rN | c: N/A	| 0010
| AND |	RRR	| rD = rM and rN |	c: N/A | 0011
| OR |	RRR	| rD = rM or rN	| c: N/A | 0100
| XOR |	RRR	| rD = rM xor rN | c: N/A | 0101
| LSL |	RRI(5) | rD = rM << rN | c: N/A	| 0110
| LSR |	RRI(5) | rD = rM >> rN | c: N/A | 0111
| CMP |	RRR	| rD = cmp(rM, rN) | c: 1/0 = signed/unsigned | 1000
| B	|   UI(8) |	PC = rM or 8-bit immediate | c: 1/0 = rM/8-bit immediate | 1001
| BEQ |	URR | PC = rM conditional on rN	| c: N/A | 1010
| IMMEDIATE | RI(8) | rD = 8-bit immediate | c: 1/0 = upper/lower 8-bits | 1011
| LD | RRU | rD = memory(rM) | c: N/A | 1100
| ST | URR | memory(rM) = rN | c: N/A | 1101



### Instruction layout

![Instruction layout](https://i.imgur.com/QfpIVy6.png)

### Selected instructions and waveforms

Hardcoded ROM for testing and display purposes; every instruction is executed at least once.

The instruction images are labeled by instruction number and with its respective hexadecimal instruction value (seen in the ram_data_out and instruction lines on the waveforms).

The signals on the left that are highlighted are most worth noting. Specifically:
* register data and select lines
* instruction line
* result line
* address line
* ram lines

**Instructions 0-11:**

![Instructions 0-11](https://i.imgur.com/nQEoh9U.png)

**Waveforms 0-11:**

![Waveforms 0-11](https://i.imgur.com/44cQyYT.png)

**Instructions 12-26:**

![Instructions 12-26](https://i.imgur.com/zI14tlq.png)

**Waveforms 12-26:**

![Waveforms 12-26](https://i.imgur.com/4Nx1CLA.png)