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

