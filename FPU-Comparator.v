module FPU_Comparator (
    input     [31:0] operand_A,
    input     [31:0] operand_B,
    input      [3:0] operator,
    output reg[31:0] result
);
    wire       sign_A;
    wire       sign_B; 
    wire[30:0] mag_A; 
    wire[30:0] mag_B;

    assign sign_A = operand_A[31];
    assign sign_B = operand_B[31];
    assign mag_A  = operand_A[30:0];
    assign mag_B  = operand_B[30:0];

    reg A_less_than_B;

    always @(*) begin
        if (sign_A != sign_B) begin
            A_less_than_B = sign_A; 
        end
        else begin
            if (sign_A == 1'b0) 
                A_less_than_B = (mag_A < mag_B) ? 1'b1 : 1'b0;
            else 
                A_less_than_B = (mag_A > mag_B) ? 1'b1 : 1'b0;
        end
        
        
        if (operator == 4'b0000) 
            result = (A_less_than_B) ? operand_A : operand_B;
        else 
            result = (A_less_than_B) ? operand_B : operand_A;
    end
endmodule