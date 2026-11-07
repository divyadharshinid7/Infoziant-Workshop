module atm_controller #(
    parameter [15:0] PIN_CODE = 16'h1234,
    parameter [31:0] INITIAL_BALANCE = 32'd1000
) (
    input wire clk,
    input wire reset,
    input wire card_insert,
    input wire submit_pin,
    input wire [15:0] entered_pin,
    input wire check_balance,
    input wire withdraw,
    input wire [31:0] withdraw_amount,
    input wire card_remove,
    output reg [31:0] balance,
    output reg balance_valid,
    output reg dispense_cash,
    output reg insufficient_funds,
    output reg locked,
    output reg [2:0] state
);
    localparam WAIT_CARD=0, WAIT_PIN=1, MENU=2, LOCKED=3;
    reg [1:0] attempts;
    always @(posedge clk) begin
        if (reset) begin
            state <= WAIT_CARD; balance <= INITIAL_BALANCE; attempts <= 0;
            balance_valid <= 0; dispense_cash <= 0; insufficient_funds <= 0;
        end else begin
            dispense_cash <= 0;
            insufficient_funds <= 0;
            balance_valid <= 0;
            case(state)
                WAIT_CARD: if(card_insert) begin state<=WAIT_PIN; attempts<=0; end
                WAIT_PIN: if(submit_pin) begin
                    if(entered_pin==PIN_CODE) begin state<=MENU; attempts<=0; end
                    else if(attempts==2) state<=LOCKED;
                    else attempts<=attempts+1'b1;
                end
                MENU: begin
                    if(check_balance) balance_valid<=1;
                    if(withdraw) begin
                        if(withdraw_amount<=balance) begin
                            balance<=balance-withdraw_amount;
                            dispense_cash<=1;
                        end else insufficient_funds<=1;
                    end
                    if(card_remove) state<=WAIT_CARD;
                end
                LOCKED: state<=LOCKED;
                default: state<=WAIT_CARD;
            endcase
        end
    end
    always @(*) locked = (state == LOCKED);
endmodule
