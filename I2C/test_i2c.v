`timescale 1ns / 1ps
//iverilog -Wimplicit -o am test_i2c.v I2C_slave.v IOBUF.v
module test_i2c;
    reg clk, rstn, SCL_i;
    wire SDA;
    reg SDA_i;
    wire SDA_in_en, SDA_o;
    I2C_slave u1(clk, rstn, SCL_i, SDA_i, SDA_in_en, SDA_o);
    integer i;
    wire [6:0] address;
    assign address = 7'h53;
    wire RW; //R=1, W=0
    assign RW = 1'b0;
    reg [7:0] dataFromI2C;
    initial begin
        $dumpfile("mytest.vcd");
        $dumpvars;
        clk = 0;
        rstn = 0;
        SDA_i = 1;
        SCL_i = 1;
        #16;
        rstn = 1;
        #80;
        SDA_i = 0;
        #80;
        SCL_i = 0;

        for(i=0; i<7; i=i+1) begin
            #16;
            SDA_i = address[6-i];
            #16;
            SCL_i = 1;
            #80;
            SCL_i = 0;
            #16;
            SDA_i = 0;
        end
        #70;
        SDA_i = RW;
        #10;
        SCL_i = 1;
        #80;
        SDA_i = 0;
        SCL_i = 0;
        #40;
        //for ACK
        SDA_i = 1;
        #40;
        SCL_i = 1;
        #80;
        SCL_i = 0;
        SDA_i = 0;
        #80;
        SCL_i = 1;
        #40;
        SDA_i = 1;
        #120;
        $finish;

        SCL_i = 0;
        for(i=0; i<8; i=i+1) begin
            #80;
            dataFromI2C[i] = SDA;
            SCL_i = 1;
            #80;
            SCL_i = 0;
        end
        #120;
        SDA_i = 0;
        #80;
        SCL_i = 1; //read, ACK
        #80;
        SDA_i = 1;
        SCL_i = 0;
        for(i=0; i<8; i=i+1) begin
            #80;
            dataFromI2C[i] = SDA;
            SCL_i = 1;
            #80;
            SCL_i = 0;
        end
        #80;
        SCL_i = 1;
        #120;
        SDA_i = 1;
        SCL_i = 0; //read, Non-ACK
        #40;
        SDA_i = 0;
        #80;
        SCL_i = 1;
        #40;
        SDA_i = 1;
        #200;
        $finish;
    end

    always begin
        #2 clk <= ~clk;
    end

endmodule
