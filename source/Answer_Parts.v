`timescale 1ns / 1ps

module Answer_Parts(
input clk,//input clock signal

input rst,//used to reset the round
input reload,//another reset signal
input beginNew,//used to reload the mark
input [3:0] Answer,//which one to answer
input Yes,//to determine the answer is right or wrong
input No,


input  [3:0] row,//used in keyboard
input select1,//used to select number of players
input select2,
output [3:0] col,//used in keyboard

output [7:0]DIG,//seg_en
output [7:0]seg_out,
output reg getter,//when someone answer the question,it turns to 1
output reg [3:0] led,//notify that someone has already answer the question and who
output alarm//for music and beep
);


reg [3:0] alarm_cnt;//used to determine the timescale for alarm
reg alarm_en;//if the alarm work
reg flag;//if the alarm has already worked

reg tone_en ;//used for beeper
wire Hz_100;
wire Hz_1;



initial
begin
tone_en = 1;
flag = 0;
alarm_cnt = 4'b0000;
alarm_en = 0;
;
getter = 1'b0;

end



//find 1Hz Clock signal
FrequencyDivider #(50000000) d2 (clk,getter,Hz_1);
FrequencyDivider #(50000000) d3 (clk,getter,Hz_100);
Beeper beeper2 (clk,alarm_en,tone_en,alarm);

ProceedMark proceedmark (clk,beginNew,led,Yes,No,getter,row,reload,select1,select2,col,DIG,seg_out);

//reset
always@(posedge clk or negedge rst)
begin
    if((~rst & ~getter) | ~beginNew) begin
        flag <= 0;
        alarm_cnt <= 4'b0000;
        alarm_en <= 0;
        led <= 4'b0000;
        getter <= 1'b0;

    end
    else if((~rst & ~getter) | ~reload) begin
        flag <= 0;
        alarm_cnt <= 4'b0000;
        alarm_en <= 0;
        led <= 4'b0000;
        getter <= 1'b0;
    end
	//determine the answer
    else begin
    if(getter) begin
        if(flag == 0) begin
           alarm_en <= 1;
           if(Hz_1) begin
               alarm_cnt <= alarm_cnt + 1;
           end
            if(alarm_cnt >= 4'b1000) begin
               alarm_en <= 0;
               flag <= 1;
               alarm_cnt <=4'b0000;
           end
        end
       if(Answer == 4'b0000)begin
       end
  end
 else
 begin
            case(Answer)
                4'b0001: 
                    begin 
                        led <= 4'b0001; 
                        getter <= 1'b1; 
                    end
                4'b0010: 
                    begin 
                        led <= 4'b0010;
                        getter <= 1'b1; 
                    end
                4'b0100: 
                    begin 
                       led <= 4'b0100; 
                        getter <= 1'b1; 
                    end
                4'b1000: 
                    begin 
                        led <= 4'b1000;
                         getter <= 1'b1; 
                    end
                4'b0000:
                    begin
                        led <= 4'b0000; 
                    end
                default: led <= led;
            endcase
        end
end
end
endmodule
