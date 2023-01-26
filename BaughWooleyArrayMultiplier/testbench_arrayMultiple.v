module testbench_arrayMultiple;
    wire [31:0] a1, a2, a3;
    wire [31:0] b1, b2, b3;
    wire [63:0] p1, p2, p3;

    assign a1 = -32'd1234;
    assign b1 = -32'd456;

    assign a2 = -32'd2147483647;
    assign b2 = 32'd2147483647;

    assign a3 = 32'h55555555;
    assign b3 = 32'haaaaaaaa;

    //arrayMultiplier arrayMultiplier1(.product(p), .a(a), .b(b));
    baughWooleyArrayMultiplier arrayMultiplier1(.product(p1), .a(a1), .b(b1));

    baughWooleyArrayMultiplier arrayMultiplier2(.product(p2), .a(a2), .b(b2));

    baughWooleyArrayMultiplier arrayMultiplier3(.product(p3), .a(a3), .b(b3));

    initial begin
        $dumpfile("mytest.vcd");
        $dumpvars;
        $display("Hello, World");
    end

    initial
        #100 $finish;
endmodule
