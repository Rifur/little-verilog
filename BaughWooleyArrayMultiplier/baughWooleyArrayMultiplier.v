//Origin: https://github.com/ppashakhanloo/verilog-array-multiplier/blob/master/ArrayMultiplier.v
//Introduction to Baugh-Wookey signed array multiplier: https://zhuanlan.zhihu.com/p/126738881?utm_id=0

//yosys+netlistsvg genenates RTL schematic
//  yosys -p "prep -top baughWooleyArrayMultiplier; write_json output.json" baughWooleyArrayMultiplier.v
//  netlistsvg output.json

//iVerilog generates GTKWave
//  iverilog -o am testbench_arrayMultiple.v baughWooleyArrayMultiplier.v
//  ./am
// then open mytest.vcd with GTKWave

module BarCell(bn, am, si, ci, co, so);
    input bn, am, si, ci;
    output co, so;
    wire t;
    nand (t, am, bn);
    FACell fa(.bn(t), .am(si), .ci(ci), .co(co), .so(so));
endmodule

module Cell(bn, am, si, ci, co, so);
    input bn, am, si, ci;
    output co, so;
    wire t;
    and (t, bn, am);
    FACell fa(.bn(t), .am(si), .ci(ci), .co(co), .so(so));
endmodule

module FACell(bn, am, ci, co, so);
    input bn, am, ci;
    output co, so;
    wire t1, t2, t3;
    xor (t1, am, bn);
    and (t2, am, bn);
    xor (so, t1, ci);
    and (t3, t1, ci);
    or (co, t2, t3);
endmodule


module baughWooleyArrayMultiplier(product, a, b);
    parameter M = 32;
    parameter N = 32;
    output [M+N-1:0] product;
    input [M-1:0] a;
    input [N-1:0] b;
    wire [M-1:0] c_partial[N-1:0] ;
    wire [M-1:0] s_partial[N-1:0] ;

    genvar i, j;
    generate
        for(i=0; i<N; i=i+1)begin
            for(j=0; j<M; j=j+1)begin
                if(i == 0) begin
                    if(j<M-1)
                        Cell cell_first(.bn(b[i]), .am(a[j]), .si(1'b0), .ci(1'b0),
                                        .co(c_partial[i][j]), .so(s_partial[i][j]));
                    else
                        BarCell bcell_first(.bn(b[i]), .am(a[j]), .si(1'b0), .ci(1'b0),
                                            .co(c_partial[i][j]), .so(s_partial[i][j]));
                end
                else if(i<N-1) begin
                    if(j<M-1)
                        Cell cell_middle(b[i], a[j], s_partial[i-1][j+1], c_partial[i-1][j],
                                         c_partial[i][j], s_partial[i][j]);
                    else
                        BarCell bcell_middle(.bn(b[i]), .am(a[j]), .si(1'b0), .ci(c_partial[i-1][j]),
                                             .co(c_partial[i][j]), .so(s_partial[i][j]));
                end
                else begin
                    if(j<M-1)
                        BarCell bcell_last(.bn(b[i]), .am(a[j]), .si(s_partial[i-1][j+1]), .ci(c_partial[i-1][j]),
                                           .co(c_partial[i][j]), .so(s_partial[i][j]));
                    else
                        Cell cell_last(.bn(b[i]), .am(a[j]), .si(1'b0), .ci(c_partial[i-1][j]),
                                       .co(c_partial[i][j]), .so(s_partial[i][j]));
                end
            end
        end
    endgenerate

    wire [M:0] c_last;
    assign c_last[0] = 1'b1;
    generate
        for(i=0; i<N; i=i+1)begin
            assign product[i] = s_partial[i][0];
        end
    endgenerate

    generate
        for(j=0; j<M; j=j+1)begin
            if(j<M-1)
                FACell fa(s_partial[N-1][j+1], c_partial[N-1][j], c_last[j],
                          c_last[j+1], product[N+j]);
            else
                FACell fa(1'b1, c_partial[N-1][j], c_last[j],
                          c_last[j+1], product[N+j]);
        end
    endgenerate
endmodule
