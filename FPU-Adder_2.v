`include "Parameter.v"
`include "FPU-Normalize.v"
module FPU_Adder (
    input clk,
    input rst,
    input[31:0] operand_A,
    input[31:0] operand_B,
    input [3:0] operator,

    input       FPU_req,
    input       FPU_stall,
    output reg  FPU_valid,
    output[31:0]result
);
    reg FPU_cal;
    reg FPU_req_fsm;
    //*================================ + ===============================*//
    wire [7:0] expo_A;
    wire [7:0] expo_B;
    wire[22:0] frac_A;
    wire[22:0] frac_B;
    reg[31:0] operand_L;
    reg[31:0] operand_S;
    reg       is_a_bigger;
   
    assign expo_A = operand_A[30:23];
    assign expo_B = operand_B[30:23];
    assign frac_A = operand_A[22:0];
    assign frac_B = operand_B[22:0];

    always @(*) begin
        if (expo_A > expo_B) begin
            is_a_bigger = 1'b1;
            operand_L   = operand_A;
            operand_S   = operand_B;
        end
        else if (expo_A < expo_B) begin
            is_a_bigger = 1'b0;
            operand_L   = operand_B;
            operand_S   = operand_A;
        end
        else begin
            is_a_bigger = (frac_A < frac_B) ? 1'b0 : 1'b1;
            operand_L   = (frac_A < frac_B) ? operand_B : operand_A;
            operand_S   = (frac_A < frac_B) ? operand_A : operand_B;
        end
    end

    //*================================ + ===============================*//
    reg[31:0] operand_L_reg;
    reg[31:0] operand_S_reg;
    reg       is_a_bigger_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            operand_L_reg   <= 32'b0;
            operand_S_reg   <= 32'b0;
            is_a_bigger_reg <= 1'b0;
        end
        else begin
            if (FPU_req_fsm) begin
                operand_L_reg   <= operand_L;
                operand_S_reg   <= operand_S;
                is_a_bigger_reg <= is_a_bigger;
            end
        end
    end

    reg[23:0] Mantissa_L;
    reg[23:0] Mantissa_S;
    reg [7:0] expo_L;
    reg [7:0] expo_S;
    reg       sign_L;
    reg       sign_S;
    always @(*) begin
        Mantissa_L = {1'b1, operand_L_reg[22:0]};
        Mantissa_S = {1'b1, operand_S_reg[22:0]};  

        expo_L = operand_L_reg[30:23];
        expo_S = operand_S_reg[30:23];

        sign_L = operand_L_reg[31];
        sign_S = operand_S_reg[31];
    end

    reg [7:0] set_Rshift;
    reg[31:0] set_op_L2;
    reg[31:0] set_op_S1;
    reg[31:0] set_op_S2;

    always @(*) begin
        set_Rshift = expo_L - expo_S;
        set_op_L2 = {1'b0, Mantissa_L, {7{1'b0}}};
        set_op_S1 = {1'b0, Mantissa_S, {7{1'b0}}};
        set_op_S2 = set_op_S1 >> set_Rshift;    
    end

    reg[31:0] cal_frac;
    reg [7:0] cal_expo;
    reg       cal_sign;

    always @(*) begin
        /* SUB */
        if (operator == 4'b0011) begin
            if (sign_L == sign_S) begin
                cal_frac = set_op_L2 - set_op_S2;
                cal_expo = expo_L;
                cal_sign = (is_a_bigger_reg) ? sign_L : ~sign_L;
            end
            else begin
                cal_frac = set_op_L2 + set_op_S2;
                cal_expo = expo_L;
                cal_sign = (is_a_bigger_reg) ? sign_L : ~sign_L;
            end
        end
        /* ADD */
        else begin
            if (sign_L == sign_S) begin
                cal_frac = set_op_L2 + set_op_S2;
                cal_expo = expo_L;
                cal_sign = sign_L;
            end
            else begin
                cal_frac = set_op_L2 - set_op_S2;
                cal_expo = expo_L;
                cal_sign = sign_L;
            end
        end
    end

    //*================================ + ===============================*//
    reg[31:0] reg_cal_frac;
    reg [7:0] reg_cal_expo;
    reg       reg_cal_sign;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_cal_sign <= 1'b0;
            reg_cal_expo <= 8'b0;
            reg_cal_frac <= 32'b0;
        end
        else begin
            if (FPU_cal) begin
                reg_cal_sign <= cal_sign;
                reg_cal_expo <= cal_expo;
                reg_cal_frac <= cal_frac;
            end
        end
    end

    wire[4:0] nor1_left;
    Normalize_LShift Normalize_LShift (
        .in     (reg_cal_frac),
        .out    (nor1_left)
    );

    reg[31:0] nor1_frac;
    reg [7:0] nor1_expo;
    reg       set_G_bit;
    reg       set_R_bit;
    reg       set_S_bit;
    reg       set_S1_bit;
    reg       set_S2_bit;
    reg [2:0] set_GRS;
    always @(*) begin
        if (reg_cal_frac[31:30] == 2'b11 || reg_cal_frac[31:30] == 2'b10) begin
            nor1_expo = reg_cal_expo + 8'd1;
            nor1_frac = reg_cal_frac >> 1;
            set_S1_bit = reg_cal_frac[0];
        end

        else if (reg_cal_frac[31:30] == 2'b00) begin
            if (reg_cal_expo != 8'b0) begin
                if (reg_cal_expo >= nor1_left) begin
                    nor1_frac = reg_cal_frac << nor1_left;
                    nor1_expo = reg_cal_expo  - nor1_left;
                end
                else begin
                    nor1_frac = reg_cal_frac << reg_cal_expo;
                    nor1_expo = 8'b0;
                end
            end
            else begin
                nor1_frac = reg_cal_frac;
                nor1_expo = reg_cal_expo;
            end
            set_S1_bit = 1'b0;
        end

        else begin
            nor1_frac = reg_cal_frac;
            nor1_expo = reg_cal_expo;
            set_S1_bit = 1'b0;
        end


        set_G_bit = nor1_frac[6];
        set_R_bit = nor1_frac[5];
        set_S2_bit = |nor1_frac[4:0];
        set_S_bit  = set_S1_bit || set_S2_bit;
        set_GRS = {set_G_bit, set_R_bit, set_S_bit};
    end

    reg[24:0] round_frac;
    always @(*) begin
        case (set_GRS)
            3'b000: round_frac = nor1_frac[31:7];
            3'b001: round_frac = nor1_frac[31:7];
            3'b010: round_frac = nor1_frac[31:7];
            3'b011: round_frac = nor1_frac[31:7];
            3'b100: round_frac = (nor1_frac[7]) ? nor1_frac[31:7] + 25'd1 : nor1_frac[31:7];
            3'b101: round_frac = nor1_frac[31:7] + 25'd1;
            3'b110: round_frac = nor1_frac[31:7] + 25'd1; 
            3'b111: round_frac = nor1_frac[31:7] + 25'd1;
            default: round_frac = nor1_frac[31:7];
        endcase
    end

    reg[24:0] nor2_frac;
    reg [7:0] nor2_expo;
    always @(*) begin
        if (round_frac[24]) begin
            nor2_expo = nor1_expo + 8'd1;
            nor2_frac = round_frac >> 1;
        end
        else begin
            nor2_expo = nor1_expo;
            nor2_frac = round_frac;
        end
    end

    assign result = {reg_cal_sign, nor2_expo, nor2_frac[22:0]};


    //*================================ + ===============================*//
    reg[1:0] state;
    reg[1:0] nextstate;
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= `FP_IDLE;
        else
            state <= nextstate;
    end
    always @(*) begin
        case (state) 
            `FP_IDLE: begin
                FPU_valid = 1'b0;
                FPU_cal   = 1'b0;
                FPU_req_fsm = (FPU_req) ? 1'b1 : 1'b0;
                nextstate = (FPU_req) ? `FP_CAL : `FP_IDLE;
            end
            `FP_CAL: begin
                FPU_valid = 1'b0;                
                FPU_cal   = 1'b1;
                FPU_req_fsm = 1'b0;
                nextstate = `FP_ROUND; 
            end
            `FP_ROUND: begin
                FPU_valid = 1'b1;
                FPU_cal   = 1'b0;
                FPU_req_fsm = 1'b0;
                nextstate = (FPU_stall) ? `FP_ROUND : `FP_IDLE;
            end
            default: begin
                FPU_valid = 1'b0;
                FPU_cal   = 1'b0;
                FPU_req_fsm = 1'b0;
                nextstate = `FP_IDLE;
            end
        endcase
    end
endmodule
