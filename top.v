`include "../sim/data_array/data_array_wrapper.v"
`include "../sim/tag_array/tag_array_wrapper.v"
`include "Processor.v"
`include "D-Cache.v"
`include "I-Cache.v"
module top (
    input           clk,
    input           rst,
    // AR channel
    output [31:0]   ARADDR_IM,
    output          ARVALID_IM,
    input           ARREADY_IM,
    // R channel
    input  [127:0]  RDATA_IM,
    input           RVALID_IM,
    output          RREADY_IM,
    // AR channel
    output [31:0]   ARADDR_DM,
    output          ARVALID_DM,
    input           ARREADY_DM,
    // R channel
    input  [127:0]  RDATA_DM,
    input           RVALID_DM,
    output          RREADY_DM,
    // AW channel
    output [31:0]   AWADDR_DM,
    output          AWVALID_DM,
    input           AWREADY_DM,
    // W channel
    output [127:0]  WDATA_DM,
    output [15:0]   WSTRB_DM,
    output          WVALID_DM,
    input           WREADY_DM
);
    // +==================== + ====================+ //
    // |             Instruction-Cache             | //
    // +==================== + ====================+ //
    wire        ic_CEB;
    wire        ic_WEB;
    wire [31:0] ic_BWEB_tag;
    wire[127:0] ic_BWEB_data;
    wire  [4:0] ic_index;
    wire [31:0] ic_tag_in;
    wire [31:0] ic_tag_out;
    wire[127:0] ic_data_in;
    wire[127:0] ic_data_out;
    wire [31:0] im_addr;
    wire [31:0] im_read_data;
    wire        stall_IF;
    wire        flush_IF;
    wire        im_valid;

    tag_array_wrapper  InstTag (
        .CLK     (clk),
        .CEB     (ic_CEB),
        .WEB     (ic_WEB),
        .BWEB    (ic_BWEB_tag),      
        .A       (ic_index),        
        .DI      (ic_tag_in), 
        .DO      (ic_tag_out)     
    );
    data_array_wrapper InstData (
        .CLK     (clk),
        .CEB     (ic_CEB),
        .WEB     (ic_WEB),
        .BWEB    (ic_BWEB_data), 
        .A       (ic_index),       
        .DI      (ic_data_in),  
        .DO      (ic_data_out)  
    );
    InstCache InstCache (
        .clk          (clk),
        .rst          (rst),

        .ARADDR_IM    (ARADDR_IM),
        .ARVALID_IM   (ARVALID_IM),
        .ARREADY_IM   (ARREADY_IM),
        .RDATA_IM     (RDATA_IM),
        .RVALID_IM    (RVALID_IM),
        .RREADY_IM    (RREADY_IM),
    
        .im_addr      (im_addr),
        .im_read_data (im_read_data),
        .stall_IF     (stall_IF),
        .flush_IF     (flush_IF),
        .im_valid     (im_valid),

        .ic_index     (ic_index),
        .ic_tag_out   (ic_tag_out),
        .ic_tag_in    (ic_tag_in),
        .ic_data_out  (ic_data_out),
        .ic_data_in   (ic_data_in),
        .ic_CEB       (ic_CEB),
        .ic_WEB       (ic_WEB),
        .ic_BWEB_tag  (ic_BWEB_tag),
        .ic_BWEB_data (ic_BWEB_data)
    );
    // +==================== + ====================+ //
    // |                 Data-Cache                | //
    // +==================== + ====================+ //
    wire        dc_CEB;
    wire        dc_WEB;
    wire [31:0] dc_BWEB_tag;
    wire[127:0] dc_BWEB_data;
    wire  [4:0] dc_index;
    wire [31:0] dc_tag_in;
    wire [31:0] dc_tag_out;
    wire[127:0] dc_data_in;
    wire[127:0] dc_data_out;

    wire[31:0] dm_addr;
    wire[31:0] dm_write_data;
    wire[31:0] dm_bit_en;
    wire[31:0] dm_read_data;
    wire       dm_req;
    wire       dm_WEB;
  //  wire       dm_valid;
    wire       dm_write;
    wire       dm_busy;

    tag_array_wrapper  DataTag (
        .CLK     (clk),
        .CEB     (dc_CEB),
        .WEB     (dc_WEB),
        .BWEB    (dc_BWEB_tag),      
        .A       (dc_index),        
        .DI      (dc_tag_in), 
        .DO      (dc_tag_out)     
    );

    data_array_wrapper DataData (
        .CLK     (clk),
        .CEB     (dc_CEB),
        .WEB     (dc_WEB),
        .BWEB    (dc_BWEB_data), 
        .A       (dc_index),       
        .DI      (dc_data_in),  
        .DO      (dc_data_out)  
    );

    DataCache DataCache (
        .clk          (clk),
        .rst          (rst),
        
        .ARADDR_DM    (ARADDR_DM),
        .ARVALID_DM   (ARVALID_DM),
        .ARREADY_DM   (ARREADY_DM),  
        .RDATA_DM     (RDATA_DM),
        .RVALID_DM    (RVALID_DM),
        .RREADY_DM    (RREADY_DM),
        .AWADDR_DM    (AWADDR_DM),
        .AWVALID_DM   (AWVALID_DM),
        .AWREADY_DM   (AWREADY_DM),
        .WDATA_DM     (WDATA_DM),
        .WSTRB_DM     (WSTRB_DM),
        .WVALID_DM    (WVALID_DM),
        .WREADY_DM    (WREADY_DM),

        .dm_addr       (dm_addr),
        .dm_read_data  (dm_read_data),
        .dm_write_data (dm_write_data),
        .dm_bit_en     (dm_bit_en),
        .dm_WEB        (dm_WEB),
        .dm_req        (dm_req),
    //    .dm_valid      (dm_valid),
        .dm_busy       (dm_busy),
        .dm_write      (dm_write),

        .dc_CEB       (dc_CEB),
        .dc_WEB       (dc_WEB),
        .dc_BWEB_data (dc_BWEB_data),
        .dc_BWEB_tag  (dc_BWEB_tag), 
        .dc_index     (dc_index),       
        .dc_data_in   (dc_data_in),  
        .dc_data_out  (dc_data_out),
        .dc_tag_in    (dc_tag_in),
        .dc_tag_out   (dc_tag_out)  
    );

    // +==================== + ====================+ //
    // |                 Processor                 | //
    // +==================== + ====================+ //
    Processor Processor (
        .clk          (clk),
        .rst          (rst),

        .im_addr      (im_addr),
        .im_read_data (im_read_data),
        .stall_IF     (stall_IF),
        .flush_IF     (flush_IF),
        .im_valid     (im_valid),

        .dm_addr       (dm_addr),
        .dm_read_data  (dm_read_data),
        .dm_write_data (dm_write_data),
        .dm_bit_en     (dm_bit_en),
        .dm_WEB        (dm_WEB),
        .dm_req        (dm_req),
    //    .dm_valid      (dm_valid),
        .dm_busy       (dm_busy),
        .dm_write      (dm_write)
    );
endmodule
