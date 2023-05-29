`timescale 1ns / 1ps
//iverilog -Wimplicit -o am test_HTLinkedlist.v linkedlist.v
module test_linkedlist;
    reg clk, rstn;
    reg [9:0] rho_i;
    reg append_i, search_i;
    wire done_o, append_o, found_o;
    wire [31:0] node_o;

    HTLinkList u1(
                   .clk(clk),
                   .rstn(rstn),
                   .rho_i(rho_i),
                   .append_i(append_i),
                   .search_i(search_i),
                   .done_o(done_o),
                   .append_o(append_o),
                   .found_o(found_o),
                   .node_o(node_o)
               );

    integer i;
    initial begin
        $dumpfile("mytest.vcd");
        $dumpvars;
        clk <= 1'b1;
        rstn <= 1'b0;
        rho_i <= 0;
        append_i <= 1'b0;
        search_i <= 1'b0;
        #2;
        rstn <= 1'b1;
        #2;
        append_i <= 1'b1;
        rho_i <= 10'd123;
        #2;
        append_i <= 1'b0;
        while ((~(done_o & append_o))) begin
            #2;
        end
        rho_i <= 10'd0;
        #2;

        append_i <= 1'b1;
        rho_i <= 10'd123;
        #2;
        append_i <= 1'b0;
        while ((~(done_o))) begin
            #2;
        end
        rho_i <= 10'd0;
        #2;

        append_i <= 1'b1;
        rho_i <= 10'd321;
        #2;
        append_i <= 1'b0;
        while ((~(done_o))) begin
            #2;
        end
        rho_i <= 10'd0;
        #2;

        search_i <= 1'b1;
        rho_i <= 10'd123;
        #2;
        while ((~(done_o))) begin
            #2;
        end
        search_i <= 1'b0;
        rho_i <= 0;
        #2;

        search_i <= 1'b1;
        rho_i <= 10'd789;
        #2;
        search_i <= 1'b0;
        while ((~(done_o))) begin
            #2;
        end
        rho_i <= 0;

        search_i <= 1'b1;
        rho_i <= 10'd321;
        #2;
        search_i <= 1'b0;
        while ((~(done_o))) begin
            #2;
        end
        rho_i <= 0;

        #10;
        $finish;
    end

    always@(*) begin
        #1 clk <= ~clk;
    end

endmodule
