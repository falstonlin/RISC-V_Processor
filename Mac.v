`include "Parameter.v"
module Mac (
    input clk,
    input rst,

    input[31:0] mac_op0,
    input[31:0] mac_op1,

    output reg[31:0] reg_op0,
    output reg[31:0] reg_op1,

    input      mac_req,
    input      mac_stall,
    output reg mac_valid
);
    reg store;
    reg state;
    reg nextstate;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= `MAC_IDLE;
            reg_op0 <= 32'b0;
            reg_op1 <= 32'b0;
        end
        else begin
            state <= nextstate;
            if (store) begin
                reg_op0 <= mac_op0;
                reg_op1 <= mac_op1;
            end
        end
    end


    always @(*) begin
        case (state)
            `MAC_IDLE: begin
                mac_valid = 1'b0;
                store     = (mac_req) ? 1'b1 : 1'b0;
                nextstate = (mac_req) ? `MAC_HOLD : `MAC_IDLE;
            end
            `MAC_HOLD: begin
                mac_valid = 1'b1;
                store     = 1'b0;
                nextstate = (mac_stall) ? `MAC_HOLD : `MAC_IDLE;
            end
            default: begin
                mac_valid = 1'b0;
                store     = 1'b0;
                nextstate = `MAC_IDLE;
            end
        endcase
    end
endmodule
