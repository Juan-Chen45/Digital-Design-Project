`timescale 1ns / 1ps

module FrequencyDivider(clk,rst,newclk); 

input clk;   
input rst; 
output newclk;  //new frequency
reg newclk;
reg [30:0] count; 
parameter period = 500000;
always@(posedge clk,negedge rst)  
    begin  
        if(!rst)begin
            count<=0; 
            newclk<=0;   
        end          
        else 
            if(count==((period >> 1) - 1)) 
            begin  
                newclk<=~newclk; 
                count<=0; 
            end  
            else begin
                count <= count+ 1;
            end
    end 
endmodule

