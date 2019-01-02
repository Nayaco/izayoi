module Top(
    input wire clk,
    output wire [3:0] R, G, B,
    output wire HS, VS,
	output wire SEGLED_CLK,
    output wire SEGLED_CLR,
    output wire SEGLED_DO,
    output wire SEGLED_PEN
);
    wire clk_25MHz, clk_100Hz, clk_4Hz;
    reg [11:0] vga_data;
    wire [8:0] y;
    wire [9:0] x;
    wire [8:0] y_fix;
    wire [9:0] x_fix;
    reg [15:0] addr;
    wire [15:0] data;
	//Drivers

    /* clock */
	clock_div clock_div (
        .clk(clk),
        .clk_25MHz(clk_25MHz),
        .clk_100Hz(clk_100Hz),
        .clk_4Hz(clk_4Hz)
    );
	/* VGA */
	VGA_driver VGA_driver (
        .clk_25MHz(clk_25MHz),
        .Din(vga_data),
        .row(y), .col(x),
        .R(R), .G(G), .B(B),
        .HS(HS), .VS(VS)
    );
	/* SEG7 */
	wire [31:0] seg_data = 32'h1234_ABCD;
    Seg7_driver Seg7_driver (
        .clk(clk),
        .data(seg_data),
        .SEGLED_CLK(SEGLED_CLK),
        .SEGLED_DO(SEGLED_DO),
        .SEGLED_PEN(SEGLED_PEN),
        .SEGLED_CLR(SEGLED_CLR)
    );
	 
	// game logic
	localparam
	GAME_INITIAL = 2'd0,
	GAME_PLAYING = 2'd1,
	GAME_OVER    = 2'd2;
	reg game_state = GAME_PLAYING;
	
	// Dino Logic
	wire [9:0] dino_x_rel = x - dino_x;
    wire [8:0] dino_y_rel = y - dino_y;
    wire [9:0] dino_mem_addr =
        dino_y_rel * 34 + dino_x_rel;
	wire [9: 0]dino_x;
	wire [8: 0]dino_y;
	wire [3: 0]dino_state, dino_animation_state;
	wire [11: 0]dino_run_image;
	dino dino_instance(
		.clk_25MHz(clk_25MHz),
		.clk_100Hz(clk_100Hz),
		.rst(1'b0),
		.start(1'b1),
		.up(1'b0),
		.down(1'b0),
		.kill(1'b0),
		.x(dino_x),
		.y(dino_y),
		.dino_state(dino_state),
		.dino_animation_state(dino_animation_state)
	);
	localparam DINO_RUN_OFFSET = 1890;
	ROM_dinorun dino_run(
		.clka(clk),
		.addra((dino_animation_state * DINO_RUN_OFFSET + dino_y_rel * 42 + dino_x_rel)),
		.douta(dino)
	)
	
	
	//game background
	wire ground_x;  
	wire [11:0]game_scene;
	defparam scene_display_instance.SPEED = 2;
	defparam scene_display_instance.GROUND_POS = 400;
	scene_display scene_display_instance(
		.clk(clk), 
		.clk_100Hz(clk_100Hz), 
		.y(y), .x(x), 
		.game_state(game_state), 
		.data(game_scene)
	);

	
	// display
    always @(posedge clk)begin
		case(game_state)
			GAME_PLAYING: begin 
				vga_data <= game_scene;
			end
		endcase
	end
endmodule
