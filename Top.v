module Top(
    input wire clk,
	input wire rst,
    input wire ps2_clk,
    input wire ps2_data,	
    output wire [3:0] R, G, B,
    output wire HS, VS,
	output wire SEGLED_CLK,
    output wire SEGLED_CLR,
    output wire SEGLED_DO,
    output wire SEGLED_PEN
);
    wire clk_25MHz, clk_1KHz, clk_100Hz, clk_50Hz, clk_25Hz, clk_4Hz;
	wire [31: 0] rand;
    reg  [11: 0] vga_data;
    wire [8: 0] y;
    wire [9: 0] x;
    wire [8: 0] y_fix;
    wire [9: 0] x_fix;
    reg  [15: 0] addr;
    wire [15: 0] data;
	//Drivers

	/* Key board */
	wire [7:0] ps2_byte;
    wire ps2_state;
    reg [2:0] ps2_state_sampling = 3'b0; 
    wire ps2_posedge_state = ps2_state_sampling[1] & ~ps2_state_sampling[2];
	wire ps2_long_en_state = &ps2_state_sampling;
    always @ (posedge clk_50Hz) begin
        ps2_state_sampling <= {ps2_state_sampling[1:0], ps2_state};
    end
    PS2_driver PS2_driver (
        .clk(clk),
        .rst(rst), 
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .ps2_byte(ps2_byte),
        .ps2_state(ps2_state)
    );
	wire keydown_R    = ps2_posedge_state && (ps2_byte == 8'h2D);
	wire keydown_ESC  = ps2_posedge_state && (ps2_byte == 8'h76);
    wire keydown_UP   = ps2_posedge_state && (ps2_byte == 8'h75);
    wire keypress_DOWN= ps2_long_en_state && (ps2_byte == 8'h72);
	wire keypress_ANY = ps2_posedge_state;
	
    /* clock */
	clock_div clock_div (
        .clk(clk),
        .clk_25MHz(clk_25MHz),
		.clk_1KHz(clk_1KHz),
        .clk_100Hz(clk_100Hz),
		.clk_50Hz(clk_50Hz),
		.clk_25Hz(clk_25Hz),
        .clk_4Hz(clk_4Hz)
    );
	/* rand */
	rand_gen rand_gen(
		.clk(clk),
		.load(1'b0),
		.seed(8'h00),
		.rand(rand[7: 0])
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
	reg [31:0] seg_data = 32'h1234_ABCD;
    Seg7_driver Seg7_driver (
        .clk(clk),
        .data(seg_data),
        .SEGLED_CLK(SEGLED_CLK),
        .SEGLED_DO(SEGLED_DO),
        .SEGLED_PEN(SEGLED_PEN),
        .SEGLED_CLR(SEGLED_CLR)
    );
	// game logic
	/* game speed */
	localparam GLOBAL_SPEED = 5;
	/* game state key control */
	wire start_game_key, 
		 restart_key,
		 dino_jump_key,
		 dino_down_key;
	assign start_game_key = keypress_ANY;
	assign restart_key = keydown_R;
	assign dino_jump_key = keydown_UP;
	assign dino_down_key = keypress_DOWN;

	/* game main logic */
	reg [31: 0]score = 0;
	wire [31: 0]score_dec;
	hex_to_dec h2d(
		.clk_25MHz(clk_25MHz),
		.hex(score),
		.dec(score_dec)
	);
	localparam 	GAME_INITIAL = 2'd0,
			   	GAME_PLAYING = 2'd1,
				GAME_OVER    = 2'd2;
	wire [1: 0]game_state;
	wire game_over;
	game_state GAME_FSM(
		.clk(clk),
		.start_game(start_game_key),
		.game_over(game_over),
        .restart(restart_key),
		.state(game_state)
	);
	
	always @(posedge clk_100Hz)begin
		if(game_state == GAME_PLAYING)begin
			if(restart_key)score = 0;
			 else score = score + 1;
		end
		else if (game_state != GAME_OVER)begin
		  	score = 0;
		end
		else begin
			if(restart_key)score = 0;
		end
	end
	/* Dino Logic */
	localparam 	DINO_STOP = 4'b00_00,
           	   	DINO_RUN = 4'b00_01,
           	   	DINO_JUMP = 4'b00_11,
           	   	DINO_DOWN = 4'b00_10,
           	   	DINO_DIE = 4'b01_10;
	localparam 	DINO_SIZE_X_U = 42,
	           	DINO_SIZE_Y_U = 45,
			   	DINO_SIZE_X_D = 57,
			   	DINO_SIZE_Y_D = 28,
				DINO_DELTA_X  = 15,
				DINO_DELTA_Y  = 17;
   
	wire [9: 0] dino_x;
	wire [8: 0] dino_y;
	wire [9: 0] dino_x_rel = x - dino_x;
    wire [8: 0] dino_y_rel = y - dino_y;
	wire [3: 0] dino_state, dino_animation_state;

	defparam dino_instance.INITIAL_POS_Y = 372;
	defparam dino_instance.DINO_INITIAL_V = 17;
	dino dino_instance(
		.clk_25MHz(clk_25MHz),
		.clk_1KHz(clk_1KHz),
		.clk_100Hz(clk_100Hz),
		.clk_50Hz(clk_50Hz),
		.clk_25Hz(clk_25Hz),
		.rst(restart_key),
		.start(game_state == GAME_PLAYING),
		.up(dino_jump_key),
		.down(dino_down_key),
		.kill(game_state == GAME_OVER),
		.x(dino_x),
		.y(dino_y),
		.dino_state(dino_state),
		.dino_animation_state(dino_animation_state)
	);
	
	localparam DINO_RUN_OFFSET = 1890;
	localparam DINO_DOWN_OFFSET = 1596;
	wire [16:0] dino_mem_addr = dino_y_rel * DINO_SIZE_X_U + dino_x_rel;
	wire [16:0] dino_mem_addr_D = dino_y_rel * DINO_SIZE_X_D + dino_x_rel;
	wire [11:0] dino_image[0: 6];
	ROM_dinoinit ROM_dino_init(
		.clka(clk),
		.addra(dino_mem_addr),
		.douta(dino_image[DINO_STOP])
	);
	ROM_dinorun ROM_dino_run(
		.clka(clk),
		.addra(dino_animation_state * DINO_RUN_OFFSET + dino_mem_addr),
		.douta(dino_image[DINO_RUN])
	);
	ROM_dinojump ROM_dino_jump(
		.clka(clk),
		.addra(dino_mem_addr),
		.douta(dino_image[DINO_JUMP])
	);
	ROM_dinodie ROM_dino_die(
		.clka(clk),
		.addra(dino_mem_addr),
		.douta(dino_image[DINO_DIE])
	);
	ROM_dinodown ROM_dino_down(
		.clka(clk),
		.addra(dino_animation_state * DINO_DOWN_OFFSET + dino_mem_addr_D),
		.douta(dino_image[DINO_DOWN])
	);
	
	/* game background */
	wire ground_x;  
	wire [11:0]game_scene;
	defparam scene_display_instance.SPEED = GLOBAL_SPEED - 1;
	defparam scene_display_instance.GROUND_POS = 400;
	scene_display scene_display_instance(
		.clk(clk), 
		.clk_100Hz(clk_100Hz), 
		.y(y), .x(x), 
		.game_state(game_state), 
		.data(game_scene)
	);

	/* tree logic */
	localparam  TREE_NONE = 4'b00_00,//0
				TREE_S_1  = 4'b00_01,//1
				TREE_S_2  = 4'b00_10,//2
				TREE_S_3  = 4'b00_11,//3
				TREE_S_4  = 4'b01_00,//4
				TREE_S_5  = 4'b01_01,//5
				TREE_S_6  = 4'b01_10,//6
				TREE_B_1  = 4'b01_11,//7
				TREE_B_2  = 4'b10_00,//8
				TREE_B_3  = 4'b10_01,//9
				TREE_B_4  = 4'b10_10,//10
				TREE_CL   = 4'b10_11,//11
				TREE_BD   = 4'b11_00,//12
				TREE_UNSET= 4'b11_11;//15

	localparam  TREE_SIZE_S_X = 17,
				TREE_SIZE_S_Y = 35,
				TREE_SIZE_B_X = 25,
				TREE_SIZE_B_Y = 50,
				TREE_SIZE_BD_X= 42,
				TREE_SIZE_BD_Y= 36,
				TREE_SIZE_CL_X= 51,
				TREE_SIZE_CL_Y= 50;
	
	wire [9: 0] tree_x;
	wire [8: 0] tree_y;
	wire [9: 0] size_x, size_y;
	wire [3: 0] tree_state;
	wire [3: 0] tree_animation_state;
	wire [9: 0] tree_x_rel = (tree_x < 700) ? x - tree_x : size_x + 700 - tree_x + x;
    wire [8: 0] tree_y_rel = y - tree_y;
	defparam tree_instance.TREE_INITIAL_POS_Y = 417;
	defparam tree_instance.SPEED = GLOBAL_SPEED;
	tree tree_instance(
		.clk_25MHz(clk_25MHz),
		.clk_1KHz(clk_1KHz),
		.clk_100Hz(clk_100Hz),
		.clk_50Hz(clk_50Hz),
		.clk_25Hz(clk_25Hz),
		.rand(rand),
		.rst(restart_key || (start_game_key && score < 5)),
		.stop(game_state == GAME_OVER),
		.x(tree_x),
		.y(tree_y),
		.tree_state(tree_state),
		.tree_animation_state(tree_animation_state),
		.size_x(size_x),
		.size_y(size_y)
	);
	localparam TREE_S_OFFSET = TREE_SIZE_S_X * TREE_SIZE_S_Y,
			   TREE_B_OFFSET = TREE_SIZE_B_X * TREE_SIZE_B_Y,
			   TREE_BD_OFFSET = TREE_SIZE_BD_X * TREE_SIZE_BD_Y;
	wire [15:0] tree_mem_addr = tree_y_rel * size_x + tree_x_rel;
	wire [11:0] tree_image[0: 16];
	ROM_treeS ROM_tree_S1(
		.clka(clk),
		.addra(tree_mem_addr),
		.douta(tree_image[TREE_S_1])
	);
	
	ROM_treeB ROM_tree_B1(
		.clka(clk),
		.addra(tree_mem_addr),
		.douta(tree_image[TREE_B_1])
	);

	ROM_treeCL ROM_tree_CL(
		.clka(clk),
		.addra(tree_mem_addr),
		.douta(tree_image[TREE_CL])
	);
	
	ROM_tree_BD ROM_tree_BD(
		.clka(clk),
		.addra(tree_mem_addr + tree_animation_state * TREE_BD_OFFSET),
		.douta(tree_image[TREE_BD])
	);

	/* dino collision */
	reg dino_col_state = 0;
	assign game_over = dino_col_state;
	reg [9: 0]low_x, hi_x;
	reg [8: 0]low_y, hi_y;
	always @(clk_1KHz)begin
		if(game_state == GAME_PLAYING && tree_state != TREE_NONE)begin
			if(restart_key)dino_col_state = 0;
			else if(dino_state == DINO_DOWN)begin
				low_x = dino_x < tree_x ? dino_x : tree_x;
				hi_x =  dino_x + DINO_SIZE_X_D > tree_x + size_x ? dino_x + DINO_SIZE_X_D : tree_x + size_x;
				low_y = dino_y < tree_y ? dino_y : tree_y;
				hi_y = dino_y + DINO_SIZE_Y_D > tree_y + size_y ? dino_y + DINO_SIZE_Y_D : tree_y + size_y;
				if(hi_y - low_y  < DINO_SIZE_Y_D + size_y - 2 && hi_x - low_x < DINO_SIZE_X_D + size_x - 2)begin
					dino_col_state = 1;
				end
			end
			else begin
				low_x = dino_x < tree_x ? dino_x : tree_x;
				hi_x =  dino_x + DINO_SIZE_X_U > tree_x + size_x ? dino_x + DINO_SIZE_X_U : tree_x + size_x;
				low_y = dino_y < tree_y ? dino_y : tree_y;
				hi_y = dino_y + DINO_SIZE_Y_U > tree_y + size_y ? dino_y + DINO_SIZE_Y_U : tree_y + size_y;
				if(hi_y - low_y  < DINO_SIZE_Y_U + size_y - 2 && hi_x - low_x < DINO_SIZE_X_U + size_x - 2)begin
					dino_col_state = 1;
				end
			end
		end
		else begin
			if(restart_key)dino_col_state = 0;
		end
	end
	
	// display
    always @(posedge clk)begin
		case(game_state)
			GAME_INITIAL: begin
				vga_data <= game_scene;
				if (dino_x_rel < DINO_SIZE_X_U && dino_y_rel < DINO_SIZE_Y_U )begin
					if (dino_x_rel < DINO_SIZE_X_U && dino_y_rel < DINO_SIZE_Y_U && dino_image[dino_state] != 12'hFFF)begin
						vga_data <= dino_image[dino_state]; 
					end
				end
			end
			GAME_PLAYING: begin 
				vga_data <= game_scene;
				case(dino_state)
					DINO_DOWN: begin
						/* release */
						if (dino_x_rel < DINO_SIZE_X_D && dino_y_rel < DINO_SIZE_Y_D && dino_image[dino_state] != 12'hFFF)begin
							vga_data <= dino_image[dino_state];
						end
					end
					default: begin
						/* release */	
						if (dino_x_rel < DINO_SIZE_X_U && dino_y_rel < DINO_SIZE_Y_U && dino_image[dino_state] != 12'hFFF)begin
							vga_data <= dino_image[dino_state]; 
						end
					end
				endcase
				/* tree display */
				case(tree_state)
					TREE_S_1: begin
						if (tree_x_rel < TREE_SIZE_S_X && tree_y_rel < TREE_SIZE_S_Y && tree_image[tree_state] != 12'hFFF)begin
						  vga_data <= tree_image[TREE_S_1];
						end
					end 
					
					TREE_B_1: begin
						if (tree_x_rel < TREE_SIZE_B_X && tree_y_rel < TREE_SIZE_B_Y && tree_image[tree_state] != 12'hFFF)begin
						  vga_data <= tree_image[TREE_B_1];
						end
					end 

					TREE_CL: begin
					  	if (tree_x_rel < TREE_SIZE_CL_X && tree_y_rel < TREE_SIZE_CL_Y && tree_image[tree_state] != 12'hFFF)begin
						  vga_data <= tree_image[TREE_CL];
						end
					end

					TREE_BD: begin
						if (tree_x_rel < TREE_SIZE_BD_X && tree_y_rel < TREE_SIZE_BD_Y && tree_image[tree_state] != 12'hFFF)begin
						  vga_data <= tree_image[TREE_BD];
						end
					end
				endcase
			end
			GAME_OVER: begin
				vga_data <= game_scene;
				/* tree display */
				case(tree_state)
					TREE_S_1: begin
						if (tree_x_rel < TREE_SIZE_S_X && tree_y_rel < TREE_SIZE_S_Y && tree_image[tree_state] != 12'hFFF)begin
						  vga_data <= tree_image[TREE_S_1];
						end
					end 
					
					TREE_B_1: begin
						if (tree_x_rel < TREE_SIZE_B_X && tree_y_rel < TREE_SIZE_B_Y && tree_image[tree_state] != 12'hFFF)begin
						  vga_data <= tree_image[TREE_B_1];
						end
					end 
					
					TREE_CL: begin
					  	if (tree_x_rel < TREE_SIZE_CL_X && tree_y_rel < TREE_SIZE_CL_Y && tree_image[tree_state] != 12'hFFF)begin
						  vga_data <= tree_image[TREE_CL];
						end
					end 

					TREE_BD: begin
						if (tree_x_rel < TREE_SIZE_BD_X && tree_y_rel < TREE_SIZE_BD_Y && tree_image[tree_state] != 12'hFFF)begin
						  vga_data <= tree_image[TREE_BD];
						end
					end
				endcase

				if (dino_x_rel < DINO_SIZE_X_U && dino_y_rel < DINO_SIZE_Y_U && dino_image[dino_state] != 12'hFFF)begin
					vga_data <= dino_image[dino_state]; 
				end

			end
		endcase
	end
	
	always @(posedge clk_50Hz)begin
		seg_data <= score_dec;
	end
endmodule
