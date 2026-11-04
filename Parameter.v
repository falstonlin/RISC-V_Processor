/*===== ALU, MPU, FPU =====*/
`define ADD    4'd0
`define SUB    4'd1
`define SLL    4'd2
`define SLT    4'd3
`define SLTU   4'd4
`define XOR    4'd5
`define SRL    4'd6
`define SRA    4'd7
`define OR     4'd8
`define AND    4'd9
`define BEQ    4'd10
`define BNE    4'd11
`define BLT    4'd12
`define BGE    4'd13
`define BLTU   4'd14
`define BGEU   4'd15
`define MUL    2'b00
`define MULH   2'b01
`define MULHSU 2'b10
`define MULHU  2'b11
`define F_MIN  2'b00
`define F_MAX  2'b01
`define F_ADD  2'b10
`define F_SUB  2'b11

/*===== opcode =====*/
`define NOP     7'b0000000
`define LOAD_I  7'b0000011
`define STORE_I 7'b0100011
`define LOAD_F  7'b0000111
`define STORE_F 7'b0100111
`define BRANCH  7'b1100011
`define ARTH_R  7'b0110011
`define ARTH_I  7'b0010011
`define ARTH_F  7'b1010011
`define AUIPC   7'b0010111
`define JAL     7'b1101111
`define JALR    7'b1100111
`define LUI     7'b0110111
`define SYSTEM  7'b1110011
`define MAC     7'b0101011

/*===== Inst-Cache =====*/
`define IC_IDLE   3'd0
`define IC_FETCH  3'd1
`define IC_CHECK  3'd2
`define IC_LOAD   3'd3
`define IC_WAIT   3'd4
`define IC_READY  3'd5

/*===== Data-Cache =====*/
`define DC_IDLE   3'd0
`define DC_FETCH  3'd1
`define DC_CHECK  3'd2
`define DC_LOAD   3'd3
`define DC_WRITE  3'd4
`define DC_WAIT   3'd5
`define DC_READY  3'd6

`define USE_INT_REGFILE 1'b0
`define USE_FLT_REGFILE 1'b1

`define USE_CSR 2'b11
`define USE_FPU 2'b10
`define USE_MPU 2'b01
`define USE_ALU 2'b00

`define USE_RS1 2'b11
`define USE_PC  2'b10
`define USE_XPU 2'b01
`define USE_0   2'b00
`define USE_RS2 2'b11
`define USE_IMM 2'b10
`define USE_REG 2'b01
`define USE_4   2'b00

`define USE_PROCESSOR 1'b1
`define USE_MEMORY    1'b0;

`define MAC_IDLE 1'b0
`define MAC_HOLD 1'b1

`define FP_IDLE  2'b00
`define FP_CAL   2'b01
`define FP_ROUND 2'b10