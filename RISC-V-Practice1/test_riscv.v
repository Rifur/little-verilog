module test_riscv;
    reg clk, rst_n;
    wire [31:0] inst;
    wire [31:0] pc;

    riscv RISCV(.clk(clk), .rst_n(rst_n), .pc(pc), .instruction(inst));

    initial begin
        clk <= 0;
        rst_n <= 0;
        #3;
        rst_n <= 1;
        $dumpfile("mytest.vcd");
        $dumpvars;
        $display("Hello, World");

        #100 $finish;
    end

    always begin
        #1 clk = ~clk;
    end

endmodule
