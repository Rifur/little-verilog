# little-verilog

This project is running Verilog HDL on Mac, using [Yosys](https://github.com/YosysHQ/yosys) + [netlistsvg](https://github.com/nturley/netlistsvg) to generate RTL schematics, [Icarus Verilog](https://github.com/steveicarus/iverilog) to run testbenches, and [GTKWave](https://gtkwave.sourceforge.net) to view the VCD file

## Install

```
$ brew install yosys
$ npm install -g netlistsvg
$ brew install icarus-verilog
$ brew install gtkwave
```

--------

## To generate the RTL schematic of the Baugh-Wooley Signed Array Multiplier, use Yosys + netlistsvg.

`$ cd BaughWooleyArrayMultiplier`

use Yosys + netlistsvg
```
$ yosys -p "prep -top baughWooleyArrayMultiplier; write_json output.json" baughWooleyArrayMultiplier.v
$ netlistsvg output.json
```

netlistsvg will generate out.svg under this folder looks like this:

![RTL Schematic](https://user-images.githubusercontent.com/1651641/214814563-e6ebe701-98e1-4ab5-a5b6-466576fa9f82.png)

## To test, use Icarus Verilog to run the testbench and generate the VCD file.

```
$ iverilog -Wimplicit -o am testbench_arrayMultiple.v baughWooleyArrayMultiplier.v
$ ./am
```
and open mytest.vcd with GTKWave

![Testbench Result on GTKWave](https://user-images.githubusercontent.com/1651641/214814673-786b7e3b-9903-4c03-b76a-b688edffe1e9.png)


## Conway's Game of Life
```
$ iverilog -Wimplicit -o am test_Conwaylife.v Conwaylife.v
$ ./am
```
