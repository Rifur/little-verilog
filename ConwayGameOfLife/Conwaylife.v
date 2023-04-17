module top_module(
    input clk,
    input load,
    input [255:0] data,
    output reg [255:0] q ); 

    integer i, j, x, y, w, h;
    reg [15:0] next_q [15:0];
    reg [3:0] counter [0:15][0:15];
    always@(*) begin
        for(i=0; i<16; i=i+1) begin
            next_q[i] = q[i*16 +: 16];
            for(j=0; j<16; j=j+1) begin
                counter[i][j] = 0;
            end
        end
        
        for(i=0; i<16; i=i+1) begin
            for(j=0; j<16; j=j+1) begin
                x = (16+(i-1))%16;
                y = (16+(j-1))%16;
                w = (16+(i+1))%16;
                h = (16+(j+1))%16;
                counter[i][j] = 
                	next_q[x][y] + next_q[x][j] + next_q[x][h] + 
                    next_q[i][y] +                next_q[i][h] + 
                    next_q[w][y] + next_q[w][j] + next_q[w][h];
            end
        end

        for(i=0; i<16; i=i+1) begin
            for(j=0; j<16; j=j+1) begin
                if(counter[i][j] <= 4'd1)
                    next_q[i][j] = 0;
                else if(counter[i][j] == 4'd3)
                    next_q[i][j] = 1;
                else if(counter[i][j] >= 4'd4)
                    next_q[i][j] = 0;
            end
        end
    end
    
    always@(posedge clk) begin
        if(load)
            q <= data;
        else begin
            for(i=0; i<16; i=i+1) begin
                for(j=0; j<16; j=j+1) begin
                    q[i*16 + j] <= next_q[i][j]; 
                end
            end
        end
            
    end
    
endmodule