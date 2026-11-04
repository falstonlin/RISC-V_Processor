`include "Parameter.v"
module InstCache (
    input clk,
    input rst,

    output[31:0] ARADDR_IM,
    output       ARVALID_IM,
    input        ARREADY_IM,
    input[127:0] RDATA_IM,
    input        RVALID_IM,
    output       RREADY_IM,
    
    input [31:0] im_addr,
    output[31:0] im_read_data,
    input        stall_IF,
    input        flush_IF,
    output reg   im_valid,

    output      [4:0] ic_index,
    input      [31:0] ic_tag_out,
    output     [31:0] ic_tag_in,
    input     [127:0] ic_data_out,
    output    [127:0] ic_data_in,
    output reg        ic_CEB,
    output reg        ic_WEB,
    output reg [31:0] ic_BWEB_tag,
    output reg[127:0] ic_BWEB_data
);
    reg      ic_VBit[0:31];
    reg[2:0] state;
    reg[2:0] nextstate;
    reg      ic_change;
    reg      ic_req;
    reg      ic_source;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= `IC_IDLE;
            ic_change   <= 1'b0;
            ic_VBit[0]  <= 1'b0;
            ic_VBit[1]  <= 1'b0;
            ic_VBit[2]  <= 1'b0;
            ic_VBit[3]  <= 1'b0;
            ic_VBit[4]  <= 1'b0;
            ic_VBit[5]  <= 1'b0;
            ic_VBit[6]  <= 1'b0;
            ic_VBit[7]  <= 1'b0;
            ic_VBit[8]  <= 1'b0;
            ic_VBit[9]  <= 1'b0;
            ic_VBit[10] <= 1'b0;
            ic_VBit[11] <= 1'b0;
            ic_VBit[12] <= 1'b0;
            ic_VBit[13] <= 1'b0;
            ic_VBit[14] <= 1'b0;
            ic_VBit[15] <= 1'b0;
            ic_VBit[16] <= 1'b0;
            ic_VBit[17] <= 1'b0;
            ic_VBit[18] <= 1'b0;
            ic_VBit[19] <= 1'b0;
            ic_VBit[20] <= 1'b0;
            ic_VBit[21] <= 1'b0;
            ic_VBit[22] <= 1'b0;
            ic_VBit[23] <= 1'b0;
            ic_VBit[24] <= 1'b0;
            ic_VBit[25] <= 1'b0;
            ic_VBit[26] <= 1'b0;
            ic_VBit[27] <= 1'b0;
            ic_VBit[28] <= 1'b0;
            ic_VBit[29] <= 1'b0;
            ic_VBit[30] <= 1'b0;
            ic_VBit[31] <= 1'b0;
        end 
        else begin
            state <= nextstate;

            if (state == `IC_FETCH)
                ic_change <= 1'b0;
            else if (ARREADY_IM)
                ic_change <= 1'b1;
            else
                ic_change <= ic_change;

            if (RREADY_IM && RVALID_IM)
                ic_VBit[ic_index] <= 1'b1;
        end       
    end

    wire[1:0]  ic_offset;
    wire[22:0] ic_tag;
    wire       ic_hit;
    assign ic_offset = im_addr[3:2];
    assign ic_index  = im_addr[8:4];
    assign ic_tag    = im_addr[31:9];
    assign ic_hit    = (ic_tag_out[31:9] == ic_tag) && (ic_VBit[ic_index]);

    assign ic_tag_in  = {im_addr[31:4], {4{1'b0}}};
    assign ARADDR_IM  = {im_addr[31:4], {4{1'b0}}};
    assign ic_data_in = RDATA_IM;

    wire[127:0] ic_raw_data;
    assign ic_raw_data  = (ic_source) ? ic_data_out : RDATA_IM;
    assign im_read_data = (ic_offset == 2'b11) ? ic_raw_data[127:96] : (ic_offset == 2'b10) ? ic_raw_data[95:64] :
                          (ic_offset == 2'b01) ? ic_raw_data[63:32]  :                        ic_raw_data[31:0];


    /*==================== Finite State Machine ====================*/
    assign ARVALID_IM = (ic_req) && (~ic_change);
    assign RREADY_IM  = (state == `IC_LOAD) ? 1'b1 : 1'b0;
    always @(*) begin
        case (state)
            `IC_IDLE: begin
                ic_CEB       = 1'b1;
                ic_WEB       = 1'b1;
                ic_BWEB_tag  = 32'hffffffff;
                ic_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                ic_req       = 1'b0;
                ic_source    = 1'b1;
                im_valid     = 1'b0;
                nextstate    = (!rst) ? `IC_FETCH : `IC_IDLE;
            end

            `IC_FETCH: begin
                ic_CEB       = 1'b0;
                ic_WEB       = 1'b1;
                ic_BWEB_tag  = 32'hffffffff;
                ic_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                ic_req       = 1'b0;
                im_valid     = 1'b0;
                ic_source    = 1'b1;
                if (stall_IF) 
                    nextstate = `IC_FETCH;
                else 
                    nextstate = (flush_IF) ? `IC_IDLE : `IC_CHECK;
            end

            `IC_CHECK: begin
                ic_CEB       = 1'b0;
                ic_WEB       = 1'b1;
                ic_BWEB_tag  = 32'hffffffff;
                ic_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                ic_source    = 1'b1;

                if (flush_IF) begin
                    im_valid = 1'b0;
                    nextstate = `IC_FETCH;
                    ic_req    = 1'b0;
                end
                else begin
                    if (ic_hit) begin
                        if (stall_IF) begin
                            im_valid = 1'b1;
                            ic_req   = 1'b0;
                            nextstate = `IC_READY;
                        end
                        else begin
                            im_valid = 1'b1;
                            ic_req   = 1'b0;
                            nextstate = `IC_FETCH;
                        end
                    end
                    else begin
                        im_valid = 1'b0;
                        ic_req   = 1'b1;
                        nextstate = `IC_LOAD;
                    end
                end
            end

            `IC_LOAD: begin
                ic_CEB       = 1'b0;
                ic_WEB       = (RVALID_IM) ? 1'b0 : 1'b1;
                ic_BWEB_tag  = 32'h0;
                ic_BWEB_data = 128'h0;
                ic_req       = 1'b1;
                ic_source    = 1'b0;

                if (RVALID_IM) begin
                    im_valid  = 1'b1;
                    nextstate = (!stall_IF) ? `IC_FETCH : `IC_WAIT;
                end
                else begin
                    im_valid  = 1'b0;
                    nextstate = `IC_LOAD;
                end
            end

            `IC_WAIT: begin
                ic_CEB       = 1'b0;
                ic_WEB       = 1'b1;
                ic_BWEB_tag  = 32'hffffffff;
                ic_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                im_valid     = 1'b0;
                ic_source    = 1'b1;
                ic_req       = 1'b0;
                nextstate    = `IC_READY;
            end

            `IC_READY: begin
                ic_CEB       = 1'b0;
                ic_WEB       = 1'b1;
                ic_BWEB_tag  = 32'hffffffff;
                ic_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                im_valid     = 1'b1;
                ic_source    = 1'b1;
                ic_req       = 1'b0;
                nextstate    = (!stall_IF) ? `IC_FETCH : `IC_READY;
            end
            
            default: begin
                ic_CEB       = 1'b1;
                ic_WEB       = 1'b1;
                ic_BWEB_tag  = 32'hffffffff;
                ic_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                im_valid     = 1'b0;
                ic_source    = 1'b1;
                ic_req       = 1'b0;
                nextstate    = `IC_IDLE;
            end
        endcase
    end
endmodule
