module dino(
    input wire clk_25MHz,
    input wire clk_1KHz,
    input wire clk_100Hz,
    input wire clk_50Hz,
    input wire clk_25Hz,
    input wire rst,
    input wire start,
    input wire up,
    input wire down,
    input wire kill,
    output reg [9: 0]x,
    output reg [8: 0]y, 
    output reg [3: 0]dino_state = 0, 
    output wire dino_animation_state,
    output wire dino_sparkle_state,
    output wire [1:0]dino_test
);
assign dino_test = dino_down_state;
parameter INITIAL_POS_X = 20,
          INITIAL_POS_Y = 400,
          DINO_ANIMATION_T = 3,
          DINO_SPARKLE_T = 7,
          DINO_JUMP_SPEED = 2;

initial begin 
    x = INITIAL_POS_X;
    y = INITIAL_POS_Y;
end

localparam DINO_STOP = 4'b00_00,
           DINO_RUN = 4'b00_01,
           DINO_JUMP = 4'b00_11,
           DINO_DOWN = 4'b00_10,
           DINO_DIE = 4'b01_10;

reg [31: 0]animation_count = 0;
assign dino_animation_state = animation_count[DINO_ANIMATION_T];
assign dino_sparkle_state = animation_count[DINO_SPARKLE_T];
// dino run_state
always @(posedge clk_100Hz) begin
    if(dino_state == DINO_RUN || dino_state == DINO_DOWN || dino_state == DINO_STOP)animation_count = animation_count + 1;
        else if(dino_state == DINO_DIE)animation_count = 0;
end
// dino jump or down state 
localparam DINO_DOWN_Y = INITIAL_POS_Y + 17;
localparam DINO_JUMP_NOT_OVER = 0,
           DINO_JUMP_OVER     = 3,
           DINO_JUMP_OVER_NR  = 1; 
localparam DINO_DOWN_OVER_NR = 1,
           DINO_DOWN_OVER_R = 0, 
           DINO_DOWN_R = 3,
           DINO_DOWN_NR = 2;// [1:FSM_Ctrl, 0:dino_Ctrl]
parameter DINO_G = 1,
          DINO_INITIAL_V = 10;

reg [9: 0]dino_y_jump_double = 0;
reg [31: 0]dino_v_y = 0;
reg dino_v_y_minus = 0;
reg [1: 0]dino_jump_state_over = DINO_JUMP_OVER_NR;
reg [1: 0]dino_down_state = DINO_DOWN_OVER_NR;
reg [3: 0]dino_last_state = DINO_STOP;
always @(posedge clk_50Hz) begin
    case(dino_state)
        DINO_DIE: begin
            dino_down_state[0] = 0;
            if(dino_last_state == DINO_DOWN)y = INITIAL_POS_Y;
            dino_jump_state_over = DINO_JUMP_OVER_NR;
        end
        DINO_JUMP: begin
            dino_down_state[0] = 0;
            if(dino_jump_state_over == DINO_JUMP_OVER_NR)begin
                dino_v_y = DINO_INITIAL_V;
                dino_v_y_minus = 0;
                dino_jump_state_over = DINO_JUMP_NOT_OVER;
                dino_y_jump_double = 0;
                y = INITIAL_POS_Y;
            end 
            else begin
                if(!dino_v_y_minus)begin /* dino up */
                    dino_y_jump_double = dino_y_jump_double + dino_v_y;
                    y = INITIAL_POS_Y - dino_y_jump_double[9: 1];
                    dino_v_y = (dino_v_y >= DINO_G) ? (dino_v_y - DINO_G) : 0;
                    dino_v_y_minus = (dino_v_y >= DINO_G) ? 0 : 1;
                    dino_jump_state_over = DINO_JUMP_NOT_OVER;
                end
                else begin /* dino down */
                    dino_y_jump_double = (dino_y_jump_double > dino_v_y) ? dino_y_jump_double - dino_v_y : 0; 
                    y = INITIAL_POS_Y - dino_y_jump_double[9: 1];
                    dino_v_y = (dino_y_jump_double > 0) ? (dino_v_y + DINO_G) : 0;
                    dino_v_y_minus = (dino_y_jump_double > 0) ? 1 : 0;
                    dino_jump_state_over = (dino_y_jump_double > 0) ? DINO_JUMP_NOT_OVER : DINO_JUMP_OVER;
                end
            end
        end

        DINO_DOWN: begin
            dino_jump_state_over = DINO_JUMP_OVER_NR;
            if (dino_down_state == DINO_DOWN_OVER_NR)begin
                y = INITIAL_POS_Y;
                dino_down_state[0] = 0;
            end
            else if (dino_down_state == DINO_DOWN_NR)begin
                y = DINO_DOWN_Y;
                dino_down_state[0] = 1;
            end
        end
        default: begin
            if(dino_down_state == DINO_DOWN_NR)begin
                y = DINO_DOWN_Y;
                dino_down_state[0] = 1;
            end
            else begin
                y = INITIAL_POS_Y;
                dino_down_state[0] = 0;
            end
            dino_jump_state_over = DINO_JUMP_OVER_NR;
        end
    endcase
    dino_last_state = dino_state;
end


// FSM
always @(posedge clk_25MHz) begin
    case (dino_state)
        DINO_STOP: begin
            if(start) dino_state = DINO_RUN;
        end
        DINO_RUN:  begin
            if(rst)dino_state = DINO_RUN;
            else if(kill) dino_state = DINO_DIE;
            else if((up & ~down) && dino_down_state == DINO_DOWN_OVER_R)dino_state = DINO_JUMP;
            else if(~up & down)begin
                if(dino_down_state == DINO_DOWN_R)dino_state = DINO_DOWN;
                else dino_down_state[1] = 1;
            end
        end
        DINO_JUMP: begin
            if(rst) dino_state = DINO_RUN;
            else if(kill) dino_state = DINO_DIE;
            else if(dino_jump_state_over == DINO_JUMP_OVER)dino_state = DINO_RUN;
        end
        DINO_DOWN: begin
            if(rst) dino_state = DINO_RUN;
            else if(kill) dino_state = DINO_DIE;
            else begin
                if(!down)begin
                    if(dino_down_state == DINO_DOWN_OVER_R)begin
                        dino_state = DINO_RUN;
                    end
                    else if(dino_down_state == DINO_DOWN_R)begin
                        dino_down_state[1] = 0;
                    end
                end
                else begin
                    dino_down_state[1] = 1;
                end
            end 
        end
        DINO_DIE: begin
            if(rst)dino_state = DINO_RUN;
        end
    endcase
end

endmodule