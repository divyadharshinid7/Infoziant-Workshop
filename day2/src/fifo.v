module synchronous_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = 4
) (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire read_enable,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output wire full,
    output wire empty,
    output reg [ADDR_WIDTH:0] count
);
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] write_pointer, read_pointer;
    wire read_accept = read_enable && !empty;
    wire write_accept = write_enable && (!full || read_accept);
    assign full = (count == DEPTH);
    assign empty = (count == 0);

    always @(posedge clk) begin
        if (reset) begin
            write_pointer <= 0;
            read_pointer <= 0;
            count <= 0;
            data_out <= 0;
        end else begin
            if (write_accept) begin
                memory[write_pointer] <= data_in;
                write_pointer <= write_pointer + 1'b1;
            end
            if (read_accept) begin
                data_out <= memory[read_pointer];
                read_pointer <= read_pointer + 1'b1;
            end
            case ({write_accept,read_accept})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule
