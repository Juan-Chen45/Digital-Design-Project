`timescale 1ns / 1ps

module Display_Mark_tb();

reg rst;
reg clk;

reg [3:0] Answer;
reg [3:0]mark_one;
reg [3:0]mark_two;
reg [3:0]mark_three;
reg [3:0]mark_four;
wire [7:0]DIG;
wire [7:0]Y;
Display_Mark dd(rst,clk, Answer,mark_one,mark_two,mark_three,mark_four,DIG,Y);

initial
begin
clk = 0;
forever
 #0.01 clk = ~clk;
end


initial
begin
rst = 0;
#1 rst = 1;
Answer = 0;
mark_one = 0;
mark_two = 0;
mark_three = 0;
mark_four = 0;
repeat(2)
begin
#10
Answer = Answer + 1;
mark_one = mark_one + 1;
mark_two = mark_two + 1;
mark_three = mark_three + 1;
mark_four = mark_four + 1;
end
#10 $finish;
end

endmodule
