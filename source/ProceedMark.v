`timescale 1ns / 1ps
module ProceedMark(//Score addition and subtraction module, this module is used to add and subtract points while determining whether the game is over
 input clk,//System clock
 input rst,//Global reset
 input [3:0] answer,//Answerer
 input Yes,No,//True or false
 input getter,//Whether to start a new round of answering
 input [3:0]row,//Keypad line signal
 input reload,//Overload signal
 input select1,//Player number selection signal
 input select2,//Player number selection signal
 output [3:0]col,//Keypad column signals
 output reg [7:0]DIG,//Digital tube output signal
 output reg [7:0]seg_out//Digital tube enable signal
    );

    reg [3:0] mark_one = 4'b0000,mark_two = 4'b0000,mark_three = 4'b0000,mark_four = 4'b0000;
    wire[3:0] y;
    wire Hz_100;
    wire flag;
    reg rstflag = 0 ;
    
    reg [3:0]winner;//which one is the finnal winner
    reg begg;//begin the final output
    wire [7:0]DIG1,DIG2,seg_out1,seg_out2;
	

   FrequencyDivider #(100000000) d6 (clk,rst,Hz_100);
   //used to display players' mark when the push the butt to answer questions
   Display_Mark displaymark(getter,clk,answer,mark_one,mark_two,mark_three,mark_four,DIG1,seg_out1);
   KeyBoard keyboard (clk,1'b1,row,flag,y,col);
   //used to show final output  with every players mark
   Final_Output finaloutput (select1,select2,winner,begg,mark_one,mark_two,mark_three,mark_four,clk,DIG2,seg_out2);

//to find out which should be the segments output
always@(rst,begg,getter)
begin
    if(begg)
    begin
        seg_out = seg_out2;
        DIG = DIG2;
    end
    else
    begin
        seg_out = seg_out1;
        DIG = DIG1;
    end
end




always@(posedge Hz_100,negedge rst)
//to check if someone has 10 marks
begin 
if(~rst)
begin
mark_one <= 4'b0000;
mark_two <= 4'b0000;
mark_three <= 4'b0000;
mark_four <= 4'b0000;
winner <= 4'b0000;
begg <= 1'b0;
end
else
begin

if(mark_one >= 4'b1010)
 begin
 winner <= 4'b0001;
 mark_one <= 4'b1010;
 begg <= 1;
end

if(mark_two >= 4'b1010)
begin
winner <= 4'b0010;
 mark_two <= 4'b1010;
begg <= 1;   
end  

if(mark_three >= 4'b1010)
begin
winner <= 4'b0100;
 mark_three <= 4'b1010;
begg <= 1;   
end      

if(mark_four >= 4'b1010)
begin
winner <= 4'b1000;
 mark_four <= 4'b1010;
begg <= 1;   
end  
//add or subtract marks
if(Yes) 
       begin
                   case(answer) 
                       4'b0001:
                       begin
                       mark_one <= mark_one + y;              
                       end
                        4'b0010 : 
                       begin
                       mark_two <= mark_two + y;                     
                       end
                        4'b0100 : 
                       begin
                       mark_three <= mark_three + y;       
                       end
                        4'b1000 : 
                       begin
                       mark_four <= mark_four + y;
                       end
                   endcase
           end
  
else 
begin 
if(No)
begin
case(answer) 
                4'b0001 : 
                begin
                    mark_one <= mark_one - y;
                end
                4'b0010 : 
                begin
                    mark_two <= mark_two - y;
                end
                4'b0100 : 
                begin
                    mark_three <= mark_three - y;
                end
                4'b1000 :
                begin
                    mark_four <= mark_four - y;
                end
            endcase
        end
     end
end

end
endmodule
