`include "Parameter.v"
module DataCache (
    input clk,
    input rst,

    output [31:0] ARADDR_DM,
    output        ARVALID_DM,
    input         ARREADY_DM,  
    input [127:0] RDATA_DM,
    input         RVALID_DM,
    output        RREADY_DM,
    output [31:0] AWADDR_DM,
    output        AWVALID_DM,
    input         AWREADY_DM,
    output[127:0] WDATA_DM,
    output [15:0] WSTRB_DM,
    output        WVALID_DM,
    input         WREADY_DM,

    input  [31:0] dm_addr,
    input  [31:0] dm_write_data,
    input  [31:0] dm_bit_en,
    output [31:0] dm_read_data,
    output  [4:0] dc_index,
    input  [31:0] dc_tag_out,
    output [31:0] dc_tag_in,
    input [127:0] dc_data_out,
    output[127:0] dc_data_in,

    input             dm_req,
    input             dm_WEB,
    output reg        dc_CEB,
    output reg        dc_WEB,
    output reg [31:0] dc_BWEB_tag,
    output reg[127:0] dc_BWEB_data,
    output reg        dm_busy,
    output reg        dm_write
);
    reg[2:0] state;
    reg[2:0] nextstate;
    reg       dc_type;   // dm_WEB
    reg[31:0] dc_addr;   // dm_addr

    reg[31:0] dc_bit_buffer;
    reg[31:0] dc_data_buffer;
    reg       shake;
    reg       dc_VBit[0:31];
    reg       enable;
    reg       dc_req;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dc_addr        <= 32'b0;
            dc_type        <= 1'b0;          
            dc_data_buffer <= 32'b0;
            dc_bit_buffer  <= 32'b0;

            state <= `DC_IDLE;
            shake <= 1'b0;

            dc_VBit[0] <= 1'b0;
            dc_VBit[1] <= 1'b0;
            dc_VBit[2] <= 1'b0;
            dc_VBit[3] <= 1'b0;
            dc_VBit[4] <= 1'b0;
            dc_VBit[5] <= 1'b0;
            dc_VBit[6] <= 1'b0;
            dc_VBit[7] <= 1'b0;
            dc_VBit[8] <= 1'b0;
            dc_VBit[9] <= 1'b0;
            dc_VBit[10] <= 1'b0;
            dc_VBit[11] <= 1'b0;
            dc_VBit[12] <= 1'b0;
            dc_VBit[13] <= 1'b0;
            dc_VBit[14] <= 1'b0;
            dc_VBit[15] <= 1'b0;
            dc_VBit[16] <= 1'b0;
            dc_VBit[17] <= 1'b0;
            dc_VBit[18] <= 1'b0;
            dc_VBit[19] <= 1'b0;
            dc_VBit[20] <= 1'b0;
            dc_VBit[21] <= 1'b0;
            dc_VBit[22] <= 1'b0;
            dc_VBit[23] <= 1'b0;
            dc_VBit[24] <= 1'b0;
            dc_VBit[25] <= 1'b0;
            dc_VBit[26] <= 1'b0;
            dc_VBit[27] <= 1'b0;
            dc_VBit[28] <= 1'b0;
            dc_VBit[29] <= 1'b0;
            dc_VBit[30] <= 1'b0;
            dc_VBit[31] <= 1'b0;
        end
        else begin
            state <= nextstate;

            if (dm_req && !dm_busy && !dm_write) begin
                dc_addr <= dm_addr;
                dc_type <= dm_WEB;
            end

            if (enable) begin
                dc_data_buffer <= dm_write_data;
                dc_bit_buffer  <= dm_bit_en;
            end

            if (dm_req && !dm_busy && !dm_write)
                shake <= 1'b0;
            else if (dc_req && (ARREADY_DM || AWREADY_DM))
                shake <= 1'b1;
            else
                shake <= shake;

            if (RVALID_DM && RREADY_DM)
                dc_VBit[dc_index] <= 1'b1;
        end
    end


    wire  [1:0] dc_offset;
    wire [22:0] dc_tag;
    wire        dc_hit;
    
    wire[127:0] dc_write_extend;
    wire[127:0] dc_read_raw;

    assign ARADDR_DM = {dc_addr[31:4], {4{1'b0}}};
    assign AWADDR_DM = {dc_addr[31:4], {4{1'b0}}};
    assign dc_tag_in = {dc_addr[31:4], {4{1'b0}}};

    assign dc_offset = dc_addr[3:2];
    assign dc_index  = dc_addr[8:4];
    assign dc_tag    = dc_addr[31:9];
    assign dc_hit    = (dc_VBit[dc_index]) && (dc_tag == dc_tag_out[31:9]);


    assign ARVALID_DM = (dc_req) &&  (dc_type) && (!shake);
    assign AWVALID_DM = (dc_req) && (!dc_type) && (!shake);
    assign RREADY_DM  = (state == `DC_LOAD)  ? 1'b1 : 1'b0;
    assign WVALID_DM  = (state == `DC_WRITE) ? 1'b1 : 1'b0;


    assign dc_write_extend = (dc_offset == 2'b11) ? {dc_data_buffer, {96{1'b0}}} : 
                             (dc_offset == 2'b10) ? {{32{1'b0}}, dc_data_buffer, {64{1'b0}}} :
                             (dc_offset == 2'b01) ? {{64{1'b0}}, dc_data_buffer, {32{1'b0}}} : {{96{1'b0}}, dc_data_buffer};
    assign WDATA_DM = dc_write_extend;

    assign dc_read_raw  = dc_data_out;
    assign dm_read_data = (dc_offset == 2'b11) ? dc_read_raw[127:96] : (dc_offset == 2'b10) ? dc_read_raw[95:64] :
                          (dc_offset == 2'b01) ? dc_read_raw[63:32]  : dc_read_raw[31:0]; 

    assign dc_data_in = (dc_type) ? RDATA_DM : dc_write_extend;
    //*========================= + =========================*//
    //*                 Write Strobe Signal                 *//
    //*========================= + =========================*//
    reg[15:0] Write_Strobe;
    always @(*) begin
        case (dc_bit_buffer)
            32'h00000000: begin
                case (dc_offset)
                    2'b00  : Write_Strobe = 16'b0000000000001111;
                    2'b01  : Write_Strobe = 16'b0000000011110000;
                    2'b10  : Write_Strobe = 16'b0000111100000000;
                    2'b11  : Write_Strobe = 16'b1111000000000000;
                    default: Write_Strobe = 16'b0;
                endcase
            end
            32'hffff0000: begin
                case (dc_offset)
                    2'b00  : Write_Strobe = 16'b0000000000000011;
                    2'b01  : Write_Strobe = 16'b0000000000110000;
                    2'b10  : Write_Strobe = 16'b0000001100000000;
                    2'b11  : Write_Strobe = 16'b0011000000000000;
                    default: Write_Strobe = 16'b0;
                endcase
            end
            32'h0000ffff: begin
                case (dc_offset)
                    2'b00  : Write_Strobe = 16'b0000000000001100;
                    2'b01  : Write_Strobe = 16'b0000000011000000;
                    2'b10  : Write_Strobe = 16'b0000110000000000;
                    2'b11  : Write_Strobe = 16'b1100000000000000;
                    default: Write_Strobe = 16'b0;
                endcase
            end 
            32'hffffff00: begin
                case (dc_offset)
                    2'b00  : Write_Strobe = 16'b0000000000000001;
                    2'b01  : Write_Strobe = 16'b0000000000010000;
                    2'b10  : Write_Strobe = 16'b0000000100000000;
                    2'b11  : Write_Strobe = 16'b0001000000000000;
                    default: Write_Strobe = 16'b0;
                endcase
            end 
            32'hffff00ff: begin
                case (dc_offset)
                    2'b00  : Write_Strobe = 16'b0000000000000010;
                    2'b01  : Write_Strobe = 16'b0000000000100000;
                    2'b10  : Write_Strobe = 16'b0000001000000000;
                    2'b11  : Write_Strobe = 16'b0010000000000000;
                    default: Write_Strobe = 16'b0;
                endcase
            end 
            32'hff00ffff: begin
                case (dc_offset)
                    2'b00  : Write_Strobe = 16'b0000000000000100;
                    2'b01  : Write_Strobe = 16'b0000000001000000;
                    2'b10  : Write_Strobe = 16'b0000010000000000;
                    2'b11  : Write_Strobe = 16'b0100000000000000;
                    default: Write_Strobe = 16'b0;
                endcase
            end 
            32'h00ffffff: begin
                case (dc_offset)
                    2'b00  : Write_Strobe = 16'b0000000000001000;
                    2'b01  : Write_Strobe = 16'b0000000010000000;
                    2'b10  : Write_Strobe = 16'b0000100000000000;
                    2'b11  : Write_Strobe = 16'b1000000000000000;
                    default: Write_Strobe = 16'b0;
                endcase
            end 
            default: Write_Strobe = 16'b0;
        endcase
    end
    assign WSTRB_DM = Write_Strobe;
    //*========================= + =========================*//
    //*                Finite State Machine                 *//
    //*========================= + =========================*//
    always @(*) begin
        case (state)
            `DC_IDLE: begin
                dc_CEB       = 1'b1;
                dc_WEB       = 1'b1;
                dc_BWEB_tag  = 32'hffffffff; 
                dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                dc_req       = 1'b0;
        
                dm_busy      = 1'b0;
                dm_write     = 1'b0;
                enable       = 1'b0;
             
                nextstate    = (dm_req) ? `DC_FETCH : `DC_IDLE;
            end

            `DC_FETCH: begin
                dc_CEB       = 1'b0;
                dc_WEB       = 1'b1;
                dc_BWEB_tag  = 32'hffffffff; 
                dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                dc_req       = (dc_type) ? 1'b0 : 1'b1;
         
                dm_busy      = 1'b1;
                dm_write     = (dc_type) ? 1'b0 : 1'b1;
               
                enable       = (dc_type) ? 1'b0 : 1'b1;
                nextstate    = `DC_CHECK;
            end

            `DC_CHECK: begin
                enable = 1'b0;
                if (dc_hit) begin
                    if (dc_type) begin
                        dc_CEB       = 1'b0;
                        dc_WEB       = 1'b1;
                        dc_BWEB_tag  = 32'hffffffff; 
                        dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                        dc_req       = 1'b0;        
                        dm_busy      = 1'b0;
                        dm_write     = 1'b0;                    
                        nextstate    = (dm_req) ? `DC_FETCH : `DC_IDLE;
                    end
                    // Store Hit
                    else begin
                        dc_CEB       = 1'b0;
                        dc_WEB       = 1'b0;
                        dc_BWEB_tag  = 32'h0; 
                        dc_req       = 1'b1;
         
                        dm_busy      = 1'b1;
                        dm_write     = 1'b1;
                        nextstate    = `DC_WRITE;
                      
                        case (dc_bit_buffer) 
                            32'h00000000: begin
                                case (dc_offset)
                                    2'b00  : dc_BWEB_data = 128'hffffffffffffffffffffffff00000000;
                                    2'b01  : dc_BWEB_data = 128'hffffffffffffffff00000000ffffffff;
                                    2'b10  : dc_BWEB_data = 128'hffffffff00000000ffffffffffffffff;
                                    2'b11  : dc_BWEB_data = 128'h00000000ffffffffffffffffffffffff;
                                    default: dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                                endcase
                            end
                            32'hffff0000: begin
                                case (dc_offset)
                                    2'b00  : dc_BWEB_data = 128'hffffffffffffffffffffffffffff0000;
                                    2'b01  : dc_BWEB_data = 128'hffffffffffffffffffff0000ffffffff;
                                    2'b10  : dc_BWEB_data = 128'hffffffffffff0000ffffffffffffffff;
                                    2'b11  : dc_BWEB_data = 128'hffff0000ffffffffffffffffffffffff;
                                    default: dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                                endcase
                            end
                            32'h0000ffff: begin
                                case (dc_offset)
                                    2'b00  : dc_BWEB_data = 128'hffffffffffffffffffffffff0000ffff;
                                    2'b01  : dc_BWEB_data = 128'hffffffffffffffff0000ffffffffffff;
                                    2'b10  : dc_BWEB_data = 128'hffffffff0000ffffffffffffffffffff;
                                    2'b11  : dc_BWEB_data = 128'h0000ffffffffffffffffffffffffffff;
                                    default: dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                                endcase
                            end
                            32'hffffff00: begin
                                case (dc_offset)
                                    2'b00  : dc_BWEB_data = 128'hffffffffffffffffffffffffffffff00;
                                    2'b01  : dc_BWEB_data = 128'hffffffffffffffffffffff00ffffffff;
                                    2'b10  : dc_BWEB_data = 128'hffffffffffffff00ffffffffffffffff;
                                    2'b11  : dc_BWEB_data = 128'hffffff00ffffffffffffffffffffffff;
                                    default: dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                                endcase
                            end
                            32'hffff00ff: begin
                                case (dc_offset)
                                    2'b00  : dc_BWEB_data = 128'hffffffffffffffffffffffffffff00ff;
                                    2'b01  : dc_BWEB_data = 128'hffffffffffffffffffff00ffffffffff;
                                    2'b10  : dc_BWEB_data = 128'hffffffffffff00ffffffffffffffffff;
                                    2'b11  : dc_BWEB_data = 128'hffff00ffffffffffffffffffffffffff;
                                    default: dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                                endcase
                            end
                            32'hff00ffff: begin
                                case (dc_offset)
                                    2'b00  : dc_BWEB_data = 128'hffffffffffffffffffffffffff00ffff;
                                    2'b01  : dc_BWEB_data = 128'hffffffffffffffffff00ffffffffffff;
                                    2'b10  : dc_BWEB_data = 128'hffffffffff00ffffffffffffffffffff;
                                    2'b11  : dc_BWEB_data = 128'hff00ffffffffffffffffffffffffffff;
                                    default: dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                                endcase
                            end
                            32'h00ffffff: begin
                                case (dc_offset)
                                    2'b00  : dc_BWEB_data = 128'hffffffffffffffffffffffff00ffffff;
                                    2'b01  : dc_BWEB_data = 128'hffffffffffffffff00ffffffffffffff;
                                    2'b10  : dc_BWEB_data = 128'hffffffff00ffffffffffffffffffffff;
                                    2'b11  : dc_BWEB_data = 128'h00ffffffffffffffffffffffffffffff;
                                    default: dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                                endcase
                            end
                            default: dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff; 
                        endcase
                    end
                end
                else begin
                    if (dc_type) begin
                        dc_CEB       = 1'b0;
                        dc_WEB       = 1'b1;
                        dc_BWEB_tag  = 32'hffffffff; 
                        dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                        dc_req       = 1'b1;         
                        dm_busy      = 1'b1;
                        dm_write     = 1'b0;                
                        nextstate = `DC_LOAD;
                    end
                    else begin
                        dc_CEB       = 1'b0;
                        dc_WEB       = 1'b1;
                        dc_BWEB_tag  = 32'hffffffff; 
                        dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                        dc_req       = 1'b1;       
                        dm_busy      = 1'b1;
                        dm_write     = 1'b1;             
                        nextstate    = `DC_WRITE;
                    end
                end
            end

            `DC_LOAD: begin
                dc_CEB       = 1'b0;
                dc_WEB       = (RVALID_DM) ? 1'b0 : 1'b1;
                dc_BWEB_tag  = 32'h0; 
                dc_BWEB_data = 128'h0;
                dc_req       = 1'b1;
                dm_busy      = 1'b1;
                dm_write     = 1'b0;
                enable       = 1'b0;                
                nextstate    = (RVALID_DM) ? `DC_WAIT : `DC_LOAD;
            end

            `DC_WRITE: begin
                dc_CEB       = 1'b0;
                dc_WEB       = 1'b1;
                dc_BWEB_tag  = 32'hffffffff; 
                dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                enable       = 1'b0;
                dc_req       = 1'b1;
                dm_busy      = 1'b0;
                dm_write     = (WREADY_DM) ? 1'b0 : 1'b1;
                nextstate    = (WREADY_DM) ? (dm_req) ? `DC_FETCH : `DC_IDLE : `DC_WRITE;          
            end

            `DC_WAIT: begin
                dc_CEB       = 1'b0;
                dc_WEB       = 1'b1;
                dc_BWEB_tag  = 32'hffffffff; 
                dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                dc_req       = 1'b0;
                dm_busy      = 1'b1;
                dm_write     = 1'b0;
                enable       = 1'b0;
                nextstate    = `DC_READY;
            end

            `DC_READY: begin
                dc_CEB       = 1'b0;
                dc_WEB       = 1'b1;
                dc_BWEB_tag  = 32'hffffffff; 
                dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                dc_req       = 1'b0;
        
                dm_busy      = 1'b0;
                dm_write     = 1'b0;
                enable       = 1'b0;
                
                nextstate    = (dm_req) ? `DC_FETCH : `DC_READY;
                    
            end

            default: begin
                dc_CEB       = 1'b1;
                dc_WEB       = 1'b1;
                dc_BWEB_tag  = 32'hffffffff; 
                dc_BWEB_data = 128'hffffffffffffffffffffffffffffffff;
                dc_req       = 1'b0;
                dm_busy      = 1'b0;
                dm_write     = 1'b0;
                enable       = 1'b0;               
                nextstate    = `DC_IDLE;
            end 
        endcase
    end
endmodule
