module scene_display(
	input wire clk,
	input wire clk_100Hz,
	input wire [8:0] y,
	input wire [9:0] x,
	input wire [1:0] game_state,
	output reg [11:0] data
 );
	
	localparam
		GAME_INITIAL = 2'd0,
		GAME_PLAYING = 2'd1,
		GAME_OVER    = 2'd2;
    
    parameter SPEED = 2;
    parameter GROUND_POS = 20;
	// internal states
	reg [31: 0] ground_offset = 0;
	wire [15: 0]image_ground;
	ROM_ground ROM_ground (
		.clka(clk),
		.addra(((y - GROUND_POS)) * 1200 + (x + ground_offset) % 1200),
		.douta(image_ground)
	);

	always @ (posedge clk_100Hz) begin
		case (game_state) 
			GAME_INITIAL: begin
				ground_offset <= 0;
			end
			GAME_PLAYING: begin
				ground_offset <= ground_offset + SPEED;
			end
			GAME_OVER: begin
			end
		endcase
	end


	always @(clk) begin
		if (y >= GROUND_POS && y < GROUND_POS + 15)
	        data = image_ground[11:0];
		else 
           data = 12'hFFF;
   end

endmodule
