# RISC-V Practice 1

Running Verilog HDL on Mac, using [Yosys](https://github.com/YosysHQ/yosys) + [netlistsvg](https://github.com/nturley/netlistsvg) to generate RTL schematic, and using [Icarus Verilog](https://github.com/steveicarus/iverilog) to run testbenches, and and using [GTKWave](https://gtkwave.sourceforge.net) to view the vcd file.

## Calculate Fibonacci
```
//clear x1; xor x1, x1, x1; x1 ^= x1;
mem[0] = {7'b000_0000, 5'd1, 5'd1, `_XOR, 5'd1, 7'b0110011};
//clear x2; xor x2, x2, x2; x2 ^= x2
mem[1] = {7'b000_0000, 5'd2, 5'd2, `_XOR, 5'd2, 7'b0110011};
//set x1=1; addi x1, x1, 1; x1 = x1 + 1;
mem[2] = {11'b000_0000_0001, 5'd1, `_ADDI, 5'd1, 7'b0010011};
//set x2=1; addi x2, x2, 1; x2 = x2 + 1;
mem[3] = {11'b000_0000_0000, 5'd2, `_ADDI, 5'd2, 7'b0010011};
//x1 = x1 + x2; add x1, x1, x2;
mem[4] = {7'b000_0000, 5'd2, 5'd1, `_ADD, 5'd1, 7'b0110011};
//x2 = x1 + x2; add x2, x1, x2;
mem[5] = {7'b000_0000, 5'd2, 5'd1, `_ADD, 5'd2, 7'b0110011};
//jump mem[4]
mem[6] = {1'b1, 10'b11_1111_1110, 1'b1, 8'b1111_1111, 5'd0, `_JAL};
```

## To test RISC-V Practice 1, use iVerilog to run testbench and generate VCD file,

```
$ iverilog -o am test_riscv.v riscv.v
$ ./am
```
and open mytest.vcd with GTKWave

![Testbench Result with GTKWave](https://user-images.githubusercontent.com/1651641/215306059-326b107f-1535-4a6e-aea6-4903d7fcaa11.png)

Notice: opcode=0x6F is `JAL` jump-and-link instruction.
