`timescale 1ns/1ps
module encoder_decoder_tb;
    reg [7:0] request;
    reg enable;
    reg [2:0] code;
    wire v_case,v_if;
    wire [2:0] c_case,c_if;
    wire [7:0] decoded;
    integer i,j,errors=0,expected_code;
    reg expected_valid;
    priority_encoder_casez ec(request,v_case,c_case);
    priority_encoder_if ei(request,v_if,c_if);
    decoder3to8 d(enable,code,decoded);
    initial begin
        $dumpfile("day1/waves/encoder_decoder.vcd"); $dumpvars(0,encoder_decoder_tb);
        for(i=0;i<256;i=i+1) begin
            request=i; expected_valid=(i!=0); expected_code=0;
            for(j=0;j<8;j=j+1) if(i[j]) expected_code=j;
            #1;
            if(v_case!==expected_valid || v_if!==expected_valid ||
               c_case!==expected_code || c_if!==expected_code) errors=errors+1;
        end
        for(i=0;i<8;i=i+1) begin
            enable=1; code=i; #1;
            if(decoded!==(8'b1<<i)) errors=errors+1;
            enable=0; #1;
            if(decoded!==0) errors=errors+1;
        end
        if(errors==0) $display("PASS encoder/decoder; casez and if versions match");
        else $display("FAIL encoder/decoder errors=%0d",errors);
        $finish;
    end
endmodule
