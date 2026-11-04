module JBUnit (
    input        JB_type,
    input [31:0] imm,
    input [31:0] pc_or_rs1,
    output[31:0] result_pc
);
    assign result_pc = (JB_type) ? (pc_or_rs1 + imm) & 32'hfffffffe : pc_or_rs1 + imm;
endmodule