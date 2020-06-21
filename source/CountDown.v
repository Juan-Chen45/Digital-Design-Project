`timescale 1ns / 1ps



module CountDown(rst,clk,time_select,DIG,Y,alarm,ifOver);
input rst;//Global reset
input clk;//System clock
input time_select; //Time selection signal 20s or 30s

output [7:0] DIG;//Digital tube enable
output [7:0] Y;//Digital tube output
output alarm;//Buzzer output signal
output reg ifOver;//Whether this round of answering is over, that is, whether the countdown is over
reg clkout;
reg [3:0]q3,q2,q1,q0;//Display value of each digit
reg [3:0] q;//Value at the position of the lit  tube
reg point;//Decimal point of each tube
wire Hz_100;
wire Hz_1;
reg alarm_en;//Buzzer enable signal
reg flag;//Determine if the buzzer sounds again
reg [1:0]alarm_cnt;
//reg alarms;
wire alarm1,alarm2;
reg [31:0] cnt;
reg [3:0] scan_cnt; //the tube being scanning 


//find 100Hz Clock signal
FrequencyDivider #(500000) d0 (clk,rst,Hz_100);

//find 1Hz Clock signal
FrequencyDivider #(50000000) d1 (clk,rst,Hz_1);

LiangZhu backgroundMusic (clk,rst & ~ifOver ,alarm2);
Beeper beeper1 (clk,alarm_en,1'b1,alarm1);

parameter period = 200000;

reg [7:0] Y_r;
reg [7:0] DIG_r;

assign Y = {point,(~Y_r[6:0])};
assign alarm = alarm_en == 1? alarm1:alarm2;
assign DIG = ~DIG_r;
// embeded frequency divider
always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        cnt <= 0;
        clkout <= 0;
    end
    else begin
        if(cnt == (period >> 1) - 1)
        begin
            clkout <= ~clkout;
            cnt <= 0; 
        end
        else
            cnt <= cnt + 1;
    end
end

//initial time
initial
begin
    alarm_en <= 0;
    alarm_cnt = 0;
    q2 <= 4'b0;
    q1 <= 4'b0;
    q0 <= 4'b0;
    flag <= 0;
    scan_cnt <= 4'b1100;
    ifOver = 1'b0;
end


//for calculating the number output for countdown
always@(posedge Hz_100 or negedge rst)
begin
    if(~rst)
    begin
        alarm_en <= 0;
        alarm_cnt <= 0;
        if(time_select == 1)
        begin
            q3 <= 4'b0011;
        end
        else
        begin
            q3 <= 4'b0010;
        end
        q2 <= 4'b0;
        q1 <= 4'b0;
        q0 <= 4'b0;
        flag <= 0;
        ifOver <= 1'b0;
    end
    else
    begin
        if(q3== 4'b0 && q2== 4'b0 && q1== 4'b0 && q0== 4'b0) 
        begin
        ifOver <= 1'b1;
            if(flag == 0)
            begin
                alarm_en <= 1;
                if(Hz_1) begin
                   alarm_cnt <= alarm_cnt + 1;
                end
                if(alarm_cnt == 2'b10) begin
                    alarm_en <= 0;
                    flag <= 1;
                end
            end
            
//            #2 alarm_en = 0;
        end
        else if(q0 == 0)
        begin
            if(q1 == 0) begin
                if(q2 == 0) begin
                    q3 <= q3 - 4'b0001;
                    q2 <= 4'b1001;
                    q1 <= 4'b1001;
                    q0 <= 4'b1001;
                end
                else begin
                    q2 <= q2 - 4'b001;
                    q1 <= 4'b1001;
                    q0 <= 4'b1001;
                end
            end
            else begin
                q1 <= q1 - 4'b0001;
                q0 <= 4'b1001;
            end
        end
        else begin
                q0 <= q0 - 4'b0001;
        end
    end
        
end

//Scan the digital tube according to clk_out frequency
always @(posedge clkout or negedge rst)
begin
   if (~rst)
   begin
        scan_cnt <= 4'b1100;    
   end 
   else 
   begin
      scan_cnt <= scan_cnt + 1;
      if (scan_cnt >= 4'b011)
        scan_cnt <= 0; 
   end   
end


//Judging the number of digital tubes
always @(scan_cnt)
begin
    case(scan_cnt)
        4'b000 : DIG_r = 8'b0000_0001;
        4'b001 : DIG_r = 8'b0000_0010;
        4'b010 : DIG_r = 8'b0000_0100;
        4'b011 : DIG_r = 8'b0000_1000;
        4'b100 : DIG_r = 8'b0001_0000;
        4'b101 : DIG_r = 8'b0010_0000;
        4'b110 : DIG_r = 8'b0100_0000;
        4'b111 : DIG_r = 8'b1000_0000;
        default :DIG_r = 8'b0000_0000;
    endcase
end


//Determine the display value of the current scanning diode
always @(scan_cnt)
begin
case(scan_cnt)
    4'b000 : q = q0;
    4'b001 : q = q1;
    4'b010 : q = q2;
    4'b011 : q = q3;
    default: q = 3'b000;
endcase

end

//Determine if the decimal point is lit

always @(scan_cnt)
begin
case(scan_cnt)
    4'b000 : point = 1;
    4'b001 : point = 1;
    4'b010 : point = 0;
    4'b011 : point = 1;
    default: point = 1;
endcase

end

//set the seg with q

always @(scan_cnt)
begin
   case (q)
       0 : Y_r = 7'b0111111; //0
       1 : Y_r = 7'b0000110; //1
       2 : Y_r = 7'b1011011; //2
       3 : Y_r = 7'b1001111; //3
       4 : Y_r = 7'b1100110; //4
       5 : Y_r = 7'b1101101; //5
       6 : Y_r = 7'b1111101; //6
       7 : Y_r = 7'b0100111; //7
       8 : Y_r = 7'b1111111; //8
       9 : Y_r = 7'b1100111; //9
       10: Y_r = 7'b1110111; //A
       11: Y_r = 7'b1111100; //B
       12: Y_r = 7'b0111001; //C
       13: Y_r = 7'b1011110; //D
       14: Y_r = 7'b1111001; //E
       15: Y_r = 7'b1110001; //F
       default: Y_r = 7'b0000000;
   endcase 
end


endmodule

