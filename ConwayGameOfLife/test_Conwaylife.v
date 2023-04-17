`timescale 1ns / 1ps
module celltest;
    reg clk, load;
    wire [255:0] data;
    wire [255:0] q;

    top_module u1(.clk(clk), .load(load), .data(256'h000200010007), .q(q));

    initial begin
        $dumpfile("mytest.vcd");
        $dumpvars;
        clk <= 0;
        load <= 1;
        #3;
        load <= 0;
        #100 $finish;
        $display("Hello, World");
    end

    always begin
        #1 clk = ~clk;
        if(clk)
            $display("%x", q);
    end

endmodule
