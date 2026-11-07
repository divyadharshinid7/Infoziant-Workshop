module vending_machine (
    input wire clk,
    input wire reset,
    input wire coin5,
    input wire coin10,
    input wire cancel,
    output reg dispense,
    output reg [7:0] change,
    output reg [7:0] refund,
    output reg [4:0] inserted
);
    reg [4:0] total;
    reg [4:0] added;
    always @(*) begin
        added = coin5 ? 5 : coin10 ? 10 : 0;
    end
    always @(posedge clk) begin
        if (reset) begin
            total <= 0; inserted <= 0; dispense <= 0; change <= 0; refund <= 0;
        end else begin
            dispense <= 0; change <= 0; refund <= 0; inserted <= total;
            if (cancel) begin
                refund <= total;
                total <= 0;
                inserted <= 0;
            end else if (added != 0) begin
                if (total + added >= 15) begin
                    dispense <= 1;
                    change <= total + added - 15;
                    total <= 0;
                    inserted <= 0;
                end else begin
                    total <= total + added;
                    inserted <= total + added;
                end
            end
        end
    end
endmodule
