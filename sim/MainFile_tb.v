`timescale 1ns / 1ps

module MainFile_tb();
reg begining;
reg count_down;
reg clk;

reg time_select;

reg Yes;
reg No;
reg [3:0] row;
reg  [3:0] answer;

reg select1;
reg select2;

wire [3:0] col;
wire  [7:0] seg_out,seg_en;
wire  [3:0] answer_led;
wire alarm;
MainFile main(
begining,
count_down,
clk,
time_select,
Yes,No, 
row,
answer,
select1,
select2,
col,
seg_out,seg_en,
answer_led,
alarm);

initial
begin
    clk = 0;
    time_select = 0;
    forever
    begin
        #1 clk = ~clk;
    end
end



initial
begin
{select1,select2} = 2'b00;
row = 0;
{Yes,No} = 2'b10;
#20 {select1,select2} = 2'b01;
end
initial
begin
    {begining,count_down,answer} = 6'b0;
    repeat(63)
        #3 {begining,count_down,answer} = {begining,count_down,answer} + 1;
end

endmodule
