module top
(
    input              clk,
    input              reset_n,

    input        [3:0] key_sw,
    output       [3:0] led,

    output       [7:0] abcdefgh,
    output       [3:0] digit,

    output             buzzer,

    output             hsync,
    output             vsync,
    output logic [2:0] rgb
);

    localparam X_WIDTH = 10,
               Y_WIDTH = 10,
               CLK_MHZ = 50;

    //------------------------------------------------------------------------

    assign led       = key_sw;
    assign abcdefgh  = 8'hff;
    assign digit     = 4'hf;
    assign buzzer    = 1'b0;

    //------------------------------------------------------------------------

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
        .clk        (   clk        ), 
        .reset      ( ~ reset_n    ),
        .hsync      (   hsync      ),
        .vsync      (   vsync      ),
        .display_on (              ),
        .hpos       (   x          ),
        .vpos       (   y          )
    );

    //------------------------------------------------------------------------

    typedef enum bit [2:0]
    {
      red    = 3'b100,
      yellow = 3'b110,
      cyan   = 3'b011

      // TODO: Add other colors
    }
    rgb_t;

    always_comb
    begin
      // Circle

      if (x ** 2 + y ** 2 < 100 ** 2)
        rgb = red;
      else if (x > 200 & y > 200 & x < 300 & y < 400) 
        rgb = yellow;
      else
        rgb = cyan;

      // TODO: Add other figures
    end

endmodule