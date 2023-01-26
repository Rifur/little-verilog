# little-verilog

Running Verilog HDL on Mac, using [Yosys](https://github.com/YosysHQ/yosys) + [netlistsvg](https://github.com/nturley/netlistsvg) to generate RTL schematic, and using [Icarus Verilog](https://github.com/steveicarus/iverilog) to run testbenches, and and using [GTKWave](https://gtkwave.sourceforge.net) to view the vcd file.

## Install

```
$ brew install yosys
$ npm install -g netlistsvg
$ brew install icarus-verilog
$ brew install gtkwave
```

--------

## To generate RTL schematic of Baugh-Wooley Signed Array Muliplier, 

`$ cd BaughWooleyArrayMultiplier`

use Yosys + netlistsvg
```
$ yosys -p "prep -top baughWooleyArrayMultiplier; write_json output.json" baughWooleyArrayMultiplier.v
$ netlistsvg output.json
```

netlistsvg will generate out.svg under this folder looks like this:

![RTL Schematic](https://user-images.githubusercontent.com/1651641/214814563-e6ebe701-98e1-4ab5-a5b6-466576fa9f82.png)

## To test, use iVerilog to run testbench and generate VCD file,

```
$ iverilog -o am testbench_arrayMultiple.v baughWooleyArrayMultiplier.v
$ ./am
```
and open mytest.vcd with GTKWave

![Testbench Result on GTKWave](https://user-images.githubusercontent.com/1651641/214814673-786b7e3b-9903-4c03-b76a-b688edffe1e9.png)


