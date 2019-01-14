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
	parameter WIN_POS_X = 0,
			  WIN_POS_Y = 1;
	localparam GROUND_SIZE_X = 1200,
			   SCREEN_SIZE_X = 640;
	localparam GO_SIZE_X = 193,
			   GO_SIZE_Y = 13;
	localparam WIN_SIZE_X = 640,
			   WIN_SIZE_Y = 153;
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

	wire [15: 0]win_x_rel = x - WIN_POS_X;
	wire [15: 0]win_y_rel = y - WIN_POS_Y;
	wire [31: 0]win_mem_addr = win_y_rel * WIN_SIZE_X + win_x_rel;
	wire [15: 0] win_image;
	ROM_window ROM_window (
		.clka(clk),
		.addra(win_mem_addr),
		.douta(win_image)
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
		if(win_y_rel < WIN_SIZE_Y && win_x_rel < WIN_SIZE_X)begin
			data <=  win_image[11: 0];
		end
		else if (y >= GROUND_POS && y < GROUND_POS + 15 && game_state != GAME_INITIAL)
			data <= ground_image[11: 0];
		else if (go_y_rel < GO_SIZE_Y && go_x_rel < GO_SIZE_X && game_state == GAME_OVER)
			data <= go_image[11: 0];
		else 
            data <= 12'hFFF;
   end

endmodule
