module betting(first, second, third, bet, clk, resetn, payout, balance_h, balance_t, balance_o);
	input [2:0] first; // first reel
	input [2:0] second; // second reel
	input [2:0] third; // third reel
	input [6:0] bet; // max 100
   input clk, resetn, payout;
	output reg [3:0] balance_h, balance_t, balance_o; // hundreds/tens/ones, max 999
	
	wire [6:0] prize_mult; // prize multiplier
	wire [9:0] prize; // winnings based on bet and roll outcome
	wire [3:0] b1, b2, b3;
	reg [9:0] balance; // current balance
	reg [6:0] nextBet; // betting value for next roll
	
	prize_multiplier p1(first, second, third, prize_mult);
	bin_to_bcd btb1(balance, b1, b2, b3);
	winnings w1(nextBet, prize_mult, prize);
	
	// set bet value
	always @(posedge clk) begin
		if (!resetn)
			nextBet <= 0;
		else if (bet > 100)
			nextBet <= 100;
		else
			nextBet <= bet;
	end
	
	always @(posedge clk) begin
		if (!resetn) 
			balance <= 100;
		else if (payout) begin
			if (balance + prize - bet > 999)
				balance <= 999;
			else
				balance <= balance + prize - bet;
		end
	end
	
	// output
	always @(posedge clk) begin
		balance_h <= b1;
		balance_t <= b2;
		balance_o <= b3;
	end
endmodule

module winnings(bet, prize_mult, prize);
	input [6:0] bet;
	input [6:0] prize_mult;
	output reg [9:0] prize;
	
	always @(*) begin
		case (prize_mult)
			80: prize = bet * 80;
			40: prize = bet * 40;
			25: prize = bet * 25;
			10: prize = bet * 10;
			5: prize = bet * 5;
			3: prize = bet * 3;
			default: prize = 0;
		endcase
	end
endmodule

module prize_multiplier(first, second, third, multiplier);
	input [2:0] first;
	input [2:0] second;
	input [2:0] third;
   output reg [6:0] multiplier;
	
	always @(*)
	if (first == 3'b111 & second == 3'b111 & third == 3'b111) begin
		multiplier = 80; // 7 7 7
	end else if (first == 3'b110 & second == 3'b110 & third == 3'b110) begin
		multiplier = 40; // 3 x triple bar
	end else if (first == 3'b101 & second == 3'b101 & third == 3'b101) begin
		multiplier = 25; // 3 x double bar
	end else if (first == 3'b100 & second == 3'b100 & third == 3'b100) begin
		multiplier = 10; // 3 x one bar
	end else if (first == 3'b011 & second == 3'b011 & third == 3'b011) begin
		multiplier = 5; // 3 x cherry
	end else if (first == 3'b011 & second == 3'b011 | first == 3'b011 & third == 3'b011 | second == 3'b011 & third == 3'b011) begin
		multiplier = 3; // 2 x cherry 
	end else if (first == 3'b101 | first == 3'b110 | first == 3'b100 & second == 3'b101 | second == 3'b110 | second == 3'b100 & third == 3'b101 | third == 3'b110 | third == 3'b100) begin
		multiplier = 3; // 3 x any bar 
	end else begin
		multiplier = 0;
	end
endmodule
	
module bin_to_bcd(num, hundreds, tens, ones);
   input [9:0] num;
   output reg [3:0] hundreds;
   output reg [3:0] tens;
   output reg [3:0] ones;
   
   integer i;
   
   always @(num)
   begin

		hundreds = 4'd0;
		tens = 4'd0;
		ones = 4'd0;
      
      // Loop 10 times
      for (i=9; i>=0; i=i-1) 
		begin
         if (hundreds >= 5)
            hundreds = hundreds + 3;
            
         if (tens >= 5)
            tens = tens + 3;
            
         if (ones >= 5)
            ones = ones + 3;  
				
         // shift left
         hundreds = hundreds << 1;
			hundreds[0] = tens[3];
			tens = tens << 1;
			tens[0] = ones[3];
			ones = ones << 1;
			ones[0] = num[i];
      end
   end
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
