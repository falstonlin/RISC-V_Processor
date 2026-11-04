`include "Parameter.v"
`include "CS-RegFile.v"
`include "Decoder.v"
`include "Controller.v"
`include "Imm-Extend.v"
`include "FP-RegFile.v"
`include "Int-RegFile.v"
`include "JB-Unit.v"
`include "ALU.v"
`include "FPU-Comparator.v"
`include "FPU-Adder_2.v"
`include "MPU.v"
`include "LD-Filter.v"
`include "SE-Filter.v"
`include "Mac.v"
module Processor (
    input clk,
    input rst,

    output[31:0] im_addr,
    input [31:0] im_read_data,
    input        im_valid,
    output       stall_IF,
    output       flush_IF,

    input [31:0] dm_read_data,
   
    input        dm_busy,
    input        dm_write,
    output[31:0] dm_write_data,
    output[31:0] dm_bit_en,
    output       dm_WEB,
    output[31:0] dm_addr,
    output       dm_req
);
    /*==================== + ====================*/
    /*                (0) Declare                */
    /*==================== + ====================*/
    /*===== (1) Fetch Stage =====*/
    reg [31:0] IF_pc;
    reg        iterate;
    wire[31:0] next_pc;
    wire[31:0] pc_plus4;
    wire       use_JBU;
    wire[31:0] JBU_op0;
    wire[31:0] pc_JB;
    /*===== (2) Decode Stage =====*/
    wire       stall_ID;
    wire       stall_fwd;
    reg [31:0] ID_pc;
    reg [31:0] ID_isa;
    wire [6:0] ID_opcode;
    wire [2:0] ID_func3;
    wire [1:0] ID_csr_type;
    wire [1:0] ID_func7;
    wire       ID_func5;
    wire [4:0] ID_rs1_addr;
    wire [4:0] ID_rs2_addr;
    wire [4:0] ID_rd_addr;
    wire[31:0] ID_rs1_Idata;
    wire[31:0] ID_rs2_Idata;
    wire[31:0] ID_rd_Idata;
    wire[31:0] ID_rs1_Fdata;
    wire[31:0] ID_rs2_Fdata;
    wire[31:0] ID_imm_data;
    wire[31:0] ID_csr_data;
    wire[31:0] ID_rs1_data;
    wire[31:0] ID_rs2_data;
    wire[31:0] ID_rs3_data;
    wire[31:0] ID_rs4_data;
    wire      ID_valid;
    wire      ID_branch;
    wire      ID_jump;
    wire      ID_jalr;
    wire      ID_csr;
    wire      ID_mac;
    wire      ID_load;
    wire      ID_store;
    wire      ID_arthF;
    wire      ID_IoF_Rg1;
    wire      ID_IoF_Rg2;
    wire      ID_IoF_Rgd;
    wire[1:0] ID_mux_op0;
    wire[1:0] ID_mux_op1;
    wire[3:0] ID_mux_opr;
    wire[1:0] ID_mux_xpu;
    wire[1:0] ID_dm_mask;
    wire      ID_dm_sign;
    wire      ID_mux_PoM;
    wire      ID_Ird_en;
    wire      ID_Frd_en;
    wire      ID_fwd_WB1;
    wire      ID_fwd_WB2;
    wire      ID_fwd_WB3;
    wire[1:0] ID_ex_fwd1;
    wire[1:0] ID_ex_fwd2;
    wire[1:0] ID_ex_fwd3;

    /*===== (3) Execute Stage =====*/
    wire stall_EX;
    wire stall_EX1;
    wire stall_EX2;
    wire stall_EX3;
    reg[31:0] EX_rs1_data;
    reg[31:0] EX_rs2_data;
    reg[31:0] EX_rs3_data;
    reg[31:0] EX_rs4_data;

    reg       EX_valid;
    reg       EX_branch;
    reg       EX_jump;
    reg       EX_jalr;
    reg       EX_mac;
    reg       EX_load;
    reg       EX_store;
    reg       EX_arthF;

    reg       EX_IoF_Rgd;
    reg [1:0] EX_mux_op0;
    reg [1:0] EX_mux_op1;
    reg [3:0] EX_mux_opr;
    reg [1:0] EX_mux_xpu;
    reg [1:0] EX_dm_mask;
    reg       EX_dm_sign;
    reg       EX_mux_PoM;
    reg       EX_Ird_en;
    reg       EX_Frd_en;
    reg [4:0] EX_rd_addr;
    reg [1:0] EX_ex_fwd1;
    reg [1:0] EX_ex_fwd2;
    reg [1:0] EX_ex_fwd3;

    reg[31:0] EX_rs1_fwd;
    reg[31:0] EX_rs2_fwd;
    reg[31:0] EX_rd_fwd;
    reg[31:0] EX_alu_op0;
    reg[31:0] EX_alu_op1;
    reg[31:0] EX_xpu_data;
    reg[31:0] EX_reg_data;
    wire[31:0] EX_fpu_data;
    wire[31:0] EX_mpu_data;
    wire[31:0] EX_alu_data;

    /*===== (4) Memory Stage =====*/
    wire      stall_MEM;
    reg       MEM_valid;
    reg       MEM_Ird_en;
    reg       MEM_Frd_en;
    reg       MEM_IoF_Rgd;
    reg [4:0] MEM_rd_addr;
    reg[31:0] MEM_xpu_data;
    reg[31:0] MEM_reg_data;
    reg [1:0] MEM_dm_mask;
    reg [1:0] MEM_dm_ofst;
    reg       MEM_dm_sign;
    reg       MEM_mux_PoM;    
    /*===== (5) White-Back Stage =====*/
   
    reg        WB_valid;
    reg        WB_Ird_en;
    reg        WB_Frd_en;
    reg        WB_IoF_Rgd;
    reg  [4:0] WB_rd_addr;
    reg [31:0] WB_xpu_data;
    reg [31:0] WB_dmRow_data;
    wire[31:0] WB_dm_data;
    wire[31:0] WB_data;
    reg  [1:0] WB_dm_mask;
    reg  [1:0] WB_dm_ofst;
    reg        WB_dm_sign;
    reg        WB_mux_PoM;
 //   reg [31:0] EX_pc;
 //   reg [31:0] MEM_pc;
 //   reg [31:0] WB_pc;
    //+========================================= + =========================================+//
    //+========================================= + =========================================+//
    /*==================== + ====================*/
    /*              (1) Fetch Stage              */
    /*==================== + ====================*/
    assign stall_IF = stall_ID;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            IF_pc   <= 32'b0;
            iterate <= 1'b0;
        end
        else begin
            if (!stall_ID) begin
                if (im_valid || use_JBU)
                    IF_pc <= next_pc;
                else
                    IF_pc <= IF_pc;
            end
            else begin
                IF_pc <= IF_pc;
            end

            
        end
    end

    assign next_pc = (use_JBU) ? pc_JB : pc_plus4;
    assign pc_plus4 = IF_pc + 4;
    assign im_addr  = IF_pc;
    assign flush_IF = ID_jump || (EX_branch && EX_alu_data[0]);

    /*==================== + ====================*/
    /*              (2) Decode Stage             */
    /*==================== + ====================*/
    assign stall_ID  = stall_EX || stall_fwd;
    assign stall_fwd = (EX_load && (ID_ex_fwd1 == 2'b11 || ID_ex_fwd2 == 2'b11 || ID_ex_fwd3 == 2'b11)); 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ID_pc  <= 32'b0;
            ID_isa <= 32'b0;
        end
        else begin
            if (!stall_ID) begin
                if (im_valid) begin
                    ID_pc  <= IF_pc;
                    ID_isa <= im_read_data;
                end
                else begin
                    ID_pc  <= 32'b0;
                    ID_isa <= 32'b0;
                end
            end
            else begin
                ID_pc  <= ID_pc;
                ID_isa <= ID_isa;
            end
        end
    end

    Decoder Decoder (
        .isa       (ID_isa),
        .opcode    (ID_opcode),
        .func3     (ID_func3),
        .func5     (ID_func5),
        .func7     (ID_func7),
        .rd_addr   (ID_rd_addr),
        .rs1_addr  (ID_rs1_addr),
        .rs2_addr  (ID_rs2_addr),
        .csr       (ID_csr_type)
    );
    Controller Controller (
        .opcode      (ID_opcode),
        .func3       (ID_func3),
        .ID_rs1_addr (ID_rs1_addr),
        .ID_rs2_addr (ID_rs2_addr),
        .ID_rd_addr  (ID_rd_addr),
        .func7       (ID_func7),
        .func5       (ID_func5),

        .EX_rd_addr  (EX_rd_addr),
        .MEM_rd_addr (MEM_rd_addr),
        .WB_rd_addr  (WB_rd_addr),

        .EX_IoF_Rgd  (EX_IoF_Rgd),
        .MEM_IoF_Rgd (MEM_IoF_Rgd),
        .WB_IoF_Rgd  (WB_IoF_Rgd),
    
        .EX_Ird_en   (EX_Ird_en),
        .MEM_Ird_en  (MEM_Ird_en),
        .WB_Ird_en   (WB_Ird_en),
        .EX_Frd_en   (EX_Frd_en),
        .MEM_Frd_en  (MEM_Frd_en),
        .WB_Frd_en   (WB_Frd_en),

        .ID_valid    (ID_valid),
        .ID_branch   (ID_branch),
        .ID_jump     (ID_jump),
        .ID_jalr     (ID_jalr),
        .ID_load     (ID_load),
        .ID_store    (ID_store),
        .ID_mac      (ID_mac),
        .ID_csr      (ID_csr),
        .ID_arthF    (ID_arthF),
    
        .ID_IoF_Rg1   (ID_IoF_Rg1),
        .ID_IoF_Rg2   (ID_IoF_Rg2),
        .ID_IoF_Rgd   (ID_IoF_Rgd),
    
        .ID_mux_op0   (ID_mux_op0),
        .ID_mux_op1   (ID_mux_op1),
        .ID_mux_opr   (ID_mux_opr),
        .ID_mux_xpu   (ID_mux_xpu),
    
        .ID_dm_mask   (ID_dm_mask), 
        .ID_dm_sign   (ID_dm_sign),
    
        .ID_Frd_en   (ID_Frd_en),
        .ID_Ird_en   (ID_Ird_en),
        .ID_mux_PoM  (ID_mux_PoM),

        .ID_fwd_WB1  (ID_fwd_WB1),
        .ID_fwd_WB2  (ID_fwd_WB2),
        .ID_fwd_WB3  (ID_fwd_WB3),
        .ID_ex_fwd1  (ID_ex_fwd1),
        .ID_ex_fwd2  (ID_ex_fwd2),
        .ID_ex_fwd3  (ID_ex_fwd3)
    );
    IntRegFile IntRegFile (
        .clk          (clk),
        .rst          (rst),
        .rs1_addr     (ID_rs1_addr),
        .rs2_addr     (ID_rs2_addr),
        .rd_addr_out  (ID_rd_addr),
        .rd_addr_in   (WB_rd_addr),
        .rs1_data     (ID_rs1_Idata),
        .rs2_data     (ID_rs2_Idata),
        .rd_data_out  (ID_rd_Idata),
        .rd_data_in   (WB_data),
        .enable       (WB_Ird_en)
    );
    FPRegFile FPRegFile (
        .clk          (clk),
        .rst          (rst),
        .rs1_addr     (ID_rs1_addr),
        .rs2_addr     (ID_rs2_addr),
        .rd_addr      (WB_rd_addr),
        .rs1_data     (ID_rs1_Fdata),
        .rs2_data     (ID_rs2_Fdata),
        .rd_data      (WB_data),
        .enable       (WB_Frd_en)
    );
    CSRegFile CSRegFile (
        .clk       (clk),
        .rst       (rst),
        .finish    (WB_valid),
        .csr_type  (ID_csr_type),
        .csr_data  (ID_csr_data)
    );
    ImmExtend ImmExtend (
        .inst      (ID_isa),
        .imm_data  (ID_imm_data)
    );

    wire[31:0] ID_rs1_IoF_data;
    wire[31:0] ID_rs2_IoF_data;
    wire[31:0] ID_rd_fwd;

    assign ID_rs1_IoF_data = (ID_IoF_Rg1) ? ID_rs1_Fdata : ID_rs1_Idata;
    assign ID_rs2_IoF_data = (ID_IoF_Rg2) ? ID_rs2_Fdata : ID_rs2_Idata;

    assign ID_rd_fwd  = (ID_fwd_WB3) ? WB_data : ID_rd_Idata;

    assign ID_rs1_data = (ID_fwd_WB1) ? WB_data : ID_rs1_IoF_data;
    assign ID_rs2_data = (ID_fwd_WB2) ? WB_data : ID_rs2_IoF_data;
    assign ID_rs3_data = (ID_mac) ? ID_rd_fwd   : ID_imm_data;
    assign ID_rs4_data = (ID_csr) ? ID_csr_data : ID_pc;


    /*==================== + ====================*/
    /*             (3) Execute Stage             */
    /*==================== + ====================*/
    wire[31:0] mac_opA;
    wire[31:0] mac_opB;
    wire       mac_valid;
    wire       FPU_valid;
    assign stall_EX1 = (EX_mac) && (!mac_valid);    // Mac
    assign stall_EX2 = (EX_arthF) && (!FPU_valid);  // FPU
    assign stall_EX3 = dm_req && dm_write;
    assign stall_EX  = stall_EX1 || stall_EX2 || stall_EX3 || stall_MEM;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
//            EX_pc       <= 32'b0;
            EX_rs1_data <= 32'b0;
            EX_rs2_data <= 32'b0;
            EX_rs3_data <= 32'b0;
            EX_rs4_data <= 32'b0;
            EX_rd_addr  <= 5'b0;
            EX_valid    <= 1'b0;
            EX_branch   <= 1'b0;
            EX_jump     <= 1'b0;
            EX_jalr     <= 1'b0;
            EX_mac      <= 1'b0;
            EX_load     <= 1'b0;
            EX_store    <= 1'b0;
            EX_arthF    <= 1'b0;
            EX_IoF_Rgd  <= 1'b0;
            EX_mux_op0  <= 2'b00;
            EX_mux_op1  <= 2'b00;
            EX_mux_opr  <= 4'b0000;
            EX_mux_xpu  <= 2'b00;
            EX_ex_fwd1  <= 2'b00;
            EX_ex_fwd2  <= 2'b00;
            EX_ex_fwd3  <= 2'b00;
            EX_dm_mask  <= 2'b00;
            EX_dm_sign  <= 1'b0;
            EX_mux_PoM  <= 1'b0;
            EX_Ird_en   <= 1'b0;
            EX_Frd_en   <= 1'b0;
        end
        else begin
            if (!stall_EX) begin
                if (!stall_fwd) begin
//                    EX_pc       <= ID_pc;
                    EX_rs1_data <= ID_rs1_data;
                    EX_rs2_data <= ID_rs2_data;
                    EX_rs3_data <= ID_rs3_data;
                    EX_rs4_data <= ID_rs4_data;
                    EX_rd_addr  <= ID_rd_addr;

                    EX_valid    <= ID_valid;
                    EX_branch   <= ID_branch;
                    EX_jump     <= ID_jump;
                    EX_jalr     <= ID_jalr;
                    EX_mac      <= ID_mac;
                    EX_load     <= ID_load;
                    EX_store    <= ID_store;
                    EX_arthF    <= ID_arthF;

                    EX_IoF_Rgd  <= ID_IoF_Rgd;
                    EX_mux_op0  <= ID_mux_op0;
                    EX_mux_op1  <= ID_mux_op1;
                    EX_mux_opr  <= ID_mux_opr;
                    EX_mux_xpu  <= ID_mux_xpu;

                    EX_ex_fwd1  <= ID_ex_fwd1;
                    EX_ex_fwd2  <= ID_ex_fwd2;
                    EX_ex_fwd3  <= ID_ex_fwd3;

                    EX_dm_mask  <= ID_dm_mask;
                    EX_dm_sign  <= ID_dm_sign;

                    EX_mux_PoM  <= ID_mux_PoM;
                    EX_Ird_en   <= ID_Ird_en;
                    EX_Frd_en   <= ID_Frd_en;
                end
                else begin
                    // NOP
//                    EX_pc       <= 32'b0;
                    EX_rs1_data <= 32'b0;
                    EX_rs2_data <= 32'b0;
                    EX_rs3_data <= 32'b0;
                    EX_rs4_data <= 32'b0;
                    EX_rd_addr  <= 5'b0;

                    EX_valid    <= 1'b0;
                    EX_branch   <= 1'b0;
                    EX_jump     <= 1'b0;
                    EX_jalr     <= 1'b0;
                    EX_mac      <= 1'b0;
                    EX_load     <= 1'b0;
                    EX_store    <= 1'b0;
                    EX_arthF    <= 1'b0;

                    EX_IoF_Rgd  <= 1'b0;
                    EX_mux_op0  <= 2'b00;
                    EX_mux_op1  <= 2'b00;
                    EX_mux_opr  <= 4'b0000;
                    EX_mux_xpu  <= 2'b00;

                    EX_ex_fwd1  <= 2'b00;
                    EX_ex_fwd2  <= 2'b00;
                    EX_ex_fwd3  <= 2'b00;

                    EX_dm_mask  <= 2'b00;
                    EX_dm_sign  <= 1'b0;

                    EX_mux_PoM  <= 1'b1;
                    EX_Ird_en   <= 1'b0;
                    EX_Frd_en   <= 1'b0;
                end
            end       
        end
    end

    Mac Mac (
        .clk       (clk),
        .rst       (rst),
        .mac_op0   (EX_mpu_data),
        .mac_op1   (EX_rd_fwd),
        .reg_op0   (mac_opA),
        .reg_op1   (mac_opB),
        .mac_req   (EX_mac),
        .mac_stall (stall_MEM),
        .mac_valid (mac_valid)
    );


    always @(*) begin
        if (EX_ex_fwd1 == 2'b11)
            EX_rs1_fwd = MEM_xpu_data;
        else if (EX_ex_fwd1 == 2'b10)
            EX_rs1_fwd = WB_data;
        else
            EX_rs1_fwd = EX_rs1_data;
        
        if (EX_ex_fwd2 == 2'b11)
            EX_rs2_fwd = MEM_xpu_data;
        else if (EX_ex_fwd2 == 2'b10)
            EX_rs2_fwd = WB_data;
        else
            EX_rs2_fwd = EX_rs2_data;

        if (EX_ex_fwd3 == 2'b11)
            EX_rd_fwd = MEM_xpu_data;
        else if (EX_ex_fwd3 == 2'b10)
            EX_rd_fwd = WB_data;
        else
            EX_rd_fwd = EX_rs3_data;

        case (EX_mux_op0)
            2'b11:  EX_alu_op0 = EX_rs1_fwd;
            2'b10:  EX_alu_op0 = EX_rs4_data;
            2'b01:  EX_alu_op0 = mac_opA;
            2'b00:  EX_alu_op0 = 32'b0;
            default:EX_alu_op0 = 32'b0;
        endcase

        case (EX_mux_op1)
            2'b11:  EX_alu_op1 = EX_rs2_fwd;
            2'b10:  EX_alu_op1 = EX_rs3_data;
            2'b01:  EX_alu_op1 = mac_opB;
            2'b00:  EX_alu_op1 = 32'd4;
            default:EX_alu_op1 = 32'd4;
        endcase
 
        EX_reg_data = EX_rs2_fwd;
        case (EX_mux_xpu)
            2'b11:  EX_xpu_data = EX_rs4_data;  // CSR
            2'b10:  EX_xpu_data = EX_fpu_data;  // FPU
            2'b01:  EX_xpu_data = EX_mpu_data;  // MPU
            2'b00:  EX_xpu_data = EX_alu_data;  // ALU
            default:EX_xpu_data = 32'b0;
        endcase
    end

    ALU ALU (
        .operand_A   (EX_alu_op0),
        .operand_B   (EX_alu_op1),
        .operator    (EX_mux_opr),
        .result      (EX_alu_data)
    );
    MPU MPU (
        .operand_A   (EX_rs1_fwd),
        .operand_B   (EX_rs2_fwd),
        .op          (EX_mux_opr),
        .result      (EX_mpu_data)
    );
    wire[31:0] EX_fpu_add;
    FPU_Adder FPU_Adder (
        .clk        (clk),
        .rst        (rst),
        .operand_A  (EX_rs1_fwd),
        .operand_B  (EX_rs2_fwd),
        .operator   (EX_mux_opr),
        .FPU_req    (EX_arthF),
        .FPU_stall  (stall_MEM),
        .FPU_valid  (FPU_valid),
        .result     (EX_fpu_add)
    );
    wire[31:0] EX_fpu_com;
    FPU_Comparator FPU_Comparator (
        .operand_A   (EX_rs1_fwd),
        .operand_B   (EX_rs2_fwd),
        .operator    (EX_mux_opr),
        .result      (EX_fpu_com)
    );
    assign EX_fpu_data = (EX_mux_opr[1]) ? EX_fpu_add : EX_fpu_com;


    assign use_JBU = (EX_jump) || ((EX_branch) && (EX_alu_data[0]));
    assign JBU_op0 = (EX_jalr) ? EX_rs1_fwd : EX_rs4_data;  
    JBUnit JBUnit (
        .JB_type    (EX_jalr),
        .imm        (EX_rs3_data),
        .pc_or_rs1  (JBU_op0),
        .result_pc  (pc_JB)
    );

    wire[1:0] dm_ofst;
    assign dm_addr = EX_alu_data;
    assign dm_req  = (EX_load) || (EX_store);
    assign dm_WEB  = EX_load;
    assign dm_ofst = EX_alu_data[1:0];

    /*==================== + ====================*/
    /*             (4) Memory Stage              */
    /*==================== + ====================*/
    assign stall_MEM = dm_busy;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
  //          MEM_pc       <= 32'b0;
            MEM_xpu_data <= 32'b0;
            MEM_reg_data <= 32'b0;
            MEM_valid    <= 1'b0;
            MEM_rd_addr  <= 5'b00000;
            MEM_Ird_en   <= 1'b0;
            MEM_Frd_en   <= 1'b0;
            MEM_IoF_Rgd  <= 1'b0;
            MEM_mux_PoM  <= 1'b0;
            MEM_dm_mask  <= 2'b00;
            MEM_dm_sign  <= 1'b0;
            MEM_dm_ofst  <= 2'b00;
        end
        else begin
            if (!stall_MEM) begin
                if (stall_EX) begin
 //                   MEM_pc       <= MEM_pc;
                    MEM_xpu_data <= MEM_xpu_data;
                    MEM_reg_data <= MEM_reg_data;
                    MEM_valid    <= MEM_valid;
                    MEM_rd_addr  <= MEM_rd_addr;
                    MEM_Ird_en   <= MEM_Ird_en;
                    MEM_Frd_en   <= MEM_Frd_en;
                    MEM_IoF_Rgd  <= MEM_IoF_Rgd;
                    MEM_mux_PoM  <= MEM_mux_PoM;
                    MEM_dm_mask  <= MEM_dm_mask;
                    MEM_dm_sign  <= MEM_dm_sign;
                    MEM_dm_ofst  <= MEM_dm_ofst;
                end                
                else begin
 //                   MEM_pc       <= EX_pc;
                    MEM_xpu_data <= EX_xpu_data;
                    MEM_reg_data <= EX_reg_data;
                    MEM_dm_mask  <= EX_dm_mask;
                    MEM_dm_sign  <= EX_dm_sign;
                    MEM_dm_ofst  <= dm_ofst;
                    MEM_valid    <= EX_valid;
                    MEM_rd_addr  <= EX_rd_addr;
                    MEM_Ird_en   <= EX_Ird_en;
                    MEM_Frd_en   <= EX_Frd_en;
                    MEM_IoF_Rgd  <= EX_IoF_Rgd;
                    MEM_mux_PoM  <= EX_mux_PoM;
                end
            end
        end
    end

    StoreFilter StoreFilter (
        .data_in     (MEM_reg_data),
        .addr        (MEM_dm_ofst),
        .lengh       (MEM_dm_mask),
	.mask        (dm_bit_en),
        .data_out    (dm_write_data)
    );

    /*==================== + ====================*/
    /*           (5) White-Back Stage            */
    /*==================== + ====================*/
    always @(posedge clk or posedge rst) begin
        if (rst) begin
   //         WB_pc         <= 32'b0;
            WB_valid      <= 1'b0;
            WB_Ird_en     <= 1'b0;
            WB_Frd_en     <= 1'b0;
            WB_IoF_Rgd    <= 1'b0;
            WB_rd_addr    <= 5'b0;
            WB_xpu_data   <= 32'b0;
            WB_dmRow_data <= 32'b0;
            WB_dm_mask    <= 2'b0;
            WB_dm_ofst    <= 2'b0;
            WB_dm_sign    <= 1'b0;
            WB_mux_PoM    <= 1'b0;
        end
        else begin
            if (!dm_busy) begin
                if (stall_EX) begin
 //                   WB_pc         <= WB_pc;
                    WB_valid      <= 1'b0;
                    WB_IoF_Rgd    <= WB_IoF_Rgd;
                    WB_Ird_en     <= WB_Ird_en;
                    WB_Frd_en     <= WB_Frd_en;
                    WB_rd_addr    <= WB_rd_addr;
                    WB_xpu_data   <= WB_xpu_data;
                    WB_dmRow_data <= WB_dmRow_data;
                    WB_dm_mask    <= WB_dm_mask;
                    WB_dm_ofst    <= WB_dm_ofst;
                    WB_dm_sign    <= WB_dm_sign;
                    WB_mux_PoM    <= WB_mux_PoM;
                end
                else begin
//                    WB_pc         <= MEM_pc;
                    WB_valid      <= MEM_valid;
                    WB_IoF_Rgd    <= MEM_IoF_Rgd;
                    WB_Ird_en     <= MEM_Ird_en;
                    WB_Frd_en     <= MEM_Frd_en;
                    WB_rd_addr    <= MEM_rd_addr;
                    WB_xpu_data   <= MEM_xpu_data;
                    WB_dmRow_data <= dm_read_data;
                    WB_dm_mask    <= MEM_dm_mask;
                    WB_dm_ofst    <= MEM_dm_ofst;
                    WB_dm_sign    <= MEM_dm_sign;
                    WB_mux_PoM    <= MEM_mux_PoM;
                end
            end
            else begin
  //              WB_pc         <= WB_pc;
                WB_valid      <= 1'b0;
                WB_IoF_Rgd    <= WB_IoF_Rgd;
                WB_Ird_en     <= WB_Ird_en;
                WB_Frd_en     <= WB_Frd_en;
                WB_rd_addr    <= WB_rd_addr;
                WB_xpu_data   <= WB_xpu_data;
                WB_dmRow_data <= WB_dmRow_data;
                WB_dm_mask    <= WB_dm_mask;
                WB_dm_ofst    <= WB_dm_ofst;
                WB_dm_sign    <= WB_dm_sign;
                WB_mux_PoM    <= WB_mux_PoM;
            end
        end
    end
    LoadFilter LoadFilter (
        .data_in   (WB_dmRow_data),
        .addr      (WB_dm_ofst),
        .lengh     (WB_dm_mask),
        .sign      (WB_dm_sign),
        .data_out  (WB_dm_data)
    );

    assign WB_data = (WB_mux_PoM) ? WB_xpu_data : WB_dm_data;    
endmodule
