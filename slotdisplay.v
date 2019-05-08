module slotdisplay
	(
		clk,
		resetn,
		spin, // triggers drawing
		// outputs of slots
      num1,
		num2,
		num3,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input clk, resetn, spin;	
	input [2:0] num1, num2, num3;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	wire draw, resetc, ld_out;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	displaycontrol c0(clk, resetn, spin, draw, writeEn, resetc, ld_out);
	display d1(num1, num2, num3, resetn, resetc, clk, ld_out, x, y, colour, draw);
    
endmodule

module displaycontrol(clk, resetn, spin, draw, plot, resetc, ld_out);
	input clk, resetn, spin, draw;
	output reg plot, resetc, ld_out;
	
	reg q;
	reg [3:0] current_state, next_state;
	reg [24:0] game_clk;
    
   localparam  WAIT      	= 4'd0,
					READY       = 4'd1,
					RESET_E     = 4'd2,
					ERASING     = 4'd3,
					RESET_D     = 4'd4,
					DRAWING     = 4'd5;
					
	// state table
	always@(*)
   begin: state_table 
		case (current_state)
			WAIT: next_state = spin ? READY : WAIT;
			READY: next_state = spin ? READY : RESET_E;
			RESET_E: next_state = ERASING;
			ERASING: next_state = draw ? RESET_D : ERASING;
			RESET_D: next_state = DRAWING;
			DRAWING: next_state = draw ? WAIT : DRAWING;
			default: next_state = WAIT;
		endcase
	end
	
	// signals
	always @(*)
   begin: enable_signals
		
		plot = 1'b0;
		resetc = 1'b1;
		ld_out = 1'b0;
		
		case (current_state)
			RESET_E: begin
				resetc = 1'b0;
			end
			ERASING: begin
				plot = 1'b1;
			end
			RESET_D: begin
				resetc = 1'b0;
			end		
			DRAWING: begin
				ld_out = 1'b1;
				plot = 1'b1;
			end
		endcase
	end
	
	// next state
	always@(posedge clk)
   begin: state_FFs
		if(!resetn)
			current_state <= WAIT;
      else
			current_state <= next_state;
   end
	
	// 0.5 second clock
//	always @(posedge clk)
//		begin
//			if (!resetn) begin
//				game_clk <= 0;
//			end else begin
//				if (game_clk == 25'd24_999_999) begin
//					game_clk <= 0;
//					q <= 1;
//				end
//			else begin
//				game_clk <= game_clk + 1;
//				q <= 0;
//			end
//		end
//	end
endmodule

module display(
	input [2:0] icon1, icon2, icon3,
	input resetn, resetc, clk,ld_out,
	output reg [7:0] x_out,
	output reg [6:0] y_out,
	output reg [2:0] color_out,
	output reg draw
	);
	
	wire [2:0] color1, color2, color3;
	wire [10:0] address1, address2, address3;
	reg [7:0] x_counter;
	reg [6:0] y_counter;
	reg count_addr1, count_addr2, count_addr3;
	
	// address counters
	addr_counter ac1(clk, resetn, resetc, count_addr1, address1);
	addr_counter ac2(clk, resetn, resetc, count_addr2, address2);
	addr_counter ac3(clk, resetn, resetc, count_addr3, address3);
	
	// color pickers
	colorpicker c1(clk, icon1, address1, color1);
	colorpicker c2(clk, icon2, address2, color2);
	colorpicker c3(clk, icon3, address3, color3);
	
	// x and y position counters
	always @(posedge clk) begin
		if (!resetn | !resetc) begin
			x_counter <= 0;
			y_counter <= 0;
			draw <= 0;
		end 
		else if (x_counter > 159) begin
			x_counter <= 0;
			y_counter <= y_counter + 1;
			draw <= 0;
		end
		else if (y_counter > 119) begin
			x_counter <= 0;
			y_counter <= 0;
			draw <= 1;
		end else begin
			x_counter <= x_counter + 1;
			draw <= 0;
		end
	end
	
		
	// draw when x, y are within bounds
	always @(posedge clk) begin
		if (!resetn) begin
			x_out <= 0;
			y_out <= 0;
			count_addr1 <= 0;
			count_addr2 <= 0;
			count_addr3 <= 0;
			color_out <= 0;
		end else if (9 < x_counter & x_counter < 50 & 40 < y_counter & y_counter < 81) begin
			x_out <= x_counter;
			y_out <= y_counter;
			count_addr1 <= 1;
			count_addr2 <= 0;
			count_addr3 <= 0;
			color_out <= (ld_out) ? color1 : 0;
		end else if (59 < x_counter & x_counter < 100 & 40 < y_counter & y_counter < 81) begin
			x_out <= x_counter;
			y_out <= y_counter;
			count_addr1 <= 0;
			count_addr2 <= 1;
			count_addr3 <= 0;
			color_out <= (ld_out) ? color2 : 0;
		end else if (109 < x_counter & x_counter < 150 & 40 < y_counter & y_counter < 81) begin
			x_out <= x_counter;
			y_out <= y_counter;
			count_addr1 <= 0;
			count_addr2 <= 0;
			count_addr3 <= 1;
			color_out <= (ld_out) ? color3 : 0;
		end else begin
			x_out <= x_counter;
			y_out <= y_counter;
			count_addr1 <= 0;
			count_addr2 <= 0;
			count_addr3 <= 0;
			color_out <= 0;
		end
	end
endmodule
		
	
