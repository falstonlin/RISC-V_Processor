`include "Parameter.v"
module Controller (
    input[6:0] opcode,
    input[2:0] func3,
    input      func5,
    input[1:0] func7,
    input[4:0] ID_rs1_addr,
    input[4:0] ID_rs2_addr,
    input[4:0] ID_rd_addr,

    input[4:0] WB_rd_addr,
    input[4:0] EX_rd_addr,
    input[4:0] MEM_rd_addr,

    input      WB_Ird_en,
    input      WB_Frd_en,
    input      EX_Ird_en,
    input      EX_Frd_en,
    input      MEM_Ird_en,
    input      MEM_Frd_en,

    input      WB_IoF_Rgd,
    input      EX_IoF_Rgd,
    input      MEM_IoF_Rgd,

    output reg ID_valid,
    output reg ID_branch,
    output reg ID_jump,
    output reg ID_jalr,
    output reg ID_load,
    output reg ID_store,
    output reg ID_mac,
    output reg ID_csr,
    output reg ID_arthF,
    
    output reg ID_IoF_Rg1,
    output reg ID_IoF_Rg2,
    output reg ID_IoF_Rgd,
    
    output reg[1:0] ID_mux_op0,
    output reg[1:0] ID_mux_op1,
    output reg[3:0] ID_mux_opr,
    output reg[1:0] ID_mux_xpu,
    
    output reg[1:0] ID_dm_mask, 
    output reg      ID_dm_sign,
    
    output reg      ID_Frd_en,
    output reg      ID_Ird_en,
    output reg      ID_mux_PoM,

    output reg      ID_fwd_WB1,
    output reg      ID_fwd_WB2,
    output reg      ID_fwd_WB3,
    output reg[1:0] ID_ex_fwd1,
    output reg[1:0] ID_ex_fwd2,
    output reg[1:0] ID_ex_fwd3
);
    reg ID_val_Rg1;
    reg ID_val_Rg2;
    always @(*) begin
        case (opcode)
            `AUIPC: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b0;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = 1'b0;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = `USE_PC;
                ID_mux_op1 = `USE_IMM;
                ID_mux_opr = `ADD;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
            end
            `LUI: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b0;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = 1'b0;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = `USE_0;
                ID_mux_op1 = `USE_IMM;
                ID_mux_opr = `ADD;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
            end
            `BRANCH: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b1;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b1;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = `USE_INT_REGFILE;
                ID_IoF_Rgd = 1'b0;
                ID_mux_op0 = `USE_RS1;
                ID_mux_op1 = `USE_RS2;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = 1'b0;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b0;
                case (func3)
                    3'b000: ID_mux_opr = `BEQ;
                    3'b001: ID_mux_opr = `BNE;
                    3'b100: ID_mux_opr = `BLT;
                    3'b101: ID_mux_opr = `BGE;
                    3'b110: ID_mux_opr = `BLTU;
                    3'b111: ID_mux_opr = `BGEU;
                    default:ID_mux_opr = 4'b0000;
                endcase
            end
            `JALR: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b1;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b1;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = `USE_PC;
                ID_mux_op1 = `USE_4;
                ID_mux_opr = `ADD;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
            end
            `JAL: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b1;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b0;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = 1'b0;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = `USE_PC;
                ID_mux_op1 = `USE_4;
                ID_mux_opr = `ADD;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
            end
            `ARTH_R: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b1;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = `USE_INT_REGFILE;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = `USE_RS1;
                ID_mux_op1 = `USE_RS2;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
                case (func3)
                    3'b000: begin
                        if (func7[0]) begin
                            ID_mux_opr = {{2{1'b0}}, `MUL};
                            ID_mux_xpu = `USE_MPU;
                        end
                        else begin
                            ID_mux_opr = (func7[1]) ? `SUB : `ADD;
                            ID_mux_xpu = `USE_ALU;
                        end
                    end
                    3'b001: begin
                        if (func7[0]) begin
                            ID_mux_opr = {{2{1'b0}}, `MULH};
                            ID_mux_xpu = `USE_MPU;
                        end
                        else begin
                            ID_mux_opr = `SLL;
                            ID_mux_xpu = `USE_ALU;
                        end
                    end
                    3'b010: begin
                        if (func7[0]) begin
                            ID_mux_opr = {{2{1'b0}}, `MULHSU};
                            ID_mux_xpu = `USE_MPU;
                        end
                        else begin
                            ID_mux_opr = `SLT;
                            ID_mux_xpu = `USE_ALU;
                        end
                    end
                    3'b011: begin
                        if (func7[0]) begin
                            ID_mux_opr = {{2{1'b0}}, `MULHU};
                            ID_mux_xpu = `USE_MPU;
                        end
                        else begin
                            ID_mux_opr = `SLTU;
                            ID_mux_xpu = `USE_ALU;
                        end
                    end
                    3'b100: begin
                        ID_mux_opr = `XOR;
                        ID_mux_xpu = `USE_ALU;
                    end
                    3'b101: begin
                        ID_mux_opr = (func7[1]) ? `SRA : `SRL;
                        ID_mux_xpu = `USE_ALU;
                    end
                    3'b110: begin
                        ID_mux_opr = `OR;
                        ID_mux_xpu = `USE_ALU;
                    end
                    3'b111: begin
                        ID_mux_opr = `AND;
                        ID_mux_xpu = `USE_ALU;
                    end
                    default: begin
                        ID_mux_opr = 4'b0000;
                        ID_mux_xpu = 2'b00;
                    end
                endcase
            end
            `ARTH_I: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = `USE_RS1;
                ID_mux_op1 = `USE_IMM;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
                case (func3)
                    3'b000: ID_mux_opr = `ADD; 
                    3'b001: ID_mux_opr = `SLL;
                    3'b010: ID_mux_opr = `SLT;
                    3'b011: ID_mux_opr = `SLTU;
                    3'b100: ID_mux_opr = `XOR;
                    3'b101: ID_mux_opr = (func7[1]) ? `SRA : `SRL;
                    3'b110: ID_mux_opr = `OR;
                    3'b111: ID_mux_opr = `AND;
                    default:ID_mux_opr = 4'b0000;
                endcase
            end
            `ARTH_F: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = (func3 == 3'b111) ? 1'b1 : 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b1;
                ID_IoF_Rg1 = `USE_FLT_REGFILE;
                ID_IoF_Rg2 = `USE_FLT_REGFILE;
                ID_IoF_Rgd = `USE_FLT_REGFILE;
                ID_mux_op0 = `USE_RS1;
                ID_mux_op1 = `USE_RS2;
                ID_mux_xpu = `USE_FPU;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b1;
                ID_Ird_en  = 1'b0;
                case (func3)
                    3'b000: ID_mux_opr = 4'b0000;
                    3'b001: ID_mux_opr = 4'b0001;
                    3'b111: ID_mux_opr = (func5) ? 4'b0011 : 4'b0010;
                    default:ID_mux_opr = 4'b0000;
                endcase
            end
            `LOAD_I: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b1;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = `USE_RS1;
                ID_mux_op1 = `USE_IMM;
                ID_mux_opr = `ADD;
                ID_mux_xpu = `USE_ALU;
                ID_mux_PoM = `USE_MEMORY;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
                case (func3)
                    3'b000: begin
                        ID_dm_mask = 2'b01;
                        ID_dm_sign = 1'b1;
                    end
                    3'b100: begin
                        ID_dm_mask = 2'b01;
                        ID_dm_sign = 1'b0;
                    end
                    3'b001: begin
                        ID_dm_mask = 2'b10;
                        ID_dm_sign = 1'b1;
                    end
                    3'b101: begin
                        ID_dm_mask = 2'b10;
                        ID_dm_sign = 1'b0;
                    end
                    3'b010: begin
                        ID_dm_mask = 2'b11;
                        ID_dm_sign = 1'b1;
                    end
                    default: begin
                        ID_dm_mask = 2'b00;
                        ID_dm_sign = 1'b0;
                    end
                endcase
            end
            `LOAD_F: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b1;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = `USE_FLT_REGFILE;
                ID_mux_op0 = `USE_RS1;
                ID_mux_op1 = `USE_IMM;
                ID_mux_opr = `ADD;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b11;
                ID_dm_sign = 1'b1;
                ID_mux_PoM = `USE_MEMORY;
                ID_Frd_en  = 1'b1;
                ID_Ird_en  = 1'b0;
            end
            `STORE_I: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b1;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b1;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = `USE_INT_REGFILE;
                ID_IoF_Rgd = 1'b0;
                ID_mux_op0 = `USE_RS1;
                ID_mux_op1 = `USE_IMM;
                ID_mux_opr = `ADD;
                ID_mux_xpu = `USE_ALU;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_MEMORY;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b0;
                case (func3)
                    3'b000: ID_dm_mask = 2'b01;                  
                    3'b001: ID_dm_mask = 2'b10;                  
                    3'b010: ID_dm_mask = 2'b11;
                    default:ID_dm_mask = 2'b00;
                endcase
            end
            `STORE_F: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b1;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b1;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = `USE_FLT_REGFILE;
                ID_IoF_Rgd = 1'b0;
                ID_mux_op0 = `USE_RS1;
                ID_mux_op1 = `USE_IMM;
                ID_mux_opr = `ADD;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b11;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_MEMORY;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b0;
            end
            `MAC: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b1;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b1;
                ID_val_Rg2 = 1'b1;
                ID_IoF_Rg1 = `USE_INT_REGFILE;
                ID_IoF_Rg2 = `USE_INT_REGFILE;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = `USE_XPU;
                ID_mux_op1 = `USE_REG;
                ID_mux_opr = 4'b0000;
                ID_mux_xpu = `USE_ALU;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
            end
            `SYSTEM: begin
                ID_valid   = 1'b1;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b1;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b0;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = 1'b0;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = `USE_INT_REGFILE;
                ID_mux_op0 = 2'b00;
                ID_mux_op1 = 2'b00;
                ID_mux_opr = 4'b0000;
                ID_mux_xpu = `USE_CSR;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = `USE_PROCESSOR;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b1;
            end
            `NOP: begin
                ID_valid   = 1'b0;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b0;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = 1'b0;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = 1'b0;
                ID_mux_op0 = 2'b00;
                ID_mux_op1 = 2'b00;
                ID_mux_opr = 4'b0000;
                ID_mux_xpu = 2'b00;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = 1'b0;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b0;
            end
            default: begin
                ID_valid   = 1'b0;
                ID_branch  = 1'b0;
                ID_jump    = 1'b0;
                ID_load    = 1'b0;
                ID_store   = 1'b0;
                ID_mac     = 1'b0;
                ID_csr     = 1'b0;
                ID_jalr    = 1'b0;
                ID_arthF   = 1'b0;
                ID_val_Rg1 = 1'b0;
                ID_val_Rg2 = 1'b0;
                ID_IoF_Rg1 = 1'b0;
                ID_IoF_Rg2 = 1'b0;
                ID_IoF_Rgd = 1'b0;
                ID_mux_op0 = 2'b00;
                ID_mux_op1 = 2'b00;
                ID_mux_opr = 4'b0000;
                ID_mux_xpu = 2'b00;
                ID_dm_mask = 2'b00;
                ID_dm_sign = 1'b0;
                ID_mux_PoM = 1'b0;
                ID_Frd_en  = 1'b0;
                ID_Ird_en  = 1'b0;
            end
        endcase
    end

    always @(*) begin
        if ((WB_rd_addr == ID_rs1_addr) && (WB_IoF_Rgd == ID_IoF_Rg1) && (WB_Ird_en || WB_Frd_en) && (ID_val_Rg1))
            ID_fwd_WB1 = 1'b1;
        else 
            ID_fwd_WB1 = 1'b0;

        if ((WB_rd_addr == ID_rs2_addr) && (WB_IoF_Rgd == ID_IoF_Rg2) && (WB_Ird_en || WB_Frd_en) && (ID_val_Rg2))
            ID_fwd_WB2 = 1'b1;
        else 
            ID_fwd_WB2 = 1'b0;

        if ((WB_rd_addr == ID_rd_addr) && (ID_mac) && (WB_Ird_en))
            ID_fwd_WB3 = 1'b1;
        else 
            ID_fwd_WB3 = 1'b0;
    end


    always @(*) begin
        if ((EX_rd_addr == ID_rs1_addr) && (EX_IoF_Rgd == ID_IoF_Rg1) && (EX_Ird_en || EX_Frd_en) && (ID_val_Rg1))
            ID_ex_fwd1 = 2'b11;
        else if ((MEM_rd_addr == ID_rs1_addr) && (MEM_IoF_Rgd == ID_IoF_Rg1) && (MEM_Ird_en || MEM_Frd_en) && (ID_val_Rg1))
            ID_ex_fwd1 = 2'b10;
        else
            ID_ex_fwd1 = 2'b00;

        if ((EX_rd_addr == ID_rs2_addr) && (EX_IoF_Rgd == ID_IoF_Rg2) && (EX_Ird_en || EX_Frd_en) && (ID_val_Rg2))
            ID_ex_fwd2 = 2'b11;
        else if ((MEM_rd_addr == ID_rs2_addr) && (MEM_IoF_Rgd == ID_IoF_Rg2) && (MEM_Ird_en || MEM_Frd_en) && (ID_val_Rg2))
            ID_ex_fwd2 = 2'b10;
        else
            ID_ex_fwd2 = 2'b00;  

        if ((EX_rd_addr == ID_rd_addr) && (ID_mac) && (EX_Ird_en))
            ID_ex_fwd3 = 2'b11;
        else if ((MEM_rd_addr == ID_rd_addr) && (ID_mac) && (MEM_Ird_en))
            ID_ex_fwd3 = 2'b10;
        else
            ID_ex_fwd3 = 2'b00;
    end
endmodule
