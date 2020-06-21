`timescale 1ns / 1ps
module ShowHello_tb();
reg rst,clk;
wire [7:0] DIG,Y;
ShowHello s (rst,clk,DIG,Y);

initial
begin
clk <= 1;
forever 
 #1 clk <= ~clk;
end

always
begin
   
    rst = 0;
    #2000000rst = 1;
    #100 rst = 0;
    #3000000 $finish;
end

endmodule
