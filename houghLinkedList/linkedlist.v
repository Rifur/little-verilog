//yosys -p "prep -top linkedlist; write_json output.json" linkedlist.v
//iverilog -Wimplicit -o am test_HTLinkedlist.v linkedlist.v
module HTLinkList
    (
        input clk, rstn,
        input [9:0] rho_i,
        input append_i, search_i,
        output reg done_o, append_o, found_o,
        output wire [31:0] node_o,
        input show_i,
        input [11:0] param_addr_i
    );

    reg [9:0] rho;
    reg [3:0] state, ns;
    reg [11:0] nextIndex;
    wire [11:0] nextIndex_plus_one = nextIndex + 12'b1;
    reg param_we;
    reg [11:0] param_addr;
    reg [31:0] param_data;
    wire [9:0] node_rho = node_o[31:22];
    wire [9:0] node_vote = node_o[21:12];
    wire [11:0] node_next = node_o[11:0];

    linkedlist u1(
                   .clk(clk),
                   .rstn(rstn),
                   .theta_we_i(),
                   .theta_addr_i(),
                   .theta_data_i(),
                   .param_we_i(param_we),
                   .param_addr_i(param_addr),
                   .param_data_i(param_data),
                   .head_o(),
                   .node_o(node_o)
               );

    parameter SIZE=4094;
    parameter IDLE=0;
    parameter SEARCH=1;
    parameter APPEND=2;
    parameter APPEND_WAIT_SRAM=8;
    parameter SEARCH_WAIT_SRAM=9;
    parameter APPEND_FIND=3;
    parameter APPEND_NEW=4;
    parameter APPEND_DONE=5;
    parameter SEARCH_FIND=6;
    parameter SHOW=7;
    parameter SHOW_WAIT_SRAM=10;

    always@(posedge clk) begin
        if(~rstn) begin
            state <= IDLE;
            param_we <= 0;
            param_addr <= 0;
            param_data <= 0;
            found_o <= 0;
            append_o <= 0;
            done_o <= 0;
            nextIndex <= 12'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    found_o <= 0;
                    append_o <= 0;
                    done_o <= 0;
                    param_we <= 0;
                    param_addr <= 0;
                    rho <= rho_i;
                    if(search_i)
                        state <= SEARCH;
                    else if(append_i)
                        state <= APPEND;
                    else if(show_i) begin
                        state <= SHOW_WAIT_SRAM;
                        param_addr <= param_addr_i;
                    end
                    else
                        state <= IDLE;
                end
                SEARCH: begin
                    if(node_next != 0) begin
                        param_addr <= node_next;
                        state <= SEARCH_WAIT_SRAM;
                    end
                    else begin
                        state <= IDLE;
                        done_o <= 1;
                        found_o <= 0;
                    end
                end
                SEARCH_WAIT_SRAM : begin
                    state <= SEARCH_FIND;
                end
                SEARCH_FIND: begin
                    if(node_rho == rho) begin
                        state <= IDLE;
                        done_o <= 1;
                        found_o <= 1;
                    end
                    else begin
                        state <= SEARCH;
                    end
                end
                APPEND: begin
                    if(node_next != 0) begin
                        param_addr <= node_next;
                        state <= APPEND_WAIT_SRAM;
                    end
                    else begin
                        if(node_next+1 < SIZE) begin
                            param_we <= 1'b1;
                            param_data <= {node_rho, node_vote, nextIndex_plus_one};
                            state <= APPEND_NEW;
                        end
                        else begin
                            state <= IDLE;
                            done_o <= 1;
                            append_o <= 0;
                        end
                    end
                end
                APPEND_WAIT_SRAM : begin
                    state <= APPEND_FIND;
                end
                APPEND_FIND: begin
                    if(node_rho==rho) begin
                        param_we <= 1'b1;
                        param_data <= {node_rho, node_vote+10'b1, nextIndex};
                        state <= APPEND_DONE;
                    end
                    else begin
                        state <= APPEND_DONE;
                    end
                end
                APPEND_NEW: begin
                    param_we <= 1'b1;
                    param_addr <= nextIndex_plus_one;
                    param_data <= {rho, 10'b1, 12'b0};
                    nextIndex <= nextIndex_plus_one;
                    state <= APPEND_DONE;
                end
                APPEND_DONE: begin
                    state <= IDLE;
                    param_we <= 0;
                    done_o <= 1;
                    append_o <= 1;
                end
                SHOW_WAIT_SRAM: begin
                    state <= SHOW;
                end
                SHOW: begin
                    state <= IDLE;
                    done_o <= 1;
                end
            endcase
        end
    end

endmodule

module linkedlist
    (
        input clk, rstn,
        input theta_we_i,
        input param_we_i,
        input [7:0] theta_addr_i,   //2^8, 0~180
        input [11:0] theta_data_i,  //2^12, Capacity of Parameter SRAM is 4096
        input [11:0] param_addr_i,
        input [31:0] param_data_i,
        output [11:0] head_o,
        output [31:0] node_o
    );

    SRAM #(
             .ADDR_SIZE(8),
             .DATA_WIDTH(12)
         ) Head (
             .clk(clk),
             .rstn(rstn),
             .write_en(theta_we_i),
             .addr(theta_addr_i),
             .data(theta_data_i),
             .out(head_o)
         );

    SRAM #(
             .ADDR_SIZE(12),
             .DATA_WIDTH(32)
         ) ParametersLinkedList (
             .clk(clk),
             .rstn(rstn),
             .write_en(param_we_i),
             .addr(param_addr_i),
             .data(param_data_i),
             .out(node_o)
         );

endmodule

module SRAM #(
        parameter ADDR_SIZE=8,
        parameter DATA_WIDTH=32
    ) (
        input clk, rstn,
        input write_en,
        input [ADDR_SIZE-1:0] addr,
        input [DATA_WIDTH-1:0] data,
        output reg [DATA_WIDTH-1:0] out
    );
    localparam RAM_DEPTH = 1<<ADDR_SIZE;
    reg [DATA_WIDTH-1:0] sram [RAM_DEPTH-1:0];
    integer i;
    always@(posedge clk) begin
        if(~rstn) begin
            for(i=0; i<RAM_DEPTH; i=i+1) begin
                sram[i] <= 0;
            end
        end
        else if(write_en)
            sram[addr] <= data;
        else
            out <= sram[addr];
    end

endmodule
