module CSRegFile (
    input            clk,
    input            rst,
    input            finish,
    input      [1:0] csr_type,
    output reg[31:0] csr_data
);
    reg [63:0] cycle;
    reg [63:0] instret;
    wire[63:0] instret_adjust;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle   <= 64'b0;
            instret <= 64'b0;
        end
        else begin
            cycle <= cycle + 1;
            if (finish)
                instret <= instret + 1;
            else
                instret <= instret;
        end
    end

    assign instret_adjust = instret + 1;

    always @(*) begin
        case (csr_type)
            2'b11  : csr_data = instret_adjust[63:32];
            2'b10  : csr_data = cycle[63:32];
            2'b01  : csr_data = instret_adjust[31:0];
            2'b00  : csr_data = cycle[31:0];
            default: csr_data = 32'b0;
        endcase
    end
endmodule
