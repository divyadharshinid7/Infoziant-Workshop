module pedestrian_traffic_controller #(
    parameter RED_CYCLES = 5,
    parameter GREEN_CYCLES = 5,
    parameter YELLOW_CYCLES = 2,
    parameter WALK_CYCLES = 3
) (
    input wire clk,
    input wire reset,
    input wire pedestrian_request,
    output reg [2:0] car_light,
    output reg walk
);
    localparam RED=0, GREEN=1, YELLOW=2, WALK=3;
    localparam RED_LIGHT=3'b100, YELLOW_LIGHT=3'b010, GREEN_LIGHT=3'b001;
    reg [1:0] state;
    reg [15:0] timer;
    reg pedestrian_pending;
    reg [15:0] duration;

    always @(*) begin
        case(state)
            RED: duration=RED_CYCLES;
            GREEN: duration=GREEN_CYCLES;
            YELLOW: duration=YELLOW_CYCLES;
            default: duration=WALK_CYCLES;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= RED; timer <= 0; pedestrian_pending <= 0;
        end else begin
            if (state != WALK && pedestrian_request)
                pedestrian_pending <= 1;
            if (timer + 1 >= duration) begin
                timer <= 0;
                case(state)
                    RED: state <= GREEN;
                    GREEN: state <= YELLOW;
                    YELLOW: begin
                        if (pedestrian_pending || pedestrian_request) begin
                            state <= WALK;
                            pedestrian_pending <= 0;
                        end else state <= RED;
                    end
                    default: state <= RED;
                endcase
            end else timer <= timer + 1'b1;
        end
    end

    always @(*) begin
        walk = (state == WALK);
        case(state)
            GREEN: car_light=GREEN_LIGHT;
            YELLOW: car_light=YELLOW_LIGHT;
            default: car_light=RED_LIGHT;
        endcase
    end
endmodule
