`timescale 1ns/1ps
module traffic_tb;
    reg clk=0,reset=0,pedestrian_request=0;
    wire [2:0] car_light;
    wire walk;
    integer errors=0,i,walk_entries=0;
    reg previous_walk=0;
    pedestrian_traffic_controller #(.RED_CYCLES(2),.GREEN_CYCLES(3),.YELLOW_CYCLES(2),.WALK_CYCLES(2))
        dut(clk,reset,pedestrian_request,car_light,walk);
    always #5 clk=~clk;
    always @(posedge clk) begin
        if(walk && !previous_walk) walk_entries=walk_entries+1;
        previous_walk=walk;
    end
    task tick; begin @(posedge clk); #1; end endtask
    initial begin
        $dumpfile("day2/waves/traffic.vcd"); $dumpvars(0,traffic_tb);
        reset=1; tick; reset=0;
        pedestrian_request=1; tick; pedestrian_request=0;
        for(i=0;i<15;i=i+1) begin
            tick;
            if(walk) begin
                if(car_light!==3'b100) errors=errors+1;
                i=15;
            end
        end
        if(!walk) errors=errors+1;
        pedestrian_request=1; tick; pedestrian_request=0;
        repeat(12) tick;
        if(walk_entries!=1) errors=errors+1;
        if(errors==0) $display("PASS traffic controller serves request and ignores requests during WALK");
        else $display("FAIL traffic errors=%0d",errors);
        $finish;
    end
endmodule
