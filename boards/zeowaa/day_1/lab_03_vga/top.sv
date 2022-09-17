module top
(
    input               clk,
    input        [ 3:0] key,
    input        [ 7:0] sw,
    output       [11:0] led,

    output       [ 7:0] abcdefgh,
    output       [ 7:0] digit,

    output              vsync,
    output              hsync,
    output logic [ 2:0] rgb,

    inout        [18:0] gpio
);

    localparam X_WIDTH = 10,
               Y_WIDTH = 10,
               CLK_MHZ = 50;

    //------------------------------------------------------------------------

    wire reset = ~ key [3];

    assign led      = { key, sw };
    assign abcdefgh = 8'hff;
    assign digit    = 8'hff;

    //------------------------------------------------------------------------

    wire display_on;

    wire [X_WIDTH - 1:0] x;
    wire [Y_WIDTH - 1:0] y;
 
    vga
    # (
        .HPOS_WIDTH ( X_WIDTH      ),
        .VPOS_WIDTH ( Y_WIDTH      ),
        
        .CLK_MHZ    ( CLK_MHZ      )
    )
    i_vga
    (
        .clk        ( clk        ), 
        .reset      ( reset      ),
        .hsync      ( hsync      ),
        .vsync      ( vsync      ),
        .display_on ( display_on ),
        .hpos       ( x          ),
        .vpos       ( y          )
    );

    //------------------------------------------------------------------------

    typedef enum bit [2:0]
    {
      black  = 3'b000,
      cyan   = 3'b011,
      red    = 3'b100,
      yellow = 3'b110,
      white  = 3'b111

      // TODO: Add other colors
    }
    rgb_t;

    always_comb
    begin
      // Circle

      if (~ display_on)
        rgb = black;
      else if (x ** 2 + y ** 2 < 100 ** 2)
        rgb = red;
      else if (x > 200 & y > 200 & x < 300 & y < 400) 
        rgb = yellow;
      else if (key == 4'b1111 & (x - 600) ** 2 + (y - 200) ** 2 < 70 ** 2)
        rgb = white;
      else
        rgb = cyan;

      // TODO: Add other figures
    end

endmodule
