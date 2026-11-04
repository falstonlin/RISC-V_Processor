`include "Parameter.v"
module ImmExtend (
    input     [31:0] inst,
    output reg[31:0] imm_data
);
    wire[6:0] op;
    wire[2:0] f3;
    assign op = inst[6:0];
    assign f3 = inst[14:12];
    always @(*) begin
        case (op)
            `LOAD_I  : imm_data = {{20{inst[31]}}, inst[31:20]};
            `LOAD_F  : imm_data = {{20{inst[31]}}, inst[31:20]};
            `JALR    : imm_data = {{20{inst[31]}}, inst[31:20]};
            `ARTH_I  : imm_data = (f3 == 3'b001 || f3 == 3'b101) ? {{27{1'b0}}, inst[24:20]} : {{20{inst[31]}}, inst[31:20]};
            `STORE_I : imm_data = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            `STORE_F : imm_data = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            `LUI     : imm_data = {inst[31:12], {12{1'b0}}};
            `AUIPC   : imm_data = {inst[31:12], {12{1'b0}}};
            `JAL     : imm_data = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            `BRANCH  : imm_data = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            default  : imm_data = 32'b0;
        endcase
    end
endmodule