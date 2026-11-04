`include "Parameter.v"
module StoreFilter (
    input     [31:0] data_in,
    input      [1:0] addr,
    input      [1:0] lengh,
	output reg[31:0] mask,
    output reg[31:0] data_out
);
    always @(*) begin
        case (lengh)
            2'b11: begin
				data_out = data_in;
				mask     = 32'h00000000;
			end

            2'b10: begin
                case (addr[1])
                    1'b1: begin
						data_out = {data_in[15:0], {16{1'b0}}};
						mask     = 32'h0000ffff;
					end                
                    1'b0: begin
						data_out = {{16{1'b0}}, data_in[15:0]};
						mask     = 32'hffff0000;
					end
                    default: begin
						data_out = 32'b0;
						mask     = 32'hffffffff;
					end
                endcase
            end

            2'b01: begin
                case (addr)
                    2'b00: begin
						data_out = {{24{1'b0}}, data_in[7:0]};
						mask     = 32'hffffff00;
					end
                    2'b01: begin
						data_out = {{16{1'b0}}, data_in[7:0], {8{1'b0}}};
						mask     = 32'hffff00ff;
					end
                    2'b10: begin
						data_out = {{8{1'b0}}, data_in[7:0], {16{1'b0}}};
						mask     = 32'hff00ffff;
					end
                    2'b11: begin
						data_out = {data_in[7:0], {24{1'b0}}};
						mask     = 32'h00ffffff;
					end
                    default: begin
						data_out = 32'b0;
					    mask     = 32'hffffffff;
						end
                endcase
            end
            default: begin
				data_out = 32'b0;
				mask     = 32'hffffffff;
			end
        endcase
    end
endmodule
