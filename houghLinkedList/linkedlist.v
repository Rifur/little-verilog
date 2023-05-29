//yosys -p "prep -top linkedlist; write_json output.json" linkedlist.v
//iverilog -Wimplicit -o am test_HTLinkedlist.v linkedlist.v
module HTLinkList
    (
        input clk, rstn,
        input [9:0] rho_i,
        input append_i, search_i,
        output reg done_o, append_o, found_o,
        output wire [31:0] node_o
    );

    reg [3:0] state, ns;
    reg [11:0] capacity;
    reg param_we;
    reg [11:0] param_addr;
    reg [31:0] param_data;
    reg capacity_plus_one;
    wire [9:0] node_rho;
    wire [9:0] node_vote;
    wire [11:0] node_next;
    assign node_rho = node_o[31:22];
    assign node_vote = node_o[21:12];
    assign node_next = node_o[11:0];

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

    parameter FULL=4094;
    parameter IDLE=0;
    parameter SEARCH=1;
    parameter APPEND=2;
    parameter APPEND_DONE=3;

    always@(posedge clk) begin
        if(~rstn) begin
            state <= IDLE;
            param_we <= 0;
            param_addr <= 1; //remainder [0] as NULL
            param_data <= 0;
            found_o <= 0;
            append_o <= 0;
            done_o <= 0;
            capacity <= 12'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    found_o <= 0;
                    append_o <= 0;
                    done_o <= 0;
                    param_we <= 0;
                    param_addr <= 1;
                    if(search_i)
                        state <= SEARCH;
                    else if(append_i)
                        state <= APPEND;
                    else
                        state <= IDLE;
                end
                SEARCH: begin
                    if(node_rho != rho_i) begin
                        if(node_next == 0) begin
                            state <= IDLE;
                            done_o <= 1'b1;
                            found_o <= 1'b0;
                        end
                        else begin
                            state <= SEARCH;
                            param_addr <= node_next;
                        end
                    end
                    else begin
                        state <= IDLE;
                        done_o <= 1'b1;
                        found_o <= 1'b1;
                    end
                end
                APPEND: begin
                    if(node_rho != rho_i) begin
                        if(node_next == 0) begin
                            if(capacity < FULL) begin
                                state <= APPEND_DONE;
                                param_we <= 1'b1;
                                capacity <= capacity + 12'b1;
                                param_addr <= capacity + 12'b1;
                                //param_data <= {rho_i, 10'd1, {12{1'b0}}};
                                param_data <= {rho_i, 10'd1, capacity+12'd2};
                            end
                            else begin
                                state <= IDLE;
                                done_o <= 1'b1;
                            end
                        end
                        else begin
                            state <= APPEND;
                            param_addr <= node_next;
                        end
                    end
                    else begin
                        state <= APPEND_DONE;
                        param_we <= 1'b1;
                        param_data <= {node_rho, node_vote+10'd1, node_next};
                        //param_data <= 32'h12345678;
                    end
                end
                APPEND_DONE: begin
                    state <= IDLE;
                    param_we <= 0;
                    done_o <= 1;
                    append_o <= 1;
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
