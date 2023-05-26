`timescale 1ns / 1ps
module test;
    reg clk_50M, data, rst;
    wire tx;
    uart u1(.clk_50M(clk_50M), .rst(rst), .rx(data), .tx(tx));

    initial begin
        $dumpfile("mytest.vcd");
        $dumpvars;
        clk_50M <= 1'b0;
        data <= 1'b1;
        rst <= 1'b0;
        #3;
        rst <= 1'b1;
        #500;
        data <= 1'b0; //start
        #868;
        data <= 1'b1; //LSB
        #868;
        data <= 1'b0;
        #868;
        data <= 1'b1;
        #868;
        data <= 1'b0;
        #868;
        data <= 1'b1;
        #868;
        data <= 1'b0;
        #868;
        data <= 1'b1;
        #868;
        data <= 1'b0; //MSB
        //---
        #868;
        data <= 1'b1;
        #2868;
        data <= 1'b0; //start
        #868;
        data <= 1'b0; //LSB
        #868;
        data <= 1'b1;
        #868;
        data <= 1'b0;
        #868;
        data <= 1'b1;
        #868;
        data <= 1'b0;
        #868;
        data <= 1'b1;
        #868;
        data <= 1'b0;
        #868;
        data <= 1'b1; //MSB
        #15000;
        $finish;
    end

    always begin
        #1 clk_50M <= ~clk_50M;
    end
endmodule
