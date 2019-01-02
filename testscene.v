`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:46:26 01/01/2019
// Design Name:   scene_display
// Module Name:   D:/project-dino/dino_001/testscene.v
// Project Name:  dino_001
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: scene_display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testscene;

	// Inputs
	reg clk;
	reg clk_100Hz;
	reg [8:0] y;
	reg [9:0] x;
	reg [1:0] game_state;
	reg [32:0] count;
	// Outputs
	wire [11:0] data;

	// Instantiate the Unit Under Test (UUT)
	scene_display uut (
		.clk(clk), 
		.clk_100Hz(clk_100Hz), 
		.y(y), 
		.x(x), 
		.game_state(game_state), 
		.data(data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		count = 0;
		clk_100Hz = 0;
		y = 0;
		x = 0;
		game_state = 2'b1;

		// Wait 100 ns for global reset to finish
        
		// Add stimulus here

	end
   always #10 clk_100Hz = !clk_100Hz;
	always #2  clk = !clk;
	always @(posedge clk_100Hz)begin
		x = count % 640;
		y = (count / 640) % 80 + 20;
		count = count + 1;
	end
endmodule

