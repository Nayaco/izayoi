module tree(
    input wire clk_25MHz,
    input wire clk_1KHz,
    input wire clk_100Hz,
    input wire clk_50Hz,
    input wire clk_25Hz,
    input wire [31: 0] rand,
    input wire rst,
    input wire stop,
    output reg [9: 0]x,
    output reg [8: 0]y,
    output reg [3: 0]tree_state = TREE_NONE, 
    output wire tree_animation_state,
    output wire [9: 0]size_x,
    output wire [8: 0]size_y
);

parameter TREE_INITIAL_POS_Y = 400,
          TREE_INITIAL_POS_X = 700;
parameter SPEED = 3;
initial begin
    x = TREE_INITIAL_POS_X;
    y = TREE_INITIAL_POS_Y;
end

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
assign size_x = TREE_SIZE;
assign size_y = TREE_SIZE_Y;
reg [9: 0]TREE_SIZE = 1;
reg [8: 0]TREE_SIZE_Y = 0;
// tree enable
reg EN = 0;

// tree reset state
localparam TREE_RESET_OVER_NR = 1,
           TREE_RESET_OVER_R  = 0,
           TREE_RESET_R = 3,
           TREE_RESET_NR = 2;

reg [1: 0]tree_reset_state = TREE_RESET_OVER_R;
always @(posedge clk_100Hz)begin
    if(EN)begin
        if(tree_reset_state == TREE_RESET_NR)begin // recieve the reset
            tree_state = TREE_NONE;
            TREE_SIZE = 1;
            TREE_SIZE_Y = 0;
            x = TREE_INITIAL_POS_X - 1;
            y = TREE_INITIAL_POS_Y;
            tree_reset_state[0] = 1;
        end
        else begin
            tree_reset_state[0] = 0;
            if(x < TREE_INITIAL_POS_X)begin // between the l and the r-bound
                x = (x > SPEED) ? (x - SPEED) : TREE_INITIAL_POS_X + TREE_SIZE;
            end
            else begin 
                if(x - SPEED > TREE_INITIAL_POS_X)begin // somehow more than the l but show something
                    x = x - SPEED;
                end
                else begin // over
                    x = TREE_INITIAL_POS_X - 1;
                    if(rand[3: 0] < 13)begin
                        tree_state = rand[3: 0];
                        if(tree_state > 6)begin
                            TREE_SIZE = TREE_SIZE_B_X;
                            TREE_SIZE_Y = TREE_SIZE_B_Y;
                            if(tree_state == TREE_BD)begin
                                tree_state = TREE_B_1;
                                TREE_SIZE = TREE_SIZE_B_X;
                                TREE_SIZE_Y = TREE_SIZE_B_Y;
                            end
                            if(tree_state == TREE_CL)begin
                                TREE_SIZE = TREE_SIZE_CL_X;
                                TREE_SIZE_Y = TREE_SIZE_CL_Y;
                            end 
                            y = TREE_INITIAL_POS_Y - 50;
                        end
                        else if(tree_state > 0)begin
                            TREE_SIZE = TREE_SIZE_S_X;
                            TREE_SIZE_Y = TREE_SIZE_S_Y;
                            y = TREE_INITIAL_POS_Y - 35;  
                        end
                        else begin
                            TREE_SIZE = 1;
                            TREE_SIZE_Y = 0;
                            y  = TREE_INITIAL_POS_Y;
                            tree_state = TREE_NONE;
                        end
                    end
                    else begin
                        TREE_SIZE = 1;
                        TREE_SIZE_Y = 0;
                        y = TREE_INITIAL_POS_Y;
                        tree_state = TREE_NONE;
                    end
                    
                end
            end
             
        end
    end 
    else begin // not enabled
        if(tree_reset_state == TREE_RESET_NR)begin// reset when not enabled
            tree_state = TREE_NONE;
            TREE_SIZE = 1;
            TREE_SIZE_Y = 0;
            x = TREE_INITIAL_POS_X - 1;
            y = TREE_INITIAL_POS_Y;
            tree_reset_state[0] = 1;
        end
    end
end

always @(posedge clk_25MHz)begin
    case (EN)
        1: begin
            case(tree_reset_state)
                TREE_RESET_OVER_R: begin
                    if(rst)begin
                        tree_reset_state[1] = 1;    
                    end
                    else if(stop)begin
                        tree_reset_state[1] = 0;
                        EN = 0;
                    end
                end
                TREE_RESET_R: begin
                    tree_reset_state[1] = 0;
                end
            endcase
        end
        0: begin
            case(tree_reset_state)
                TREE_RESET_OVER_R: begin
                    if(rst)begin
                        tree_reset_state[1] = 1;    
                    end
                    else begin
                        tree_reset_state[1] = 0;
                    end
                end
                TREE_RESET_R: begin
                    tree_reset_state[1] = 0;
                    EN = 1;
                end
            endcase
        end  
    endcase
end

endmodule


