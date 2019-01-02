`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:36:48 01/01/2019
// Design Name:   ground_state
// Module Name:   D:/project-dino/dino_001/gournd_state_test.v
// Project Name:  dino_001
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ground_state
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gournd_state_test;

	// Inputs
	reg clk_100Hz;

	// Outputs
	wire [15:0] ground_x;

	// Instantiate the Unit Under Test (UUT)
	ground_state uut (
		.clk_100Hz(clk_100Hz), 
		.ground_x(ground_x)
	);

	initial begin
		// Initialize Inputs
		clk_100Hz = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
   always #5 clk_100Hz = !clk_100Hz;
endmodule

