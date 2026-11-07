module rv32_pipeline_mutation #(
    parameter OMIT_FORWARDING = 0,
    parameter OMIT_LOAD_STALL = 0,
    parameter OMIT_FLUSH = 0
) (
    input wire clk,
    input wire reset,
    output reg halted,
    output reg [31:0] pc,
    output reg [31:0] total_cycles,
    output reg [31:0] instructions_retired,
    output reg [31:0] stall_cycles,
    output reg [31:0] flush_cycles
);
    reg [31:0] imem [0:255];
    reg [31:0] dmem [0:255];
    reg [31:0] registers [0:31];
    integer i;

    reg [31:0] ifid_pc, ifid_inst;
    reg [31:0] idex_pc, idex_inst, idex_a, idex_b, idex_imm;
    reg [4:0] idex_rs1, idex_rs2, idex_rd;
    reg idex_valid, idex_regwrite, idex_memread, idex_memwrite, idex_alusrc;
    reg idex_branch, idex_jal, idex_jalr, idex_lui, idex_halt;

    reg [31:0] exmem_pc, exmem_alu, exmem_store_data;
    reg [4:0] exmem_rd;
    reg exmem_valid, exmem_regwrite, exmem_memread, exmem_memwrite, exmem_halt;

    reg [31:0] memwb_result, memwb_load_data;
    reg [4:0] memwb_rd;
    reg memwb_regwrite, memwb_memread, memwb_halt, memwb_valid;

    reg fetch_stopped;
    wire [6:0] id_opcode=ifid_inst[6:0];
    wire [4:0] id_rs1=ifid_inst[19:15], id_rs2=ifid_inst[24:20];
    wire [4:0] id_rd=ifid_inst[11:7];
    wire [2:0] id_funct3=ifid_inst[14:12];
    reg [31:0] id_imm, id_read_a, id_read_b;
    reg id_regwrite, id_memread, id_memwrite, id_alusrc;
    reg id_branch, id_jal, id_jalr, id_lui, id_uses_rs1, id_uses_rs2;

    wire [31:0] wb_value = memwb_memread ? memwb_load_data : memwb_result;
    wire stall = !OMIT_LOAD_STALL && idex_memread && idex_rd!=0 &&
        ((id_uses_rs1 && id_rs1==idex_rd) || (id_uses_rs2 && id_rs2==idex_rd));
    reg [31:0] ex_a, ex_b_raw, ex_b, ex_result, ex_target, ex_store_data;
    reg ex_take_branch, ex_redirect;
    reg [1:0] forward_a, forward_b;
    wire [31:0] mem_load_data = dmem[exmem_alu[9:2]];

    initial begin
        for(i=0;i<256;i=i+1) begin imem[i]=32'h00000013; dmem[i]=0; end
        for(i=0;i<32;i=i+1) registers[i]=0;
    end

    always @(*) begin
        id_imm={{20{ifid_inst[31]}},ifid_inst[31:20]};
        id_regwrite=0; id_memread=0; id_memwrite=0; id_alusrc=0;
        id_branch=0; id_jal=0; id_jalr=0; id_lui=0;
        id_uses_rs1=0; id_uses_rs2=0;
        case(id_opcode)
            7'b0110111: begin id_imm={ifid_inst[31:12],12'b0}; id_regwrite=1; id_lui=1; end
            7'b0010011: begin id_regwrite=1; id_alusrc=1; id_uses_rs1=1; end
            7'b0110011: begin id_regwrite=1; id_uses_rs1=1; id_uses_rs2=1; end
            7'b0000011: begin id_regwrite=1; id_memread=1; id_alusrc=1; id_uses_rs1=1; end
            7'b0100011: begin
                id_imm={{20{ifid_inst[31]}},ifid_inst[31:25],ifid_inst[11:7]};
                id_memwrite=1; id_alusrc=1; id_uses_rs1=1; id_uses_rs2=1;
            end
            7'b1100011: begin
                id_imm={{19{ifid_inst[31]}},ifid_inst[31],ifid_inst[7],
                    ifid_inst[30:25],ifid_inst[11:8],1'b0};
                id_branch=1; id_uses_rs1=1; id_uses_rs2=1;
            end
            7'b1101111: begin
                id_imm={{11{ifid_inst[31]}},ifid_inst[31],ifid_inst[19:12],
                    ifid_inst[20],ifid_inst[30:21],1'b0};
                id_jal=1; id_regwrite=1;
            end
            7'b1100111: begin id_jalr=1; id_regwrite=1; id_alusrc=1; id_uses_rs1=1; end
            default: begin end
        endcase
        id_read_a=(id_rs1==0)?0:registers[id_rs1];
        id_read_b=(id_rs2==0)?0:registers[id_rs2];
        if(memwb_regwrite && memwb_rd!=0 && memwb_rd==id_rs1) id_read_a=wb_value;
        if(memwb_regwrite && memwb_rd!=0 && memwb_rd==id_rs2) id_read_b=wb_value;
    end

    always @(*) begin
        forward_a=0; forward_b=0;
        if(!OMIT_FORWARDING && exmem_regwrite && !exmem_memread && exmem_rd!=0 && exmem_rd==idex_rs1)
            forward_a=1;
        else if(!OMIT_FORWARDING && memwb_regwrite && memwb_rd!=0 && memwb_rd==idex_rs1)
            forward_a=2;
        if(!OMIT_FORWARDING && exmem_regwrite && !exmem_memread && exmem_rd!=0 && exmem_rd==idex_rs2)
            forward_b=1;
        else if(!OMIT_FORWARDING && memwb_regwrite && memwb_rd!=0 && memwb_rd==idex_rs2)
            forward_b=2;

        ex_a=idex_a;
        case(forward_a)
            1: ex_a=exmem_alu;
            2: ex_a=wb_value;
            default: ex_a=idex_a;
        endcase
        ex_b_raw=idex_b;
        case(forward_b)
            1: ex_b_raw=exmem_alu;
            2: ex_b_raw=wb_value;
            default: ex_b_raw=idex_b;
        endcase
        ex_b=idex_alusrc ? idex_imm : ex_b_raw;
        ex_store_data=ex_b_raw;
        ex_result=0;
        ex_take_branch=0;
        if(idex_lui) ex_result=idex_imm;
        else if(idex_jal || idex_jalr) ex_result=idex_pc+4;
        else begin
            case(idex_inst[6:0])
                7'b0010011: begin
                    case(idex_inst[14:12])
                        3'b000: ex_result=ex_a+idex_imm;
                        3'b111: ex_result=ex_a&idex_imm;
                        3'b110: ex_result=ex_a|idex_imm;
                        3'b100: ex_result=ex_a^idex_imm;
                        3'b010: ex_result=($signed(ex_a)<$signed(idex_imm))?1:0;
                        3'b001: ex_result=ex_a<<idex_inst[24:20];
                        3'b101: begin
                            if(idex_inst[30]) ex_result=$signed(ex_a)>>>idex_inst[24:20];
                            else ex_result=ex_a>>idex_inst[24:20];
                        end
                        default: ex_result=0;
                    endcase
                end
                7'b0110011: begin
                    case(idex_inst[14:12])
                        3'b000: ex_result=idex_inst[30]?ex_a-ex_b_raw:ex_a+ex_b_raw;
                        3'b111: ex_result=ex_a&ex_b_raw;
                        3'b110: ex_result=ex_a|ex_b_raw;
                        3'b100: ex_result=ex_a^ex_b_raw;
                        3'b010: ex_result=($signed(ex_a)<$signed(ex_b_raw))?1:0;
                        3'b001: ex_result=ex_a<<ex_b_raw[4:0];
                        3'b101: begin
                            if(idex_inst[30]) ex_result=$signed(ex_a)>>>ex_b_raw[4:0];
                            else ex_result=ex_a>>ex_b_raw[4:0];
                        end
                        default: ex_result=0;
                    endcase
                end
                7'b0000011,7'b0100011: ex_result=ex_a+idex_imm;
                default: ex_result=0;
            endcase
        end
        if(idex_branch) begin
            case(idex_inst[14:12])
                3'b000: ex_take_branch=(ex_a==ex_b_raw);
                3'b001: ex_take_branch=(ex_a!=ex_b_raw);
                3'b100: ex_take_branch=($signed(ex_a)<$signed(ex_b_raw));
                3'b101: ex_take_branch=($signed(ex_a)>=$signed(ex_b_raw));
                default: ex_take_branch=0;
            endcase
        end
        ex_redirect=(idex_jal || idex_jalr || (idex_branch && ex_take_branch));
        if(idex_jalr) ex_target=(ex_a+idex_imm)&32'hfffffffe;
        else ex_target=idex_pc+idex_imm;
    end

    always @(posedge clk) begin
        if(reset) begin
            pc<=0; halted<=0; fetch_stopped<=0;
            ifid_pc<=0; ifid_inst<=0;
            idex_pc<=0; idex_inst<=0; idex_a<=0; idex_b<=0; idex_imm<=0;
            idex_rs1<=0; idex_rs2<=0; idex_rd<=0;
            idex_valid<=0; idex_regwrite<=0; idex_memread<=0; idex_memwrite<=0; idex_alusrc<=0;
            idex_branch<=0; idex_jal<=0; idex_jalr<=0; idex_lui<=0; idex_halt<=0;
            exmem_pc<=0; exmem_alu<=0; exmem_store_data<=0; exmem_rd<=0;
            exmem_valid<=0; exmem_regwrite<=0; exmem_memread<=0; exmem_memwrite<=0; exmem_halt<=0;
            memwb_result<=0; memwb_load_data<=0; memwb_rd<=0;
            memwb_regwrite<=0; memwb_memread<=0; memwb_halt<=0; memwb_valid<=0;
            total_cycles<=0; instructions_retired<=0; stall_cycles<=0; flush_cycles<=0;
            for(i=0;i<32;i=i+1) registers[i]<=0;
            for(i=0;i<256;i=i+1) dmem[i]<=0;
        end else if(!halted) begin
            total_cycles<=total_cycles+1'b1;
            if(memwb_valid && !memwb_halt) instructions_retired<=instructions_retired+1'b1;
            if(stall) stall_cycles<=stall_cycles+1'b1;
            if(ex_redirect && !OMIT_FLUSH) flush_cycles<=flush_cycles+1'b1;

            if(memwb_regwrite && memwb_rd!=0) registers[memwb_rd]<=wb_value;
            registers[0]<=0;

            if(exmem_memwrite) dmem[exmem_alu[9:2]]<=exmem_store_data;
            memwb_result<=exmem_alu;
            memwb_load_data<=mem_load_data;
            memwb_rd<=exmem_rd;
            memwb_regwrite<=exmem_regwrite;
            memwb_memread<=exmem_memread;
            memwb_halt<=exmem_halt;
            memwb_valid<=exmem_valid;

            exmem_pc<=idex_pc; exmem_alu<=ex_result; exmem_store_data<=ex_store_data;
            exmem_valid<=idex_valid; exmem_rd<=idex_rd; exmem_regwrite<=idex_regwrite;
            exmem_memread<=idex_memread; exmem_memwrite<=idex_memwrite; exmem_halt<=idex_halt;

            if(ex_redirect && !OMIT_FLUSH) begin
                pc<=ex_target;
                ifid_pc<=0; ifid_inst<=0;
                idex_pc<=0; idex_inst<=0; idex_a<=0; idex_b<=0; idex_imm<=0;
                idex_rs1<=0; idex_rs2<=0; idex_rd<=0;
                idex_valid<=0; idex_regwrite<=0; idex_memread<=0; idex_memwrite<=0; idex_alusrc<=0;
                idex_branch<=0; idex_jal<=0; idex_jalr<=0; idex_lui<=0; idex_halt<=0;
            end else if(stall) begin
                idex_pc<=0; idex_inst<=0; idex_a<=0; idex_b<=0; idex_imm<=0;
                idex_rs1<=0; idex_rs2<=0; idex_rd<=0;
                idex_valid<=0; idex_regwrite<=0; idex_memread<=0; idex_memwrite<=0; idex_alusrc<=0;
                idex_branch<=0; idex_jal<=0; idex_jalr<=0; idex_lui<=0; idex_halt<=0;
            end else begin
                idex_pc<=ifid_pc; idex_inst<=ifid_inst; idex_a<=id_read_a;
                idex_b<=id_read_b; idex_imm<=id_imm; idex_rs1<=id_rs1;
                idex_rs2<=id_rs2; idex_rd<=id_rd;
                idex_valid<=(ifid_inst!=0); idex_regwrite<=id_regwrite; idex_memread<=id_memread;
                idex_memwrite<=id_memwrite; idex_alusrc<=id_alusrc;
                idex_branch<=id_branch; idex_jal<=id_jal; idex_jalr<=id_jalr;
                idex_lui<=id_lui; idex_halt<=(ifid_inst==32'h00000073);
            end

            if(ex_redirect) begin
                fetch_stopped<=0;
            end else if(!stall) begin
                if(ifid_inst==32'h00000073) begin fetch_stopped<=1; ifid_inst<=0; ifid_pc<=0; end
                else if(fetch_stopped) begin ifid_inst<=0; ifid_pc<=0; end
                else begin
                    ifid_pc<=pc;
                    ifid_inst<=imem[pc[9:2]];
                    pc<=pc+4;
                end
            end

            if(memwb_halt) halted<=1;
        end
    end
endmodule
