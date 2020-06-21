`timescale 1ns / 1ps

module keyboard_tb( );
reg clk;
reg rst;
reg [3:0]row;
wire key_flag;
wire[3:0] y;
wire [3:0] col;

 KeyBoard k(clk,rst,row,key_flag,y,col);
 
   initial
   begin
       clk = 0;
       rst = 0;
       #10;
       rst = 1; //Reset for a while before starting
   end
   end
   
    always #10 clk=~clk; 
    
    reg [4:0]pnumber; //Key value
    initial
       begin
           pnumber = 16;//No key press
           #10 pnumber = 1;
           #10 pnumber = 16;  //Analog jitter
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10;
           
           pnumber = 1;//Button 1 Press
           #2500 pnumber = 16;  //Simulate jitter on release
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10 pnumber = 16; 
           #2000; //ËÉ¿ª
           
           pnumber = 2;//Button 2 Press
           #2500 pnumber = 16;  //Simulate jitter on release
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10 pnumber = 16; 
           #2000; //ËÉ¿ª
           
           pnumber = 3;//Button 3 Press
           #2500 pnumber = 16;  //Simulate jitter on release
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10 pnumber = 16;
           #10 pnumber = 1;
           #10 pnumber = 16; 
           #2000; //release
       end

       always @(*)
       begin
         case(pnumber)
         0:    row = {1'b1,1'b1,1'b1,col[0]};
         1:    row = {1'b1,1'b1,1'b1,col[1]};
         2:    row = {1'b1,1'b1,1'b1,col[2]}; 
         3:    row = {1'b1,1'b1,1'b1,col[3]};
         
         4:    row = {1'b1,1'b1,col[0],1'b1};
         5:    row = {1'b1,1'b1,col[1],1'b1};
         6:    row = {1'b1,1'b1,col[2],1'b1};
         7:    row = {1'b1,1'b1,col[3],1'b1};
         
         8:    row = {1'b1,col[0],1'b1,1'b1};
         9:    row = {1'b1,col[1],1'b1,1'b1};
         10:    row = {1'b1,col[2],1'b1,1'b1};
         11:    row = {1'b1,col[3],1'b1,1'b1};
         
         12:    row = {col[0],1'b1,1'b1,1'b1};
         13:    row = {col[1],1'b1,1'b1,1'b1};
         14:    row = {col[2],1'b1,1'b1,1'b1};
         15:    row = {col[3],1'b1,1'b1,1'b1};
         
         16:    row = 4'b1111;
         default : row = 4'b1111;
         endcase
       end
       
endmodule


