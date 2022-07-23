module top
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
    output [2:0] rgb
);

    wire reset = ~ reset_n;

    assign led    = 4'hf;
    assign buzzer = 1'b0;
    assign hsync  = 1'b1;
    assign vsync  = 1'b1;
    assign rgb    = 3'b0;
    
    //------------------------------------------------------------------------

    logic [31:0] cnt;
    
    always_ff @ (posedge clk)
      if (reset)
        cnt <= 32'b0;
      else
        cnt <= cnt + 32'b1;
        
    wire enable = (cnt [22:0] == 23'b0);

    //------------------------------------------------------------------------

    logic [3:0] shift_reg;
    
    always_ff @ (posedge clk)
      if (reset)
        shift_reg <= 4'b0001;
      else if (enable)
        shift_reg <= { shift_reg [0], shift_reg [3:1] };

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

    typedef enum bit [7:0]
    {
        A = 8'b00010001,
        B = 8'b11000001,
        C = 8'b01100011,
        K = 8'b01010001,
        U = 8'b10000011
    }
    seven_seg_encoding_e;

    logic [7:0] letter;
    
    always_comb
      case (shift_reg)
      4'b0111: letter = A;
      4'b1011: letter = U;
      4'b1101: letter = C;
      4'b1110: letter = A;
      default: letter = K;
      endcase

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
