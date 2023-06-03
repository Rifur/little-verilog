`timescale 1ns / 1ps
//iverilog -Wimplicit -o am test_HTLinkedlist.v linkedlist.v
module test_linkedlist;
    reg clk, rstn;
    reg [9:0] rho_i;
    reg append_i, search_i, show_i;
    wire done_o, append_o, found_o;
    wire [31:0] node_o;
    reg [11:0] param_addr_i;

    HTLinkList u1(
                   .clk(clk),
                   .rstn(rstn),
                   .rho_i(rho_i),
                   .append_i(append_i),
                   .search_i(search_i),
                   .done_o(done_o),
                   .append_o(append_o),
                   .found_o(found_o),
                   .node_o(node_o),

                   .show_i(show_i),
                   .param_addr_i(param_addr_i)
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
        show_i <= 0;
        #2;
        rstn <= 1'b1;
        #2;

        Append(10'd123);
        Append(10'd123);
        //ShowTask();

        Append(10'd123);
        //ShowTask();

        Append(10'd321);
        //ShowTask();

        Search(10'd123);
        Search(10'd789);
        Search(10'd321);

        ShowTask();

        $finish;
    end

    integer j;
    task ShowTask;
        begin
            #10;
            for(i=0; i<5; i=i+1) begin
                show_i <= 1;
                param_addr_i <= i;
                #2;
                show_i <= 0;
                j = 0;
                while (~(done_o) && j < 10) begin
                    #2;
                    j += 1;
                end
            end
            #10;
        end
    endtask

    task Append;
        input[9:0] data;
        begin
            append_i <= 1'b1;
            rho_i <= data;
            #2;
            append_i <= 1'b0;
            while (~(done_o) && i < 10) begin
                #2;
                i += 1;
            end
            rho_i <= 10'd0;
            #2;
        end
    endtask

    task Search;
        input[9:0] data;
        begin
            search_i <= 1'b1;
            rho_i <= data;
            #2;
            search_i <= 1'b0;
            while (~(done_o) && i < 10) begin
                #2;
                i += 1;
            end
            rho_i <= 10'd0;
            #2;
        end
    endtask

    always@(*) begin
        #1 clk <= ~clk;
    end

endmodule
