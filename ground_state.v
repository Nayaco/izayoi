module ground_state(
    input wire clk_100Hz,
    output reg [15: 0]ground_x
);

parameter px_Perclk = 3;
always @(posedge clk_100Hz)begin
    if(ground_x < 559)ground_x <= ground_x + px_Perclk;
    else ground_x <= 0;
end

endmodule
