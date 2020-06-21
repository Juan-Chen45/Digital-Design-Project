`timescale 1ns / 1ps
module Beeper
(
input					clk_in,		//System clock
input					rst_n_in,	//System reset, low active
input					tone_en,	//Buzzer enable signal
output	reg				piano_out	//Buzzer control output
);
/*
Passive buzzers can emit different syllables, which are related to the frequency of the buzzer vibration (equal to the frequency of the buzzer control signal),
In order to make the buzzer control signal generate different frequencies, we use a counter to count (divide) to achieve. Different syllable controls correspond to different final count values (frequency division coefficient).
The counter counts and divides according to the final count value and generates a buzzer control signal
*/
wire [4:0]	tone;		//Buzzer syllable control
assign tone = 5'b00001;
reg [15:0] time_end;
//According to different syllable control, select the corresponding counting end value (frequency division coefficient)
//The frequency of bass 1 is 261.6Hz, and the buzzer control signal period should be 12MHz / 261.6Hz = 45871.5,
//Because the buzzer control signal in this design is inverted according to the counter period, several kinds of final values = 45871.5 / 2 = 22936
//Need to count 22936, the counting range is 0 ~ (22936-1), so time_end = 22935
always@(tone) begin
	case(tone)
		5'd1:	time_end =	16'd22935;	//L1,
		5'd2:	time_end =	16'd20428;	//L2,
		5'd3:	time_end =	16'd18203;	//L3,
		5'd4:	time_end =	16'd17181;	//L4,
		5'd5:	time_end =	16'd15305;	//L5,
		5'd6:	time_end =	16'd13635;	//L6,
		5'd7:	time_end =	16'd12147;	//L7,
		5'd8:	time_end =	16'd11464;	//M1,
		5'd9:	time_end =	16'd10215;	//M2,
		5'd10:	time_end =	16'd9100;	//M3,
		5'd11:	time_end =	16'd8589;	//M4,
		5'd12:	time_end =	16'd7652;	//M5,
		5'd13:	time_end =	16'd6817;	//M6,
		5'd14:	time_end =	16'd6073;	//M7,
		5'd15:	time_end =	16'd5740;	//H1,
		5'd16:	time_end =	16'd5107;	//H2,
		5'd17:	time_end =	16'd4549;	//H3,
		5'd18:	time_end =	16'd4294;	//H4,
		5'd19:	time_end =	16'd3825;	//H5,
		5'd20:	time_end =	16'd3408;	//H6,
		5'd21:	time_end =	16'd3036;	//H7,
		default:time_end =	16'd65535;	
	endcase
end
 
reg [17:0] time_cnt;
//When the buzzer is enabled, the counter counts according to the final count value (frequency division factor)
always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) begin
		time_cnt <= 1'b0;
	end else if(!tone_en) begin
		time_cnt <= 1'b0;
	end else if(time_cnt>=time_end) begin
		time_cnt <= 1'b0;
	end else begin
		time_cnt <= time_cnt + 1'b1;
	end
end
 
//According to the period of the counter, flip the buzzer control signal
always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) begin
		piano_out <= 1'b0;
	end else if(time_cnt==time_end) begin
		piano_out <= ~piano_out;	//The buzzer controls the output to flip, twice to 1Hz
	end else begin
		piano_out <= piano_out;
	end
end
 
endmodule