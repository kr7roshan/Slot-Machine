module colorpicker(clk, icon, address, color);
	input clk;
	input [2:0] icon;
	input [10:0] address;
	output reg [2:0] color;
	
	wire [2:0] color1, color2, color3, color4, color5, color6, color7, color8;
	
	bell sp1(address, clk, color1);
	cherry sp2(address, clk, color2);
	gold sp3(address, clk, color3);
	grape sp4(address, clk, color4);
	seven sp5(address, clk, color5);
	onebar sp6(address, clk, color6);
	twobar sp7(address, clk, color7);
	threebar sp8(address, clk, color8);
	
	// pick color depending on icon
	always @(*) begin
		case (icon)
			0: color = color1;
			1: color = color2;
			2: color = color3;
			3: color = color4;
			4: color = color5;
			5: color = color6;
			6: color = color7;
			7: color = color8;
		endcase
	end
endmodule

module addr_counter(clk, resetn, resetc, count_sig, address);
	input clk, resetn, resetc, count_sig;
	output reg [10:0] address;
	
	always @(posedge clk) begin
		if (!resetn | !resetc) begin
			address <= 0;
		end 
		else begin
			if	(count_sig) begin
				address <= address + 1;
			end
		end
	end

endmodule
	