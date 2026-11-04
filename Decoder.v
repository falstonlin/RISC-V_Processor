module Decoder (
    input[31:0] isa,
    output[6:0] opcode,
    output[2:0] func3,
    output[4:0] rd_addr,
    output[4:0] rs1_addr,
    output[4:0] rs2_addr,
    output[1:0] csr,
    output      func5,
    output[1:0] func7
);
    assign opcode  = isa[6:0];
    assign rd_addr = isa[11:7];
    assign func3   = isa[14:12];
    assign rs1_addr = isa[19:15];
    assign rs2_addr = isa[24:20];
    assign func5    =  isa[27];
    assign func7    = {isa[30], isa[25]};
    assign csr      = {isa[27], isa[21]};  
endmodule