module rv32_single (
    input wire clk,
    input wire reset,
    output reg halted,
    output reg [31:0] pc,
    output wire [31:0] instruction,
    output reg [31:0] alu_result,
    output reg [31:0] writeback_data
);
    reg [31:0] imem [0:255];
    reg [31:0] dmem [0:255];
    reg [31:0] registers [0:31];
    wire [31:0] inst = imem[pc[9:2]];
    assign instruction = inst;

    wire [6:0] opcode=inst[6:0];
    wire [4:0] rd=inst[11:7], rs1=inst[19:15], rs2=inst[24:20];
    wire [2:0] funct3=inst[14:12];
    wire [6:0] funct7=inst[31:25];
    wire [31:0] imm_i={{20{inst[31]}},inst[31:20]};
    wire [31:0] imm_s={{20{inst[31]}},inst[31:25],inst[11:7]};
    wire [31:0] imm_b={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
    wire [31:0] imm_u={inst[31:12],12'b0};
    wire [31:0] imm_j={{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
    reg [31:0] a,b,alu_value,store_value,next_pc;
    reg reg_write,mem_write,mem_read,branch,take_branch,jump,jalr;
    reg [31:0] immediate;
    integer i;

    initial begin
        for(i=0;i<256;i=i+1) begin imem[i]=32'h00000013; dmem[i]=0; end
        for(i=0;i<32;i=i+1) registers[i]=0;
    end

    always @(*) begin
        a=registers[rs1];
        b=registers[rs2];
        alu_value=0;
        store_value=registers[rs2];
        immediate=imm_i;
        reg_write=0; mem_write=0; mem_read=0; branch=0; jump=0; jalr=0;
        take_branch=0;
        case(opcode)
            7'b0110111: begin alu_value=imm_u; reg_write=1; end
            7'b0010011: begin
                reg_write=1;
                case(funct3)
                    3'b000: alu_value=a+imm_i;
                    3'b111: alu_value=a&imm_i;
                    3'b110: alu_value=a|imm_i;
                    3'b100: alu_value=a^imm_i;
                    3'b010: alu_value=($signed(a)<$signed(imm_i))?1:0;
                    3'b001: alu_value=a<<inst[24:20];
                    3'b101: begin
                        if(inst[30]) alu_value=$signed(a)>>>inst[24:20];
                        else alu_value=a>>inst[24:20];
                    end
                    default: alu_value=0;
                endcase
            end
            7'b0110011: begin
                reg_write=1;
                case(funct3)
                    3'b000: alu_value=funct7[5] ? a-b : a+b;
                    3'b111: alu_value=a&b;
                    3'b110: alu_value=a|b;
                    3'b100: alu_value=a^b;
                    3'b010: alu_value=($signed(a)<$signed(b))?1:0;
                    3'b001: alu_value=a<<b[4:0];
                    3'b101: begin
                        if(funct7[5]) alu_value=$signed(a)>>>b[4:0];
                        else alu_value=a>>b[4:0];
                    end
                    default: alu_value=0;
                endcase
            end
            7'b0000011: begin alu_value=a+imm_i; mem_read=1; reg_write=1; end
            7'b0100011: begin alu_value=a+imm_s; mem_write=1; end
            7'b1100011: begin
                branch=1; immediate=imm_b;
                case(funct3)
                    3'b000: take_branch=(a==b);
                    3'b001: take_branch=(a!=b);
                    3'b100: take_branch=($signed(a)<$signed(b));
                    3'b101: take_branch=($signed(a)>=$signed(b));
                    default: take_branch=0;
                endcase
            end
            7'b1101111: begin alu_value=pc+4; reg_write=1; jump=1; immediate=imm_j; end
            7'b1100111: begin alu_value=pc+4; reg_write=1; jalr=1; immediate=imm_i; end
            default: begin end
        endcase
        next_pc=pc+4;
        if(branch && take_branch) next_pc=pc+imm_b;
        else if(jump) next_pc=pc+imm_j;
        else if(jalr) next_pc=(a+imm_i)&32'hfffffffe;
        writeback_data=alu_value;
        if(mem_read) writeback_data=dmem[alu_value[9:2]];
        alu_result=alu_value;
    end

    always @(posedge clk) begin
        if(reset) begin
            pc<=0; halted<=0;
            for(i=0;i<32;i=i+1) registers[i]<=0;
            for(i=0;i<256;i=i+1) dmem[i]<=0;
        end else if(!halted) begin
            if(inst==32'h00000073) halted<=1;
            else begin
                if(mem_write) dmem[alu_result[9:2]]<=store_value;
                if(reg_write && rd!=0) registers[rd]<=writeback_data;
                registers[0]<=0;
                pc<=next_pc;
            end
        end
    end
endmodule
