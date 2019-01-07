module rand_gen(
    input               clk,      /*clock signal*/
    input               load,     /*load seed to rand,active high */
    input      [7:0]    seed,     
    output reg [7:0]    rand  /*random number output*/
);
initial rand = 8'hF0;
always@(posedge clk)
begin
    if(load)
        rand <=seed;    /*load the initial value when load is active*/
    else
        begin
            rand[0] <= rand[7];
            rand[1] <= rand[0];
            rand[2] <= rand[1];
            rand[3] <= rand[2];
            rand[4] <= rand[3]^rand[7];
            rand[5] <= rand[4]^rand[7];
            rand[6] <= rand[5]^rand[7];
            rand[7] <= rand[6];
        end
            
end
endmodule