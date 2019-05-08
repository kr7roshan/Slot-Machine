module slotmachine(SW, CLOCK_50, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);
	input [9:0] SW;
	input [3:0] KEY; //KEY[0] sync. low reset, KEY[1] spin
	input CLOCK_50;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire [2:0] icon1, icon2, icon3;
	wire [3:0] balance_h, balance_t, balance_o;
	wire [3:0] bet_h, bet_t, bet_o, icon1_h, icon1_t, icon1_o, icon2_h, icon2_t, icon2_o, icon3_h, icon3_t, icon3_o;
	wire spin, payout;
	
	assign spin = ~KEY[1];

	control c1(CLOCK_50, KEY[0], spin, payout);
	spinner s1(CLOCK_50, KEY[0], spin, icon1, icon2, icon3);
	betting b1(icon1, icon2, icon3, SW[6:0], CLOCK_50, KEY[0], payout, balance_h, balance_t, balance_o);
	
	slotdisplay sd1(CLOCK_50, KEY[0], spin, icon1, icon2, icon3, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B);
	
	bin_to_bcd bcd1({7'b0000000, icon1}, icon1_h, icon1_t, icon1_o);
	bin_to_bcd bcd2({7'b0000000, icon2}, icon2_h, icon2_t, icon2_o);
	bin_to_bcd bcd3({7'b0000000, icon3}, icon3_h, icon3_t, icon3_o);
	
	hex_decoder H0(
       .hex_digit(icon1_o), 
       .segments(HEX0)
       );
        
   hex_decoder H1(
       .hex_digit(icon2_o), 
       .segments(HEX1)
       );
		 
   hex_decoder H2(
       .hex_digit(icon3_o), 
       .segments(HEX2)
       );
        
   hex_decoder H3(
       .hex_digit(balance_o), 
       .segments(HEX3)
       );
		 
   hex_decoder H4(
       .hex_digit(balance_t), 
       .segments(HEX4)
       );
        
   hex_decoder H5(
       .hex_digit(balance_h), 
       .segments(HEX5)
       );
		 
endmodule

module control(
	input clock,
	input reset,
	input spin, 
	output reg payout
	); 

	reg [1:0] current_state, next_state; 

	localparam  SPIN = 2'd0,
					SPINNING = 2'd1,
					PAY  = 2'd2; 

	always @(*)
	begin
		case (current_state)
			SPIN: next_state = spin ? SPINNING : SPIN;
			SPINNING: next_state = spin ? SPINNING : PAY;
			PAY: next_state = SPIN; 
			default: next_state = SPIN; 
		endcase
	end

	always @(*)
	begin
		payout = 1'b0;
		case (current_state)
			PAY: begin
				payout = 1'b1;
				end
		endcase 
	end

	always @(posedge clock)
	begin 
		if (!reset)
			current_state <= SPIN;
		else 
			current_state <= next_state;
	end
endmodule 

module gameclock(clk, resetn, q);
	input clk, resetn;
	output reg q; 
	reg [25:0] game_clk; 
	//0.5 second clock
    always @(posedge clk)
		begin
			if (!resetn) begin
				game_clk <= 0;
			end else begin
				if (game_clk == 25'd24_999_999) begin
					game_clk <= 0;
					q <= 1;
				end
			else begin
				game_clk <= game_clk + 1;
				q <= 0;
			end
		end
	end