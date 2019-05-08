//THIS MODULE OUTPUTS THREE 3BIT ICONs, WHEN THE SPIN KEY/BUTTON IS LET GO. 
module spinner(clock, reset, spin, icon1, icon2, icon3); 
	input clock;
	input reset;
	input spin;
	output [2:0] icon1;
	output [2:0] icon2;
	output [2:0] icon3;
	wire [5:0] randNum6; 
	wire [5:0] randNum7;
	wire [5:0] randNum8;

	randomNumberGenerator6bit randomGen6(clock, reset, randNum6);
	randomNumberGenerator7bit randomGen7(clock, reset, randNum7);
	randomNumberGenerator8bit randomGen8(clock, reset, randNum8);

	iconEncoder iconEncoder1(reset, spin, randNum6, icon1);
	iconEncoder iconEncoder2(reset, spin, randNum7, icon2);
	iconEncoder iconEncoder3(reset, spin, randNum8, icon3);
endmodule

//THIS MODULE GENERATES A 6 BIT RANDOM NUMBER USING A 6 BIT LFSR.
module randomNumberGenerator6bit(clock, reset, randNum6bit);
	input clock;
	input reset;
	output [5:0] randNum6bit; 

	reg [5:0] rand6; 

	always @(posedge clock, negedge reset)
	begin
		if(!reset)
			rand6 <= 6'b111111;
		else
			begin
			//polynomial for 6 bit LFSR: 1 + x^5 + x^6
			rand6[0] <= rand6[4]^rand6[5];
			rand6[5:1] <= rand6[4:0];
			end
	end
	assign randNum6bit = rand6[5:0]; //outputs the random 6 bit sequence
endmodule

//THIS MODULE GENERATES A 6 BIT RANDOM NUMBER USING A 7 BIT LFSR.
module randomNumberGenerator7bit(clock, reset, randNum7bit);
	input clock;
	input reset;
	output [5:0] randNum7bit; 

	reg [6:0] rand7; 

	always @(posedge clock, negedge reset)
	begin
		if(!reset)
			rand7 <= 7'b111111;
		else
			begin
			//polynomial for 7 bit LFSR: 1 + x^6 + x^7
			rand7[0] <= rand7[5]^rand7[6];
			rand7[6:1] <= rand7[5:0];
			end
	end
	assign randNum7bit = rand7[5:0]; //outputs the random 6 bit sequence
endmodule

//THIS MODULE GENERATES A 6 BIT RANDOM NUMBER USING A 8 BIT LFSR.
module randomNumberGenerator8bit(clock, reset, randNum8bit);
	input clock;
	input reset;
	output [5:0] randNum8bit; 

	reg [7:0] rand8; 

	always @(posedge clock, negedge reset)
	begin
		if(!reset)
			rand8 <= 8'b111111;
		else
			begin
			//polynomial for 8 bit LFSR is: 1 + x + x^6 + x^7 + x^8
			rand8[0] <= rand8[1]^rand8[5]^rand8[6]^rand8[7];
			rand8[7:1] <= rand8[6:0];
			end
	end
	assign randNum8bit = rand8[5:0]; //outputs the random 6 bit sequence
endmodule

//THIS MODULE ENCODES THE RANDOM NUMBER TO AN ICON, WHEN THE SPIN KEY/BUTTON IS LET GO. 
module iconEncoder(reset, spin, randNum, icon);
	input spin;
	input reset;
	input [5:0] randNum;
	output reg [2:0] icon;

	parameter watermelon = 3'b000;
	parameter orange = 3'b001;
	parameter apple = 3'b010;
	parameter cherry = 3'b011;
	parameter bar = 3'b100;
	parameter bar2 = 3'b101;
	parameter bar3 = 3'b110;
	parameter jackpot = 3'b111;

	always @(posedge spin, negedge reset)
	begin 
		if (!reset)
			icon <= watermelon; 
		else
			begin
			if (randNum <= 6'b011010)
				icon <= watermelon; 
			else if (randNum > 6'b011010 & randNum <= 6'b100100)
				icon <= orange;
			else if (randNum > 6'b100100 & randNum <= 6'b101110)
				icon <= apple;
			else if (randNum > 6'b101110 & randNum <= 6'b110011)
				icon <= cherry;
			else if (randNum > 6'b110011 & randNum <= 6'b111000)
				icon <= bar;
			else if (randNum > 6'b111000 & randNum <= 6'b111100)
				icon <= bar2;
			else if (randNum > 6'b111100 & randNum <= 6'b111110)
				icon <= bar3;
			else
				icon <= jackpot;
			end
	end
endmodule











