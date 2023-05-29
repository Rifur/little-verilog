`timescale 1ns / 1ps
//iverilog -Wimplicit -o am test_linkedlist.v linkedlist.v
module test_linkedlist;
    reg clk, rstn;
    reg theta_we_i, param_we_i;
    reg [7:0] theta_addr_i;
    reg [11:0] theta_data_i;
    wire [11:0] head_o;
    wire [31:0] node_o;
    linkedlist u1(
                   .clk(clk),
                   .rstn(rstn),
                   .theta_we_i(theta_we_i),
                   .param_we_i(param_we_i),
                   .theta_addr_i(theta_addr_i),
                   .theta_data_i(theta_data_i),
                   .head_o(head_o),
                   .node_o(node_o)
               );

    integer i;
    initial begin
        $dumpfile("mytest.vcd");
        $dumpvars;
        clk <= 1'b1;
        rstn <= 1'b0;
        theta_we_i <= 1'b0;
        param_we_i <= 1'b0;
        #2;
        rstn <= 1'b1;
        #2;
        for(i=0; i<180; i=i+1) begin
            theta_we_i <= 1'b1;
            theta_addr_i <= i;
            theta_data_i <= 12'h123 + i;
            #1;
            theta_we_i <= 1'b0;
            #1;
        end
        for(i=0; i<180; i=i+1) begin
            theta_addr_i <= i;
            theta_data_i <= 12'h000 + i;
            #2;
        end
        #3;

        $finish;

    end

    always@(*) begin
        #1 clk <= ~clk;
    end

endmodule
