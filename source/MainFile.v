`timescale 1ns / 1ps

module MainFile(
input begining,//the whole beginning and reset
input count_down,//to start count_down
input clk,//clock signal

input time_select,//to select if its 30s or 20s

input Yes,No, //to determine if the answer is right or wrong
input [3:0] row,//used for keeyboard
input  [3:0] answer,//used to determine the answerer

input select1,//to select the number of players
input select2,

output [3:0] col,//for keyboard
output  [7:0] seg_out,seg_en,
output  [3:0] answer_led,//which one to answer
output alarm//beeper
);

reg enable_counting,enable_answer;
wire alarm1,alarm2;
wire getter;//if someone answer the question ,it will turn to 1
reg [7:0]seg_out,seg_en;
wire [7:0]seg_out1;
wire [7:0]seg_out2;
wire [7:0]seg_out3;
wire [7:0]seg_en1;
wire [7:0]seg_en2;
wire [7:0]seg_en3;
wire Hz_100;
wire ifOver;

    //make submodules
	//1.to countDown with time
	//2.to proceed answer
	//3. to show hello before game
    //4.FrequencyDivider
    CountDown countDown (begining  & ~getter & count_down,clk,time_select,seg_en1,seg_out1,alarm1,ifOver);
    Answer_Parts answerpart(clk,enable_answer&~ifOver,count_down,begining,answer,Yes,No,row,select1,select2,col,seg_en2,seg_out2,getter,answer_led,alarm2);
    ShowHello showhello(begining && ~count_down,clk,seg_en3,seg_out3);
    FrequencyDivider #(500000) d5 (clk,begining,Hz_100);
    




initial begin
        enable_counting = 0;
        enable_answer=0;
   end 

assign alarm = alarm1 | alarm2;


//some logical calculation to control the submodules
always@(begining,count_down,getter)
begin
    if(~begining & ~count_down)
    begin
        seg_out = 8'b11111111;
        seg_en = 8'b11111111;
    end
    else
    begin
    if (~getter) begin
            if(~count_down)
            begin
                    seg_out = seg_out3;
                    seg_en = seg_en3;
            end
            else
            begin
            seg_out = seg_out1;
            seg_en = seg_en1;
            end
            
        end
        else if(getter)
        begin
            seg_out = seg_out2;
            seg_en = seg_en2;
        end
        else 
        begin
            seg_out =8'b0;
            seg_en = 8'b10000000;
        end
    end
end

//some logical calculation to control the submodules
always @(count_down,getter)
begin 
if(count_down) 
begin
    if(~getter) begin
        enable_answer = 1;
        enable_counting = 1;
    end
    else begin
        enable_answer = 0;
        enable_counting = 0;
    end
end
else begin 
    enable_answer = 0;
    enable_counting = 0;
end
end







   
endmodule
