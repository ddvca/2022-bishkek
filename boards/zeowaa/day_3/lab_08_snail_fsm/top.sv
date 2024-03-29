module top
(
    input               clk,
    input        [ 3:0] key,
    input        [ 7:0] sw,
    output       [11:0] led,

    output logic [ 7:0] abcdefgh,
    output       [ 7:0] digit,

    output              vsync,
    output              hsync,
    output       [ 2:0] rgb,

    inout        [18:0] gpio
);

    wire reset = ~ key [3];

    assign hsync = 1'b1;
    assign vsync = 1'b1;
    assign rgb   = 3'b0;

    //------------------------------------------------------------------------

    wire enable;
    wire fsm_in, moore_fsm_out, mealy_fsm_out;

    wire [3:0] shift_reg_par_out;
    assign led = ~ shift_reg_par_out;

    strobe_gen i_strobe_gen
        (.strobe (enable), .*);

    shift_reg # (.depth (4)) i_shift_reg
    (
        .en      ( enable            ),
        .seq_in  ( ~& key            ),  // Same as key != 4'b1111
        .seq_out ( fsm_in            ),
        .par_out ( shift_reg_par_out ),
        .*
    );

    snail_moore_fsm i_moore_fsm
        (.en (enable), .a (fsm_in), .y (moore_fsm_out), .*);

    snail_mealy_fsm i_mealy_fsm
        (.en (enable), .a (fsm_in), .y (mealy_fsm_out), .*);

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

    always_comb
      case ({ mealy_fsm_out, moore_fsm_out })
      2'b00: abcdefgh = 8'b1111_1111;
      2'b01: abcdefgh = 8'b0011_1001;  // Moore only
      2'b10: abcdefgh = 8'b1100_0101;  // Mealy only
      2'b11: abcdefgh = 8'b0000_0001;
      endcase

    assign digit = 8'b1111_1110;

    // Exercise: Implement FSM for recognizing other sequence,
    // for example 0101

endmodule
