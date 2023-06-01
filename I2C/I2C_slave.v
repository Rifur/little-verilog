module I2C_slave_wrapper
    (
        input clk, rstn,
        input SCL_i,
        inout SDA
    );

    wire SDA_i;
    wire SDA_in_en;
    wire SDA_o;

    //assign SDA = SDA_in_en ? 1'bz : SDA_o;
    //NOTE: Xilinx IOBUF should be at top-level
    IOBUF #(
              .DRIVE(12),             // Specify the output drive strength
              .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE"
              .IOSTANDARD("LVCMOS33"),// Specify the I/O standard
              .SLEW("SLOW")           // Specify the output slew rate
          ) IOBUF_inst (
              .O(SDA_i),    // IOBUF output as module's input
              .IO(SDA),     // Buffer inout port (connect directly to top-level port)
              .I(SDA_o),    // Buffer input as module's output
              .T(SDA_in_en) // tri-state enable input, high=input, low=output
          );

    I2C_slave i2c_slave_0
              (
                  .clk(clk),
                  .rstn(rstn),
                  .SCL_i(SCL_i),
                  .SDA_i(SDA_i),
                  .SDA_in_en(SDA_in_en),
                  .SDA_o(SDA_o)
              );

endmodule

module I2C_slave
    (
        input clk, rstn,
        input SCL_i,
        input SDA_i,
        output SDA_in_en,
        output SDA_o
    );

    parameter I2C_ADDRESS = 7'h53;
    parameter IDLE = 0;
    parameter ADDR = 1;
    parameter RACK = 2;
    parameter WACK = 3;
    parameter READ = 4;
    parameter WRITE = 5;
    parameter RMACK = 6;
    parameter NOTME = 7;

    reg [3:0] state, ns;
    reg [7:0] address;
    reg [7:0] addr_cnt;
    reg [15:0] data;
    reg r_master_ack;

    wire SCL_posedge, SCL_negedge;
    posedge_detector scl_pos_dec(clk, rstn, SCL_i, SCL_posedge);
    negedge_detector scl_neg_dec(clk, rstn, SCL_i, SCL_negedge);

    wire SDA_posedge, SDA_negedge;
    posedge_detector sda_pos_dec(clk, rstn, SDA_i, SDA_posedge);
    negedge_detector sda_neg_dec(clk, rstn, SDA_i, SDA_negedge);

    wire start_cond = SCL_i & SDA_negedge;
    wire stop_cond  = SCL_i & SDA_posedge;

    always @(posedge clk) begin
        if(~rstn)
            state <= IDLE;
        else
            state <= ns;
    end

    always@(posedge clk) begin
        if(~rstn) begin
            address <= 0;
            addr_cnt <= 0;
            data <= 16'b1010_1010_0111_1110;
        end
        else if(state == ADDR || state == WRITE) begin
            if(SCL_posedge) begin
                address <= {address[6:0], SDA_i};
                addr_cnt <= addr_cnt + 8'b1;
            end
        end
        else if(state == READ) begin
            if(SCL_posedge)
                addr_cnt <= addr_cnt + 8'b1;
            if(SCL_negedge) begin
                data <= {1'b0, data[15:1]};
            end
        end
        else begin
            address <= 0;
            addr_cnt <= 0;
        end
    end

    always@(posedge clk) begin
        if(~rstn)
            r_master_ack <= 0;
        else if(state == RMACK & SCL_posedge)
            r_master_ack <= SDA_i;

    end

    always@(*) begin
        ns = state;
        case(state)
            IDLE: ns = start_cond ? ADDR : IDLE;
            ADDR: begin
                if(addr_cnt == 8'd8 & SCL_negedge) begin
                    if(address[7:1]==I2C_ADDRESS)
                        ns = address[0] ? RACK : WACK;
                    else
                        ns = NOTME;
                end
                else
                    ns = ADDR;
            end
            RACK: ns = SCL_negedge ? READ : RACK;
            WACK: ns = SCL_negedge ? WRITE : WACK;
            READ: ns = stop_cond ? IDLE : ((addr_cnt==8'd8 & SCL_negedge) ? RMACK : READ);
            WRITE: ns = stop_cond ? IDLE : ((addr_cnt==8'd8) ? WACK : WRITE);
            RMACK: ns = SCL_negedge ? (r_master_ack ? IDLE : READ) : RMACK;
            NOTME: ns = SCL_negedge ? IDLE : NOTME;
        endcase
    end

    assign SDA_in_en = state==IDLE | state==ADDR | state==NOTME | state==WRITE | state==RMACK;
    assign SDA_o = ~((state==READ & data[0]) | (state==RACK) | (state==WACK));
    wire tb_ack_o = (state==NOTME);
endmodule


module posedge_detector
    (
        input clk, rstn,
        input curr,
        output reg posedge_o
    );

    reg prev;
    always@(posedge clk) begin
        if(~rstn) begin
            prev <= 2'd0;
            posedge_o <= 0;
        end
        else begin
            prev <= curr;
            posedge_o <= {prev, curr} == 2'b01;
        end
    end

endmodule

module negedge_detector
    (
        input clk, rstn,
        input curr,
        output reg negedge_o
    );

    reg prev;
    always@(posedge clk) begin
        if(~rstn) begin
            prev <= 0;
            negedge_o <= 0;
        end
        else begin
            prev <= curr;
            negedge_o <= ({prev,curr} == 2'b10);

        end
    end

endmodule
