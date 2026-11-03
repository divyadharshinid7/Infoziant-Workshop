module atm_controller ( 
    input wire clk, 
    input wire rst, 
    input wire card, 
    input wire pin_enter, 
    input wire [15:0] pin, 
    input wire withdraw, 
    input wire amount_enter, 
    input wire [15:0] amount, 
 
    output reg dispense, 
    output reg insufficient, 
    output reg [15:0] balance 
); 
 
    // FSM states 
    parameter IDLE     = 3'b000, 
              PIN_CHECK = 3'b001, 
              SELECT    = 3'b010, 
              AMOUNT    = 3'b011, 
              DISPENSE  = 3'b100, 
              ERROR     = 3'b101; 
 
    reg [2:0] state; 
 
    // State transition logic 
    always @(posedge clk or posedge rst) begin 
        if (rst) begin 
            state <= IDLE; 
            balance <= 16'd5000; 
        end 
        else begin 
            case (state) 
 
                IDLE: begin 
                    if (card) 
                        state <= PIN_CHECK; 
                end 
 
                PIN_CHECK: begin 
                    if (pin_enter) begin 
                        if (pin == 16'd1234) 
                            state <= SELECT; 
                        else 
                            state <= ERROR; 
                    end 
                end 
 
                SELECT: begin 
                    if (withdraw) 
                        state <= AMOUNT; 
                end 
 
                AMOUNT: begin 
                    if (amount_enter) begin 
                        if (amount <= balance) begin 
                            balance <= balance - amount; 
                            state <= DISPENSE; 
                        end 
                        else begin 
                            state <= ERROR; 
                        end 
                    end 
                end 
 
                DISPENSE: begin 
                    state <= IDLE; 
                end 
 
                ERROR: begin 
                    state <= IDLE; 
                end 
 
                default: state <= IDLE; 
 
            endcase 
        end 
    end 
 
    // Output logic 
    always @(*) begin 
        dispense = 0; 
        insufficient = 0; 
 
        case (state) 
            DISPENSE: dispense = 1; 
            ERROR:    insufficient = 1; 
        endcase 
    end 
 
endmodule