// Asynchronous reset here is needed for the FPGA board we use

module top
# (
    parameter clk_frequency = 50 * 1000 * 1000
)
(
    input        clk,
    input        reset_n,
    
    input  [3:0] key_sw,
    output [3:0] led,

    output [7:0] abcdefgh,
    output [3:0] digit,

    output       buzzer,

    output       hsync,
    output       vsync,
    output [2:0] rgb,

    input        rx
);

    wire reset = ~ reset_n;

    assign buzzer = 1'b0;
    assign hsync  = 1'b1;
    assign vsync  = 1'b1;
    assign rgb    = 3'b0;

    // [3:0] led
    // [7:0] abcdefgh
    // [3:0] digit

endmodule
