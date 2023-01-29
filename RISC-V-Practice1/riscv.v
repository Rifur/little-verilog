//see: https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf
`define _ADD 3'h0 //SUB funct7==7'b010_0000
`define _XOR 3'h4
`define _OR  3'h6
`define _AND 3'h7
`define _SLL 3'h1 //Shift Left Logical
`define _SRL 3'h5 //SRA funct7==7'b010_0000 for msb-extend
`define _SLT 3'h2 //Set Less Than
`define _SLTU 3'h3 //zero-extend

`define _ADDI 3'h0
`define _ORI  3'h6
`define _ANDI 3'h7

`define _JAR 7'b1101111

module sram(dout, din, rd_addr, wr_addr, wr_en, clk);
    parameter WIDTH = 32;
    parameter SIZE = 32;
    output [WIDTH-1:0] dout;
    input [WIDTH-1:0] din;
    input [SIZE-1:0] rd_addr, wr_addr;
    input wr_en, clk;
    reg [WIDTH-1:0] mem [0:SIZE-1];

    assign dout = mem[rd_addr[SIZE-1:2]];

    always @(posedge clk) begin
        if(wr_en)
            mem[wr_addr] <=din;
    end

    integer  i;
    initial begin
        //TEST: x1=x1+x2
        /*for(i=0; i<SIZE; i=i+1) begin
            mem[i] = {5'b00010, 5'b00001, 3'h0, 5'b00001, 7'b0110011};
        end*/

        for(i=0; i<SIZE; i=i+1)
            mem[i] = 32'bx;

        //TEST: Fibonacci
        //clear x1; xor x1, x1, x1; x1 ^= x1;
        mem[0] = {7'b000_0000, 5'd1, 5'd1, `_XOR, 5'd1, 7'b0110011};
        //clear x2; xor x2, x2, x2; x2 ^= x2
        mem[1] = {7'b000_0000, 5'd2, 5'd2, `_XOR, 5'd2, 7'b0110011};
        //set x1=1; addi x1, x1, 1; x1 = x1 + 1;
        mem[2] = {11'b000_0000_0001, 5'd1, `_ADDI, 5'd1, 7'b0010011};
        //set x2=1; addi x2, x2, 1; x2 = x2 + 1;
        mem[3] = {11'b000_0000_0000, 5'd2, `_ADDI, 5'd2, 7'b0010011};
        //x1 = x1 + x2; add x1, x1, x2;
        mem[4] = {7'b000_0000, 5'd2, 5'd1, `_ADD, 5'd1, 7'b0110011};
        //x2 = x1 + x2; add x2, x1, x2;
        mem[5] = {7'b000_0000, 5'd2, 5'd1, `_ADD, 5'd2, 7'b0110011};
        //jump mem[4]
        mem[6] = {1'b1, 10'b11_1111_1110, 1'b1, 8'b1111_1111, 5'd0, `_JAR};

    end

endmodule


module riscv(clk, rst_n, pc, instruction , regRd);
    parameter XLEN = 32;
    parameter REGNUM = 32;
    input clk, rst_n;
    output reg [XLEN-1:0] pc;
    output [31:0] instruction;
    output [31:0] regRd;

    reg [XLEN-1:0] regfile [REGNUM:0];
    reg [31:0] wr_addr;
    wire wr_en;
    wire [31:0] din;

    wire [6:0] opcode = instruction[6:0]; //[1:0] are always 2'b11
    wire [4:0] rd = instruction [11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [6:0] funct7 = instruction[31:25];
    wire [11:0] immI = instruction[31:20];
    wire [11:0] immS = {instruction[31:25], instruction[4:0]};
    wire [19:0] immU = instruction[31:12];
    wire [19:0] immJ = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};

    sram code (.dout(instruction), .din(0), .rd_addr(pc),
               .wr_addr(wr_addr), .wr_en(wr_en), .clk(clk));

    integer i;
    initial begin
        //TEST: initialize x0~x31 = 0~31
        for(i=0; i<REGNUM; i=i+1)
            regfile[i] <= i;
    end

    always@(posedge clk) begin
        if(!rst_n)
            pc <= 0;
        else begin
            if(opcode == `_JAR)
                pc <= pc + {{11{immJ[19]}}, immJ[19:0], 1'b0}; //sign-extend and *2
            else
                //pc <= pc + (opcode == `_JAR ?  {{11{immJ[19]}}, immJ[19:0], 1'b0} : 0);
                pc <= pc + 32'd4;
        end
    end


    assign regRd = regfile[rd];

    always@(posedge clk) begin
        if(opcode == 7'b0110011) begin
            case(funct3)
                `_ADD:
                    regfile[rd] <=(funct7&7'b010_0000) ?
                    (regfile[rs1] - regfile[rs2])
                    :(regfile[rs1] + regfile[rs2]);
                `_XOR:
                    regfile[rd] <= regfile[rs1] ^ regfile[rs2];
                `_OR:
                    regfile[rd] <= regfile[rs1] | regfile[rs2];
                `_AND:
                    regfile[rd] <= regfile[rs1] & regfile[rs2];
                `_SLL:
                    regfile[rd] <= regfile[rs1] <<regfile[rs2];
                `_SRL:
                    regfile[rd] <= (funct7&7'b010_0000)?
                    (regfile[rs1] >>>regfile[rs2])
                    :(regfile[rs1] >>regfile[rs2]);
                `_SLT:
                    regfile[rd] <= (regfile[rs1] < regfile[rs2]) ? 32'hFFFFFFFF : 0;
                `_SLTU:
                    regfile[rd] <= (regfile[rs1] < regfile[rs2]) ? 32'h00000001 : 0;
            endcase
        end
        else if(opcode == 7'b0010011) begin
            case(funct3)
                `_ADDI:
                    regfile[rd] <= regfile[rs1] + immI;
                `_ORI:
                    regfile[rd] <= regfile[rs1] | immI;
            endcase
        end
        else if(opcode == `_JAR) begin
            regfile[rd] <= pc + 4;
        end
        else begin
        end
    end

endmodule

//yosys -p "prep -top riscv; write_json output.json" riscv.v
//netlistsvg output.json
