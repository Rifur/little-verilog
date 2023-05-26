module uart(clk_50M, rst, rx, tx);
    input clk_50M, rst; //50MHz
    input rx;
    output tx;

    wire rxack;
    wire [7:0] out;

    uart_rx rx1(clk_50M, ~rst, rx, out, rxack);
    uart_tx tx1(clk_50M, ~rst, out, rxack, tx);

endmodule

module uart_rx(clk_50M, rst, rx, out, rxack);
    input clk_50M, rst; //50MHz
    input rx;
    output rxack;
    output reg [7:0] out;
    parameter CLKDIV_9600=5208, CLKDIV_115200=434;
    parameter RxIdle=3'd0, RxReceive=3'd1, RxStop=3'd2, RxFail=3'd3;
    reg [12:0] cnt_rx;
    reg [3:0] receiveCnt;
    reg [2:0] state_rx, ns_rx;
    wire pulse_rx;
    assign pulse_rx = cnt_rx == CLKDIV_115200;

    always@(posedge clk_50M)
    begin
        if(rst)
            state_rx <= RxIdle;
        else
            state_rx <= ns_rx;
    end

    always@(*)
    begin
        ns_rx = state_rx;
        case(state_rx)
            RxIdle:
                ns_rx = ~rx ? RxReceive : RxIdle;
            RxReceive:
                ns_rx = pulse_rx & receiveCnt == 4'd8 ? RxStop : RxReceive;
            RxStop:
                ns_rx = rx ? RxIdle : RxFail;
            RxFail:
                ns_rx = rx ? RxIdle : RxFail;
        endcase
    end

    always@(posedge clk_50M)
    begin
        if(rst)
            cnt_rx <= 13'b0;
        else if(state_rx == RxIdle || state_rx == RxFail)
            cnt_rx <= 13'b0;
        else
            cnt_rx <= pulse_rx ? 13'b0 : cnt_rx + 13'b1;
    end

    always@(posedge clk_50M)
    begin
        if(rst)
            receiveCnt <= 4'd0;
        else if(state_rx == RxReceive)
            receiveCnt <= pulse_rx ? receiveCnt + 4'd1 : receiveCnt;
        else
            receiveCnt <= 4'd0;
    end

    always@(posedge clk_50M)
    begin
        if(rst)
            out <= 8'b0;
        else if(state_rx != RxReceive)
            out <= 8'b0;
        else if((state_rx == RxReceive) & (receiveCnt < 8) & pulse_rx)
            out <= {rx, out[7:1]};
    end

    //assign rxack = (state_rx == RxReceive) & (receiveCnt == 4'd7) & rx;
    assign rxack = (state_rx == RxStop) & rx;

endmodule

//--------

module uart_tx(clk_50M, rst, out, rxack, tx);
    input clk_50M, rst; //50MHz
    input rxack;
    input [7:0] out;
    output reg tx;
    parameter CLKDIV_9600=13'd5208, CLKDIV_115200=13'd434;
    parameter TxIdle=2'd0, TxStart=2'd1, TxTransmit=2'd2;
    reg [1:0] state_tx, ns_tx;
    reg [12:0] cnt_tx;
    reg [7:0] tdr;
    reg [3:0] transmitCnt;
    assign pulse_tx = cnt_tx == CLKDIV_115200;

    always@(posedge clk_50M) begin
        if(rst)
            state_tx <= TxIdle;
        else
            state_tx <= ns_tx;
    end

    always@(*) begin
        ns_tx = state_tx;
        case(state_tx)
            TxIdle:
                ns_tx = rxack /*pulse_tx*/ ? TxStart : TxIdle;
            TxStart:
                ns_tx = pulse_tx ? TxTransmit : TxStart;
            TxTransmit:
                ns_tx = pulse_tx ? transmitCnt < 7 ? TxTransmit : TxIdle : TxTransmit;
        endcase
    end

    always@(posedge clk_50M) begin
        if(rst)
            tdr <= 8'b0;
        else if(state_tx == TxIdle & rxack)
            tdr <= out; //8'b01010101;
        else if(state_tx == TxTransmit & pulse_tx)
            tdr <= {1'b0, tdr[7:1]};
    end

    always@(posedge clk_50M) begin
        if(rst)
            transmitCnt <= 4'd0;
        else if (state_tx != TxTransmit)
            transmitCnt <= 4'd0;
        else if(state_tx == TxTransmit)
            transmitCnt <=  pulse_tx ? transmitCnt + 4'd1 : transmitCnt;
    end

    always@(posedge clk_50M) begin
        if(rst)
            cnt_tx <= 13'b0;
        else
            //cnt_tx <= pulse_tx ? 13'b0 : cnt_tx + 13'b1;
            cnt_tx <= pulse_tx ? 13'b0 : (state_tx == TxIdle ? 13'b0 : cnt_tx + 13'b1);
    end

    always@(*) begin
        tx = 1'b1;
        case(state_tx)
            TxIdle:
                tx = 1'b1;
            TxStart:
                tx = 1'b0;
            TxTransmit:
                tx = tdr[0];
        endcase
    end
endmodule
