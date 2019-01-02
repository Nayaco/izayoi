module dino(
    input wire clk_25MHz,
    input wire clk_100Hz,
    input wire rst,
    input wire start,
    input wire up,
    input wire down,
    input wire kill,
    output reg [9: 0]x,
    output reg [8: 0]y, 
    output reg [3: 0]dino_state = 0, 
    output wire dino_animation_state
);
parameter INITIAL_POS_X = 50,
          INITIAL_POS_Y = 400;

initial begin 
    x = INITIAL_POS_X;
    y = INITIAL_POS_Y;
end

localparam DINO_STOP = 4'b00_00,
           DINO_RUN = 4'b00_01,
           DINO_JUMP = 4'b00_11,
           DINO_DOWN = 4'b00_10,
           DINO_DIE = 4'b01_10;

reg [31: 0]dino_v_y = 0;
reg dino_v_y_minus = 1'b0;

reg [31: 0]animation_count = 0;
assign dino_animation_state = animation_count[5];
//dino run_state
always @(clk_100Hz) if(dino_state == DINO_RUN || dino_state == DINO_DOWN)animation_count = animation_count + 1;

// FSM
always @(clk_25MHz) begin
    case (dino_state)
        DINO_STOP: begin
            if(start)dino_state = DINO_RUN;
        end
        DINO_RUN:  begin
            if(rst)dino_state = DINO_STOP;
            else if(kill) dino_state = DINO_DIE;
            else if(up & ~down)dino_state = DINO_JUMP;
            else if(~up & down)dino_state = DINO_DOWN;
        end
        DINO_JUMP: begin
            if(rst)dino_state = DINO_STOP;
            else if(kill) dino_state = DINO_DIE;
            else if(up & ~down)dino_state = DINO_JUMP;
            else if(~up & down)dino_state = DINO_DOWN;
        end
        DINO_DOWN: begin
            if(rst)dino_state = DINO_STOP;
            else if(kill) dino_state = DINO_DIE;
            else if(up & ~down)dino_state = DINO_JUMP;
            else if(~up & down)dino_state = DINO_DOWN;
        end
        DINO_DIE: begin
            if(rst)dino_state = DINO_STOP;
            else if(kill) dino_state = DINO_DIE;
            else if(up & ~down)dino_state = DINO_JUMP;
            else if(~up & down)dino_state = DINO_DOWN;
        end
    endcase
end

endmodule