`timescale 1ns / 1ps

// The `clock_div` module describes the frequency divider.
// It takes a 100MHz clock signal (clk) and divides its frequency
// into 25MHz, 100Hz, and 4Hz. Other modules are driven by these
// divided signals for different but synchronized behaviors.

module clock_div(
    input wire clk,
    output wire clk_25MHz,
    output reg clk_1KHz = 0,
    output reg clk_100Hz = 0,
    output reg clk_50Hz = 0,
    output reg clk_25Hz = 0, 
    output reg clk_4Hz = 0
);

    reg [31:0] clk_counter = 0;
    reg [31:0] clk_counter_1KHz = 0;
    reg [31:0] clk_counter_100Hz = 0;
    reg [31:0] clk_counter_50Hz = 0;
    reg [31:0] clk_counter_25Hz = 0;
    reg [31:0] clk_counter_4Hz = 0;
    
    
    always @ (posedge clk) begin
        clk_counter <= clk_counter + 1;

        if (clk_counter_1KHz == 49_999) begin  
            clk_counter_1KHz <= 0;
            clk_1KHz <= ~clk_1KHz;
        end
        else
            clk_counter_1KHz <= clk_counter_1KHz + 1;

        if (clk_counter_100Hz == 499_999) begin  
            clk_counter_100Hz <= 0;
            clk_100Hz <= ~clk_100Hz;
        end
        else
            clk_counter_100Hz <= clk_counter_100Hz + 1;
        
        if (clk_counter_50Hz == 999_999) begin  
            clk_counter_50Hz<= 0;
            clk_50Hz <= ~clk_50Hz;
        end
        else
            clk_counter_50Hz <= clk_counter_50Hz + 1;

        if (clk_counter_25Hz == 1_999_999) begin  
            clk_counter_25Hz<= 0;
            clk_25Hz <= ~clk_25Hz;
        end
        else
            clk_counter_25Hz <= clk_counter_25Hz + 1;   
        
        if (clk_counter_4Hz == 12_499_999) begin  
            clk_counter_4Hz <= 0;
            clk_4Hz <= ~clk_4Hz;
        end
        else
            clk_counter_4Hz <= clk_counter_4Hz + 1; 

    end
    
    assign clk_25MHz = clk_counter[1];
endmodule
