`include "Parameter.v"
module LoadFilter (
    input     [31:0] data_in,
    input      [1:0] addr,     
    input      [1:0] lengh, 
    input            sign,     
    output reg[31:0] data_out
);
    reg [7:0] byte_data;
    reg[15:0] half_data;
    always @(*) begin
        case (lengh)
            2'b11: begin
                data_out = data_in;
            end
            2'b10: begin
                half_data = (addr[1]) ? data_in[31:16] : data_in[15:0];
                if (sign)
                    data_out = {{16{half_data[15]}}, half_data};
                else
                    data_out = {16'b0, half_data};
            end
            2'b01: begin
                case (addr)
                    2'b00  : byte_data = data_in[7:0];
                    2'b01  : byte_data = data_in[15:8];
                    2'b10  : byte_data = data_in[23:16];
                    2'b11  : byte_data = data_in[31:24];
                    default: byte_data = 8'b0;
                endcase
                if (sign)
                    data_out = {{24{byte_data[7]}}, byte_data};
                else
                    data_out = {24'b0, byte_data};
            end
            default: data_out = 32'b0;
        endcase
    end
endmodule
