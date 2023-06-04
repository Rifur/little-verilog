//yosys -p "prep -top linkedlist; write_json output.json" HTLinkedList.v
//iverilog -Wimplicit -o am test_HTLinkedlist.v HTLinkedList.v linkedlist.v sram.v
module HTLinkedList
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
    reg [3:0] state, waitsram_state;
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

    //parameter SIZE=4094;
    parameter SIZE=10;
    parameter IDLE=0;
    parameter SEARCH=1;
    parameter APPEND=2;
    parameter APPEND_FIND=3;
    parameter APPEND_NEW=4;
    parameter APPEND_DONE=5;
    parameter SEARCH_FIND=6;
    parameter SHOW=7;
    parameter WAIT_SRAM=10;

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
            waitsram_state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    found_o <= 0;
                    append_o <= 0;
                    done_o <= 0;
                    param_we <= 0;
                    param_addr <= 0;
                    waitsram_state <= 0;
                    rho <= rho_i;
                    if(search_i) begin
                        state <= WAIT_SRAM;
                        waitsram_state <= SEARCH;
                    end
                    else if(append_i) begin
                        state <= WAIT_SRAM;
                        waitsram_state <= APPEND;
                    end
                    else if(show_i) begin
                        state <= WAIT_SRAM;
                        waitsram_state <= SHOW;
                        param_addr <= param_addr_i;
                    end
                    else
                        state <= IDLE;
                end
                SEARCH: begin
                    if(node_next != 0) begin
                        param_addr <= node_next;
                        state <= WAIT_SRAM;
                        waitsram_state <= SEARCH_FIND;
                    end
                    else begin
                        state <= IDLE;
                        done_o <= 1;
                        found_o <= 0;
                    end
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
                        state <= WAIT_SRAM;
                        waitsram_state <= APPEND_FIND;
                    end
                    else begin
                        if(nextIndex+1 < SIZE) begin
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
                APPEND_FIND: begin
                    if(node_rho==rho) begin
                        param_we <= 1'b1;
                        param_data <= {node_rho, node_vote+10'b1, node_next};
                        state <= APPEND_DONE;
                    end
                    else begin
                        state <= APPEND;
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
                WAIT_SRAM: begin
                    state <= waitsram_state;
                end
                SHOW: begin
                    state <= IDLE;
                    done_o <= 1;
                end
            endcase
        end
    end

endmodule
