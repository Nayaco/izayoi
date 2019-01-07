module scene_display(
	input wire clk,
	input wire clk_100Hz,
	input wire [8:0] y,
	input wire [9:0] x,
	input wire [1:0] game_state,
	output reg [11:0] data
 );
	
	localparam	GAME_INITIAL = 2'd0,
				GAME_PLAYING = 2'd1,
				GAME_OVER    = 2'd2;
    
    parameter SPEED = 3	;
    parameter GROUND_POS = 20;
	parameter GO_POS_X = 223,
			  GO_POS_Y = 200;
	localparam GROUND_SIZE_X = 1200,
			   SCREEN_SIZE_X = 640;
	localparam GO_SIZE_X = 193,
			   GO_SIZE_Y = 13;
	// internal states
	reg [31: 0]  ground_offset = 0;
	wire [15: 0] ground_image;
	wire [15: 0] ground_x_rel = (x + ground_offset) > 1200 ? (x + ground_offset) - 1200 : (x + ground_offset);
    wire [15: 0] ground_y_rel = (y >= GROUND_POS && y < GROUND_POS + 15) ? (y - GROUND_POS) : 0;
	wire [15: 0] ground_mem_addr = ground_y_rel * GROUND_SIZE_X + ground_x_rel;
	ROM_ground ROM_ground (
		.clka(clk),
		.addra(ground_mem_addr),
		.douta(ground_image)
	);

	wire [15: 0]go_x_rel = x - GO_POS_X;
	wire [15: 0]go_y_rel = y - GO_POS_Y;
	wire [15: 0]go_mem_addr = go_y_rel * GO_SIZE_X + go_x_rel;
	wire [15: 0] go_image;
	ROM_gameover ROM_gameover (
		.clka(clk),
		.addra(go_mem_addr),
		.douta(go_image)
	);
	always @ (posedge clk_100Hz) begin
		case (game_state) 
			GAME_INITIAL: begin
				ground_offset <= 0;
			end
			GAME_PLAYING: begin
				if(ground_offset < 1200)ground_offset <= ground_offset + SPEED;
					else ground_offset <= 0;
			end
			GAME_OVER: begin
				ground_offset <= ground_offset;
			end
		endcase
	end


	always @(posedge clk) begin
		if (y >= GROUND_POS && y < GROUND_POS + 15 && game_state != GAME_INITIAL)
			data <= ground_image[11: 0];
		else if (go_y_rel < GO_SIZE_Y && go_x_rel < GO_SIZE_X && game_state == GAME_OVER)
			data <= go_image[11: 0];
		else 
            data <= 12'hFFF;
   end

endmodule
