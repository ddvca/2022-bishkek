module top
# (
    parameter clk_mhz = 50,
              strobe_to_update_xy_counter_width = 20
)
(
    input               clk,
    input        [ 3:0] key,
    input        [ 7:0] sw,
    output logic [11:0] led,

    output logic [ 7:0] abcdefgh,
    output logic [ 7:0] digit,

    output              vsync,
    output              hsync,
    output       [ 2:0] rgb,

    inout        [18:0] gpio
);

    wire   reset       = ~ key [3];

    assign led         =   key;
    assign abcdefgh    =   sw;
    assign digit       =   { key, key };

    wire   left_key    = ~ key [1];
    wire   right_key   = ~ key [0];

    wire   launch_key  =   left_key | right_key;

    game_top
    # (
        .clk_mhz (clk_mhz),

        .strobe_to_update_xy_counter_width
        (strobe_to_update_xy_counter_width)
    )
    i_game_top
    (
        .clk              (   clk                   ),
        .reset            (   reset                 ),

        .launch_key       (   launch_key            ),
        .left_right_keys  ( { left_key, right_key } ),

        .hsync            (   hsync                 ),
        .vsync            (   vsync                 ),
        .rgb              (   rgb                   )
    );

endmodule
