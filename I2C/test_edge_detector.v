`timescale 1ns / 1ps
//iverilog -Wimplicit -o am test_edge_detector.v I2c.v
module test_edge_detector;
    reg clk, rstn, curr;
    wire posedge_o, negedge_o;
    integer i;
    posedge_detector pd1(clk, rstn, curr, posedge_o);
    negedge_detector nd1(clk, rstn, curr, negedge_o);
    initial begin
        $dumpfile("mytest.vcd");
        $dumpvars;
        clk = 0;
        rstn = 0;
        curr = 0;
        #4;
        rstn = 1;
        for(i=0; i<10; i=i+1) begin
            #10 curr = i[1];
        end
        #2;
        $finish;
    end

    always begin
        #2 clk <= ~clk;
    end

endmodule
