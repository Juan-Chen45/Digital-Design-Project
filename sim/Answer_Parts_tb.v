`timescale 1ns / 1ps
module Answer_Parts_tb();
reg clk,rst;
reg [3:0] Answer;
reg reload;
reg begining;
reg true;
reg false;
reg [3:0] row;
reg select1;
reg select2;
wire [3:0]col;
wire [3:0] Answer_led;
wire [7:0]DIG;
wire [7:0]seg_out;
wire getter;
wire alarm;

Answer_Parts a ( clk,
rst,
reload,
begining,
Answer,
true,
false,
row,
select1,
select2,
col,
DIG,
seg_out,
getter,
Answer_led,
alarm);



initial
begin
{select1,select2} = 0;
row = 0;
end

initial
begin
    clk = 0;
    false = 0;
    forever
        #2 clk = ~clk;
end

initial
begin
    Answer = 5'b0;
    repeat(31)
        #50 Answer = Answer + 5'b1;
//    #5 $finish;
end

initial 
begin
    rst = 0;
//    forever
        #1000 rst = ~rst;
end

initial 
begin
    reload = 0;
    begining = 0;
    #5 reload = ~reload;
    begining = ~begining;
end

initial 
begin
    true = 1;
    #500 true= ~true;
end

endmodule
