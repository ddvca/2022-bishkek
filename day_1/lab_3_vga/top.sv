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

    always_comb
    begin
      if (x ^ 2 + y ^ 2 < 100 ^ 2)
        rgb = 3'b100;
      else
        rgb = 3'b011;
    end

endmodule
