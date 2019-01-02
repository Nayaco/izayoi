`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:25:21 01/01/2019
// Design Name:   dino
// Module Name:   D:/project-dino/dino_001/test_dino.v
// Project Name:  dino_001
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dino
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_dino;

	// Inputs
	reg clk_25MHz;
	reg clk_100Hz;
	reg rst;
	reg start;
	reg up;
	reg down;
	reg kill;

	// Outputs
	wire [9:0] x;
	wire [8:0] y;
	wire [3:0] dino_state;
	wire dino_animation_state;

	// Instantiate the Unit Under Test (UUT)
	dino uut (
		.clk_25MHz(clk_25MHz), 
		.clk_100Hz(clk_100Hz), 
		.rst(rst), 
		.start(start), 
		.up(up), 
		.down(down), 
		.kill(kill), 
		.x(x), 
		.y(y), 
		.dino_state(dino_state), 
		.dino_animation_state(dino_animation_state)
	);

	initial begin
		// Initialize Inputs
		clk_25MHz = 0;
		clk_100Hz = 0;
		rst = 0;
		start = 1;
		up = 0;
		down = 0;
		kill = 0;

		// Wait 100 ns for global reset to finish
		#500
      start = 0;
		kill = 1;
		// Add stimulus here

	end
	
	always #2 clk_25MHz = !clk_25MHz;
	always #10 clk_100Hz = !clk_100Hz;
      
endmodule

