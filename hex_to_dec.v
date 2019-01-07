module hex_to_dec(
    input wire clk_25MHz,
    input wire [31: 0]hex,
    output reg [31: 0]dec = 0
);
reg [31: 0]temp;
always @(posedge clk_25MHz)begin
    temp = hex;
    dec[31: 28] = temp / 10_000_000;
    temp = temp - dec[31: 28] * 10_000_000;
    dec[27: 24] = temp / 1_000_000;
    temp = temp - dec[27: 24] * 1_000_000;
    dec[23: 20] = temp / 100_000;
    temp = temp - dec[23: 20] * 100_000;
    dec[19: 16] = temp / 10_000;
    temp = temp - dec[19: 16] * 10_000;
    dec[15: 12] = temp / 1_000;
    temp = temp - dec[15: 12] * 1_000;
    dec[11: 8] = temp / 100;
    temp = temp - dec[11: 8] * 100;
    dec[7: 4] =  temp / 10;
    temp = temp - dec[7: 4] * 10;
    dec[3: 0] =  temp;
end
endmodule