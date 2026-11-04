`include "Parameter.v"
module MPU (
    input [31:0] operand_A,
    input [31:0] operand_B,
    input [3:0]  op,
    output[31:0] result
);  
    wire [1:0] operator;
    wire[31:0] abs_a;
    wire[31:0] abs_b;
    wire[63:0] product;
    wire[63:0] product_2;

    assign operator = op[1:0];

    assign abs_a = (operator != `MULHU) ? (operand_A[31]) ? ~operand_A + 1 : operand_A : operand_A;
    assign abs_b = (operator[1] == 1'b0) ? (operand_B[31]) ? ~operand_B + 1 : operand_B : operand_B;

    assign product = abs_a * abs_b;
    
    assign product_2 = (operator[1] == 1'b0) ? (operand_A[31] ^ operand_B[31]) ? ~product + 1 : product :
                       (operator == `MULHSU) ? (operand_A[31])                 ? ~product + 1 : product : product;

    assign result = (operator == `MUL) ? product_2[31:0] : product_2[63:32];
endmodule
