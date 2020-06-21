`timescale 1ns / 1ps

module FrequencyDivider_tb();
    reg clk,rst_n;
    wire newclk;
    FrequencyDivider #(4)  cc (clk,rst_n,newclk);
    initial 
    fork
        clk <= 0;
        rst_n <= 1;
        #1 rst_n <= 0;
        #2 rst_n <= 1;
        forever 
            #5 clk = ~clk;
    join
    
endmodule
