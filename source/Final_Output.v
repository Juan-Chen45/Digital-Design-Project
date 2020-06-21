`timescale 1ns / 1ps

module Final_Output(
input select1,
input select2,

input[3:0] winner,//Used to indicate who the winner is, 0001, 0010, 0100, 1000
input reset,//Used to indicate whether this module is enabled, that is, whether a game ends and the score is displayed.

//4 people score up to 10
input[3:0] score1,
input[3:0] score2,
input[3:0] score3,
input[3:0] score4,

input clk,//System clock signal with a frequency of 100MHz

output reg[7:0] seg_en,//Seven-segment tube enable
output reg[7:0] seg_out//Seven-segment tube output result Represents a number output by a seven-segment tube, and the digit 7 represents a point.

    );

reg clk_after_div;//Clock signal after frequency division
reg[31:0] div_counter;//Counters used during frequency division
parameter period = 100000;//Divide multiples, that is, multiples that slow down the original signal

reg[2:0] scan_cnt;//Seven-segment tube scan signal

reg[31:0] display_counter;//Used to count in the display module to achieve the effect of delay. (Lights up for a while, turns off for a while)
reg ifLight = 0;//Used to indicate in the display module whether the flash is blinking or off
parameter display_time = 1000;//The total clock period of the signal after frequency division is used to delay. The larger the number, the longer the word blinking interval.
reg[3:0] display_content;//It is used to indicate what the currently displayed seven-segment digital tube displays, the range is 0-15, which is decoded into the output result of seg_out in the decoder.

//Seven-segment tube scanning circuit
always @(posedge clk_after_div or negedge reset)//Scans the next bit when the clock signal rises after each frequency division, and resets every time the falling edge of rst
begin
	if (~reset)
	begin
		scan_cnt <= 0;    
	end
	else 
	begin
		scan_cnt <= scan_cnt + 1;
		if (scan_cnt == 3'b111)
		begin
			scan_cnt <= 0; 
		end
	end   
end

//·ÖÆµÆ÷µçÂ·
always @(posedge clk)
begin
	if(reset)
	begin
		if(div_counter == (period >> 1) - 1)
		begin
			div_counter <= 32'b0;
			clk_after_div <= ~clk_after_div;
		end
		else
			div_counter <= div_counter + 32'b1;
	end
	else
	begin
	        div_counter <= 32'b0;
	        clk_after_div <= 0;
    end
end

//The module that determines which digital tube is lit by the scan_cnt mapping
always @(scan_cnt)
begin
    case(scan_cnt)
        3'b000 : seg_en = 8'b01111_111;//The first digital tube is enabled, counting from right to left
        3'b001 : seg_en = 8'b11111_110;//The second digital tube is enabled, counting from right to left
        3'b010 : seg_en = 8'b11111_101;//The third digital tube is enabled, counting from right to left
        3'b011 : seg_en = 8'b11111_011;//The fourth digital tube is enabled, counting from right to left
        3'b100 : seg_en = 8'b11110_111;//The fifth digital tube is enabled, counting from right to left
        3'b101 : seg_en = 8'b11101_111;//The sixth digital tube is enabled, counting from right to left
        3'b110 : seg_en = 8'b11011_111;//The seventh digital tube is enabled, counting from right to left
        3'b111 : seg_en = 8'b10111_111;//The 8th digital tube is enabled, counting from right to left
        default :seg_en = 8'b11111_111;//None by default
    endcase
end

//Display module
always @(posedge clk_after_div or negedge reset)//Detect once per clock cycle, which is equivalent to one increment of display_counter per clock cycle
begin
	if(~reset)//When reset, the display module is off, the display module counter is reset to 0, and the display content is empty.
	begin
		display_counter <= 0;
        display_content <= 15;
	end
	else
	begin
	    ////////////////////////////////////////////////////////////////
	    //A bright once
		if(display_counter < display_time)
		begin
			display_counter <= display_counter + 1;
			if(score1 >= 10)                                       
            begin                                                  
                case(scan_cnt)                                     
                    3'b000 : display_content = 0;//Low score            
                    3'b001 : display_content = 1;//High score            
                    3'b111 : display_content = 10;//N              
                    3'b110 : display_content = 11;//O              
                    3'b101 : display_content = 1;//Number of players           
                    default: display_content = 15;                 
                endcase                                            
            end                                                    
            else                                                   
            begin                                                  
                case(scan_cnt)                                     
                    3'b000 : display_content = score1;//Low score       
                    3'b001 : display_content = 0;//High score            
                    3'b111 : display_content = 10;//N              
                    3'b110 : display_content = 11;//O              
                    3'b101 : display_content = 1;//Number of players           
                    default: display_content = 15;                 
                endcase                                            
            end                                                    
		end
		//A off once
		if(display_counter >= display_time && display_counter < 2 * display_time)
		begin
			display_content = 15;
			display_counter <= display_counter + 1;
		end
		//A bright 2 times
        if(display_counter >= 2 * display_time && display_counter < 3 * display_time)
        begin
            display_counter <= display_counter + 1;   
            if(score1 >= 10) 
            begin
                case(scan_cnt)
                    3'b000 : display_content = 0;//Low score     
                    3'b001 : display_content = 1;//High score
                    3'b111 : display_content = 10;//N         
                    3'b110 : display_content = 11;//O         
                    3'b101 : display_content = 1;//Number of players      
                    default: display_content = 15;            
                endcase  
            end
            else
            begin
                case(scan_cnt)                             
                    3'b000 : display_content = score1;//Low score    
                    3'b001 : display_content = 0;//High score   
                    3'b111 : display_content = 10;//N        
                    3'b110 : display_content = 11;//O        
                    3'b101 : display_content = 1;//Number of players     
                    default: display_content = 15;           
                endcase                                      
            end    
        end
        //
        if(display_counter >= 3 * display_time && display_counter < 4 * display_time)
        begin
            display_content = 15;
            display_counter <= display_counter + 1;
        end
        //////////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////////////////////
        
        if(display_counter >= 4 * display_time && display_counter < 5 * display_time)
        begin
            display_counter <= display_counter + 1;
            if(score2 >= 10)                                     
            begin                                                
                case(scan_cnt)                                   
                    3'b000 : display_content = 0;//Low score          
                    3'b001 : display_content = 1;//High score          
                    3'b111 : display_content = 10;//N            
                    3'b110 : display_content = 11;//O            
                    3'b101 : display_content = 2;//Number of players         
                    default: display_content = 15;               
                endcase                                          
            end                                                  
            else                                                 
            begin                                                
                case(scan_cnt)                                   
                    3'b000 : display_content = score2;//Low score     
                    3'b001 : display_content = 0;//High score          
                    3'b111 : display_content = 10;//N            
                    3'b110 : display_content = 11;//O            
                    3'b101 : display_content = 2;//Number of players         
                    default: display_content = 15;               
                endcase                                          
            end                                                  
        end
        
        if(display_counter >= 5 * display_time && display_counter < 6 * display_time)
        begin
            display_content = 15;
            display_counter <= display_counter + 1;
        end
        
        if(display_counter >= 6 * display_time && display_counter < 7 * display_time)
        begin
            display_counter <= display_counter + 1;
            if(score2 >= 10)                                     
            begin                                                
                case(scan_cnt)                                   
                    3'b000 : display_content = 0;//Low score          
                    3'b001 : display_content = 1;//High score          
                    3'b111 : display_content = 10;//N            
                    3'b110 : display_content = 11;//O            
                    3'b101 : display_content = 2;//Number of players         
                    default: display_content = 15;               
                endcase                                          
            end                                                  
            else                                                 
            begin                                                
                case(scan_cnt)                                   
                    3'b000 : display_content = score2;//Low score     
                    3'b001 : display_content = 0;//High score          
                    3'b111 : display_content = 10;//N            
                    3'b110 : display_content = 11;//O            
                    3'b101 : display_content = 2;//Number of players         
                    default: display_content = 15;               
                endcase                                          
            end                                                   
        end
        
        if(display_counter >= 7 * display_time && display_counter < 8 * display_time)
        begin
            display_content = 15;
            display_counter <= display_counter + 1;
        end
        //////////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////////////////////
		if(~select2)
		begin
        
        if(display_counter >= 8 * display_time && display_counter < 9 * display_time)
        begin
            display_counter <= display_counter + 1;
            if(score3 >= 10)                                     
            begin                                                
                case(scan_cnt)                                   
                    3'b000 : display_content = 0;//Low score          
                    3'b001 : display_content = 1;//High score          
                    3'b111 : display_content = 10;//N            
                    3'b110 : display_content = 11;//O            
                    3'b101 : display_content = 3;//Number of players         
                    default: display_content = 15;               
                endcase                                          
            end                                                  
            else                                                 
            begin                                                
                case(scan_cnt)                                   
                    3'b000 : display_content = score3;//Low score     
                    3'b001 : display_content = 0;//High score          
                    3'b111 : display_content = 10;//N            
                    3'b110 : display_content = 11;//O            
                    3'b101 : display_content = 3;//Number of players         
                    default: display_content = 15;               
                endcase                                          
            end                                                  
        end
        
        if(display_counter >= 9 * display_time && display_counter < 10 * display_time)
        begin
            display_content = 15;
            display_counter <= display_counter + 1;
        end
        
        if(display_counter >= 10 * display_time && display_counter < 11 * display_time)
        begin
            display_counter <= display_counter + 1;
            if(score3 >= 10)                                            
            begin                                                       
                case(scan_cnt)                                          
                    3'b000 : display_content = 0;//Low score                 
                    3'b001 : display_content = 1;//High score                 
                    3'b111 : display_content = 10;//N                   
                    3'b110 : display_content = 11;//O                   
                    3'b101 : display_content = 3;//Number of players                
                    default: display_content = 15;                      
                endcase                                                 
            end                                                         
            else                                                        
            begin                                                       
                case(scan_cnt)                                          
                    3'b000 : display_content = score3;//Low score            
                    3'b001 : display_content = 0;//High score                 
                    3'b111 : display_content = 10;//N                   
                    3'b110 : display_content = 11;//O                   
                    3'b101 : display_content = 3;//Number of players                
                    default: display_content = 15;                      
                endcase                                                 
            end                                                         
        end
        
        if(display_counter >= 11 * display_time && display_counter < 12 * display_time)
        begin
            display_content = 15;
            display_counter <= display_counter + 1;
        end
        end

		
		//////////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////////////////////
		
		if(~select1 && ~ select2)
			begin
			
			if(display_counter >= 12 * display_time && display_counter < 13 * display_time)
			begin
				display_counter <= display_counter + 1;
				if(score4 >= 10)                                            
					begin                                                       
						case(scan_cnt)                                          
							3'b000 : display_content = 0;//Low score                 
							3'b001 : display_content = 1;//High score                 
							3'b111 : display_content = 10;//N                   
							3'b110 : display_content = 11;//O                   
							3'b101 : display_content = 4;//Number of players                
							default: display_content = 15;                      
						endcase                                                 
					end                                                         
					else                                                        
					begin                                                       
						case(scan_cnt)                                          
							3'b000 : display_content = score4;//Low score            
							3'b001 : display_content = 0;//High score                 
							3'b111 : display_content = 10;//N                   
							3'b110 : display_content = 11;//O                   
							3'b101 : display_content = 4;//Number of players                
							default: display_content = 15;                      
						endcase                                                 
					end                                                         
			end
			
			if(display_counter >= 13 * display_time && display_counter < 14 * display_time)
			begin
				display_content = 15;
				display_counter <= display_counter + 1;
			end
			
			if(display_counter >= 14 * display_time && display_counter < 15 * display_time)
			begin
				display_counter <= display_counter + 1;
				if(score4 >= 10)                                           
					begin                                                  
						case(scan_cnt)                                     
							3'b000 : display_content = 0;//Low score            
							3'b001 : display_content = 1;//High score            
							3'b111 : display_content = 10;//N              
							3'b110 : display_content = 11;//O              
							3'b101 : display_content = 4;//Number of players           
							default: display_content = 15;                 
						endcase                                            
					end                                                    
					else                                                   
					begin                                                  
						case(scan_cnt)                                     
							3'b000 : display_content = score4;//Low score       
							3'b001 : display_content = 0;//High score            
							3'b111 : display_content = 10;//N              
							3'b110 : display_content = 11;//O              
							3'b101 : display_content = 4;//Number of players           
							default: display_content = 15;                 
						endcase                                            
					end                                                       
			end
			
			if(display_counter >= 15 * display_time && display_counter < 16 * display_time)
			begin
            display_content = 15;
            display_counter <= display_counter + 1;
        end
			end
		
		//////////////////////////////////////////////////////////////////
        
        /////////Final residency display results///////////////////////////////////////////
		if(~select1 && ~select2)
			begin
			if(display_counter >= 16 * display_time)
				begin
					if(winner == 4'b0001)
					begin
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 1;//Number of players         
							default: display_content = 15;               
						endcase   
					end
					
					if(winner == 4'b0010)
					begin
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 2;//Number of players         
							default: display_content = 15;               
						endcase                                          
					end
					
					if(winner == 4'b0100)
					begin                
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 3;//Number of players         
							default: display_content = 15;               
						endcase                                                               
					end        
					
					if(winner == 4'b1000) 
					begin                 
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 4;//Number of players         
							default: display_content = 15;               
						endcase                                                                
					end                                 
				end	
			end
		
		if(select1 && ~select2) 
			begin
			if(display_counter >= 12 * display_time)
				begin
					if(winner == 4'b0001)
					begin
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 1;//Number of players         
							default: display_content = 15;               
						endcase   
					end
					
					if(winner == 4'b0010)
					begin
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 2;//Number of players         
							default: display_content = 15;               
						endcase                                          
					end
					
					if(winner == 4'b0100)
					begin                
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 3;//Number of players         
							default: display_content = 15;               
						endcase                                                               
					end        
					
					if(winner == 4'b1000) 
					begin                 
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 4;//Number of players         
							default: display_content = 15;               
						endcase                                                                
					end                                 
				end	
			end
		
		if(select1 && select2)
		begin
			if(display_counter >= 8 * display_time)
				begin
					if(winner == 4'b0001)
					begin
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 1;//Number of players         
							default: display_content = 15;               
						endcase   
					end
					
					if(winner == 4'b0010)
					begin
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 2;//Number of players         
							default: display_content = 15;               
						endcase                                          
					end
					
					if(winner == 4'b0100)
					begin                
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 3;//Number of players         
							default: display_content = 15;               
						endcase                                                               
					end        
					
					if(winner == 4'b1000) 
					begin                 
						case(scan_cnt)                                   
							3'b000 : display_content = 0;//Low score          
							3'b001 : display_content = 1;//High score          
							3'b111 : display_content = 10;//N            
							3'b110 : display_content = 11;//O            
							3'b101 : display_content = 4;//Number of players         
							default: display_content = 15;               
						endcase                                                                
					end                                 
				end	
			end
		
		////////////////////////////////////////////////////////////////
	end	
end

//Seven-segment digital tube display content decoder, decodes display_content to seven-segment display circuit
always @(scan_cnt)
begin
   case (display_content)
       0 : seg_out = 8'b11000000; //0 or O
       1 : seg_out = 8'b11111001; //1
       2 : seg_out = 8'b10100100; //2
       3 : seg_out = 8'b10110000; //3
       4 : seg_out = 8'b10011001; //4
       5 : seg_out = 8'b10010010; //5
       6 : seg_out = 8'b10000010; //6
       7 : seg_out = 8'b11011000; //7
       8 : seg_out = 8'b10000000; //8
       9 : seg_out = 8'b10011000; //9
       10: seg_out = 8'b11001000; //N
       11: seg_out = 8'b01000000; //O.
       12: seg_out = 8'b11111001; //C
       13: seg_out = 8'b11110110; //D
       default: seg_out = 8'b11111111;
   endcase 
end

endmodule
