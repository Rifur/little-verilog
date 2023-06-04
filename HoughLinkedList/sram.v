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
