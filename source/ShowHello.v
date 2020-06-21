`timescale 1ns / 1ps



module ShowHello(rst,clk,DIG,Y);//This module displays the word hello before the game starts
input rst;//Global reset
input clk;//System clock

output [7:0] DIG;//<=>seg_en
output [7:0] Y;//<=> seg_out

reg clkout;
reg [3:0]q4,q3,q2,q1,q0;//Display value of each digit
reg [3:0] q;//Value at the position of the lit nixie tube
reg point;//Decimal point of each nixie tube
wire Hz_100;
wire Hz_1;

reg [31:0] cnt;
reg [2:0] scan_cnt; //Scanning nixie tube
//find 100Hz Clock signal
FrequencyDivider #(500000) d3 (clk,rst,Hz_100);

//find 1Hz Clock signal
FrequencyDivider #(50000000) d4 (clk,rst,Hz_1);

//Beeper bee (clk,alarm_en,1'b1,alarm);

parameter period = 200000;

reg [7:0] Y_r;
reg [7:0] DIG_r;

assign Y = {point,(~Y_r[6:0])};
assign DIG = ~DIG_r;

always @(posedge clk or negedge rst)
//always @(posedge clk)
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



//count time as 100Hz
always@(posedge Hz_100 or negedge rst)
begin
    if(!rst)
    begin
//        alarm_en = 0;
//        alarm_cnt = 0;
            q4 <= 4'b1101;
            q3 <= 4'b1100;
            q2 <= 4'b1011;
            q1 <= 4'b1010;
            q0 <= 4'b0;
//        flag = 0;
    end
    
end

//Scan the digital tube according to clk_out frequency
always @(posedge clkout or negedge rst)
begin
   if (!rst)
   begin
        scan_cnt <= 0;    
   end 
   else 
   begin
      scan_cnt <= scan_cnt + 1;
      if (scan_cnt == 3'b100)
        scan_cnt <= 0; 
   end   
end


//Judging the number of digital tubes
always @(scan_cnt)
begin
    case(scan_cnt)
        3'b000 : DIG_r = 8'b0000_0001;
        3'b001 : DIG_r = 8'b0000_0010;
        3'b010 : DIG_r = 8'b0000_0100;
        3'b011 : DIG_r = 8'b0000_1000;
        3'b100 : DIG_r = 8'b0001_0000;
        3'b101 : DIG_r = 8'b0010_0000;
        3'b110 : DIG_r = 8'b0100_0000;
        3'b111 : DIG_r = 8'b1000_0000;
        default :DIG_r = 8'b0000_0000;
    endcase
end


//Determine the display value of the current scanning diode
always @(scan_cnt)
begin
case(scan_cnt)
    3'b000 : q = q0;
    3'b001 : q = q1;
    3'b010 : q = q2;
    3'b011 : q = q3;
    3'b100 : q = q4;
    default: q = 3'b000;
endcase

end

//Determine if the decimal point is lit

always @(scan_cnt)
begin
case(scan_cnt)
    3'b000 : point = 1;
    3'b001 : point = 1;
    3'b010 : point = 1;
    3'b011 : point = 1;
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
       10: Y_r = 7'b0111000; //L
       11: Y_r = 7'b0111000; //L
       12: Y_r = 7'b1111001; //E
       13: Y_r = 7'b1110110; //H
       14: Y_r = 7'b1010100; //n
       15: Y_r = 7'b1011100; //o
   endcase 
end


endmodule
