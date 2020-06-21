`timescale 1ns / 1ps


module Display_Mark(
input rst,
input clk,

input [3:0] Answer,
input [3:0]mark_one,//players' mark
input [3:0]mark_two,
input [3:0]mark_three,
input [3:0]mark_four,
output [7:0]DIG,//seg_en
output [7:0]Y//seg_out

);
reg clkout;
reg[31:0] cnt;
reg [2:0] scan_cnt;  //Scanning which tube
reg point;//Decimal point of each nixie tube
parameter period = 200000;
reg [7:0]  Y_r;
reg [7:0]  DIG_r;
reg [3:0] mark;
reg [3:0]  q;
reg [3:0] answerBoy;//the one who answer the question
reg [3:0] keepAnswer;//also the one who answer the question but its for other uses

   
assign Y = {point,(~Y_r[6:0])};
assign DIG = ~DIG_r;

always@(posedge clk)
begin
keepAnswer <= Answer;
end
//check the answerer
always@ (posedge clkout)//keepAnswer,mark_one,mark_two,mark_three,mark_four
begin
    case(keepAnswer)
        4'b0001 :
        begin
            mark <= mark_one;
            answerBoy <= 4'b0001;
        end
        4'b0010 : 
        begin
            mark <= mark_two;
            answerBoy <= 4'b0010;
        end
        4'b0100 : 
        begin
            mark <= mark_three;
            answerBoy <= 4'b0011;
        end
        4'b1000 :
        begin
            mark <= mark_four;
            answerBoy <= 4'b0100;
        end
        default : 
        begin 
        mark <= 4'b0;
        answerBoy <= 4'b0000;
        end
    endcase
end



//embeded frequency divider
always @(posedge clk or negedge rst)
//always @(posedge clk)
begin
    if((~rst))
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
            cnt <= cnt + 32'b1;
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
        if (scan_cnt >= 3'b100)
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
    3'b000 : 
    begin
        case(mark)
            0 : q = 4'd0;
            1 : q = 4'd1;
            2 : q = 4'd2;
            3 : q = 4'd3;
            4 : q = 4'd4;
            5 : q = 4'd5;
            6 : q = 4'd6;
            7 : q = 4'd7;
            8 : q = 4'd8;
            9 : q = 4'd9;
            10: q = 4'd0;
            default: q = 4'd0;
        endcase;
    end
    3'b001 :
        begin
            case(mark)
                10: q = 4'd1;
                default: q = 4'd0;
            endcase;
        end
    3'b010 : q = answerBoy;
    3'b011 : q = 4'b1111;//15
    3'b100 : q = 4'b1110;//14
    default: q = 4'b0000;
endcase
end

//Determine if the decimal point is lit

always @(scan_cnt)
begin
case(scan_cnt)
    3'b000 : point = 1;
    3'b001 : point = 1;
    3'b010 : point = 0;
    3'b011 : point = 1;
    3'b100 : point = 1;
    3'b101 : point = 1;
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
       14: Y_r = 7'b0110111; //n
       15: Y_r = 7'b0111111; //o
       default: Y_r = 7'b0000000;
   endcase 
end
    
endmodule
