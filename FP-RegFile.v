module FPRegFile (
    input        clk,
    input        rst,
    input  [4:0] rs1_addr,
    input  [4:0] rs2_addr,
    input  [4:0] rd_addr,
    output[31:0] rs1_data,
    output[31:0] rs2_data,
    input [31:0] rd_data,
    input        enable
);
    reg[31:0] GPR[0:31];
    assign rs1_data = GPR[rs1_addr];
    assign rs2_data = GPR[rs2_addr];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            GPR[0] <= 1'b0;
            GPR[1] <= 1'b0;
            GPR[2] <= 1'b0;
            GPR[3] <= 1'b0;
            GPR[4] <= 1'b0;
            GPR[5] <= 1'b0;
            GPR[6] <= 1'b0;
            GPR[7] <= 1'b0;
            GPR[8] <= 1'b0;
            GPR[9] <= 1'b0;
            GPR[10] <= 1'b0;
            GPR[11] <= 1'b0;
            GPR[12] <= 1'b0;
            GPR[13] <= 1'b0;
            GPR[14] <= 1'b0;
            GPR[15] <= 1'b0;
            GPR[16] <= 1'b0;
            GPR[17] <= 1'b0;
            GPR[18] <= 1'b0;
            GPR[19] <= 1'b0;
            GPR[20] <= 1'b0;
            GPR[21] <= 1'b0;
            GPR[22] <= 1'b0;
            GPR[23] <= 1'b0;
            GPR[24] <= 1'b0;
            GPR[25] <= 1'b0;
            GPR[26] <= 1'b0;
            GPR[27] <= 1'b0;
            GPR[28] <= 1'b0;
            GPR[29] <= 1'b0;
            GPR[30] <= 1'b0;
            GPR[31] <= 1'b0;
        end
        else begin
            if (enable)
                GPR[rd_addr] <= rd_data;
        end    
    end
endmodule
