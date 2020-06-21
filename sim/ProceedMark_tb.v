`timescale 1ns / 1ps
module ProceedMark_tb();
reg clk;
reg rst;
reg [3:0] answer;
reg Yes,No;
reg getter;//Whether to start a new round of answering
reg [3:0]row;//Keypad row signal
reg reload;//Overload signal
reg select1;//Player number selection signal
reg select2;//Player number selection signal
wire [3:0]col;//Keypad column signals
wire [7:0]DIG;//Digital tube output signal
wire [7:0]seg_out;//Digital tube enable signal

ProceedMark p (clk, rst,answer,Yes,No,getter,row,reload,select1,select2,col,DIG,seg_out);




initial 
begin
{Yes,No} = 2'b10;
getter = 0;
row = 4'b0010;
reload = 0;
{select1,select2} = 0;
rst = 0;
#5 rst = 1;
#5 getter = 1;
#50 select1 = 1;
#50 select1 = 0;

row = 4'b0001;
select2 = 1;


end




initial
begin
clk = 0;
forever 
    #5 clk = ~clk;
end

initial 
begin

answer = 4'b0;
No = 1'b0;
#10 answer = 4'b0001;
Yes = 1'b1;
#1 Yes = 1'b0;
#10 answer = 4'b0001;
Yes = 1'b1;
#1 Yes = 1'b0;
#10 answer = 4'b0010;
Yes = 1'b1;
#1 Yes = 1'b0;
#10 answer = 4'b0100;
Yes = 1'b1;
#1 Yes = 1'b0;
#10 answer = 4'b1000;
Yes = 1'b1;
#1 Yes = 1'b0;

end

endmodule
