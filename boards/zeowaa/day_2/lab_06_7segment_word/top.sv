module top
(
    input         clk,
    input  [ 3:0] key,
    input  [ 7:0] sw,
    output [11:0] led,

    output [ 7:0] abcdefgh,
    output [ 7:0] digit,

    output        vsync,
    output        hsync,
    output [ 2:0] rgb,

    inout  [18:0] gpio
);

    wire   reset  = ~ key [3];

    assign hsync  = 1'b1;
    assign vsync  = 1'b1;
    assign rgb    = 3'b0;

    //------------------------------------------------------------------------

    logic [31:0] cnt;
    
    always_ff @ (posedge clk or posedge reset)
      if (reset)
        cnt <= 32'b0;
      else
        cnt <= cnt + 32'b1;

    wire enable = (cnt [22:0] == 23'b0);

    //------------------------------------------------------------------------

    logic [7:0] shift_reg;
    
    always_ff @ (posedge clk or posedge reset)
      if (reset)
        shift_reg <= 8'b0000_0001;
      else if (enable)
        shift_reg <= { shift_reg [0], shift_reg [7:1] };

    assign led = { 4'b1111, ~ shift_reg };

    //------------------------------------------------------------------------

    //   --a--
    //  |     |
    //  f     b
    //  |     |
    //   --g--
    //  |     |
    //  e     c
    //  |     |
    //   --d--  h
    //
    //  0 means light

    enum bit [7:0]
    {
        A = 8'b00010001,
        B = 8'b11000001,
        C = 8'b01100011,
        K = 8'b01010001,
        U = 8'b10000011
    }
    letter;
    
    always_comb
    begin
      case (shift_reg)
      8'b1000_0000: letter = A;
      8'b0100_0000: letter = U;
      8'b0010_0000: letter = C;
      8'b0001_0000: letter = A;

      8'b0000_1000: letter = A;
      8'b0000_0100: letter = U;
      8'b0000_0010: letter = C;
      8'b0000_0001: letter = A;
      default:      letter = K;
      endcase
    end

    assign abcdefgh = letter;
    assign digit    = ~ shift_reg;

    // Exercise 1: Increase the frequency of enable signal
    // to the level your eyes see the letters as a solid word
    // without any blinking. What is the threshold of such frequency?

    // Exercise 2: Put your name or another word to the display.

    // Exercise 3: Comment out the "default" clause from the "case" statement
    // in the "always" block,and re-synthesize the example.
    // Are you getting any warnings or errors? Try to explain why.

endmodule
