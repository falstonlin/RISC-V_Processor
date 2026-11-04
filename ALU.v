`include "Parameter.v"
module ALU (
    input     [31:0] operand_A,
    input     [31:0] operand_B,
    input     [3:0]  operator,
    output reg[31:0] result
);
    always @(*) begin
        case (operator)
            `ADD   : result = operand_A + operand_B;
            `SUB   : result = operand_A - operand_B;
            `SLL   : result = operand_A << operand_B[4:0];
            `SLT   : result = ($signed(operand_A) < $signed(operand_B)) ?  32'd1 : 32'd0;
            `SLTU  : result = (operand_A < operand_B) ? 32'd1 : 32'd0;
            `XOR   : result = operand_A ^ operand_B;
            `SRL   : result = $unsigned(operand_A) >> operand_B[4:0];
            `SRA   : result = $signed(operand_A) >>> operand_B[4:0];
            `OR    : result = operand_A | operand_B;
            `AND   : result = operand_A & operand_B;
            `BEQ   : result = (operand_A == operand_B) ? 32'd1 : 32'd0;
            `BNE   : result = (operand_A != operand_B) ? 32'd1 : 32'd0;
            `BLT   : result = ($signed(operand_A)  < $signed(operand_B)) ?  32'd1 : 32'd0;
            `BGE   : result = ($signed(operand_A) >= $signed(operand_B)) ?  32'd1 : 32'd0;
            `BLTU  : result = (operand_A  < operand_B) ? 32'd1 : 32'd0;
            `BGEU  : result = (operand_A >= operand_B) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end
endmodule