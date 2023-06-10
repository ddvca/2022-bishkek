module top
(
    input           clk,
    input           rst_n,

    input   [ 3:0]  key,
    input   [ 9:0]  sw,
    output  [ 9:0]  led,
    output  [ 7:0]  ledg,

    output  [ 7:0]  hex0,
    output  [ 7:0]  hex1,
    output  [ 7:0]  hex2,
    output  [ 7:0]  hex3,

    inout   [35:0]  gpio
);

    //------------------------------------------------------------------------

    assign ledg = '0;

    wire reset = ~ rst_n;

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

    assign digit = 4'b1110;

    // Exercise: Implement FSM for recognizing other sequence,
    // for example 0101

    wire [31:0] number_to_display =
    {
        shift_strobe_count,
        moore_fsm_out_count,
        mealy_fsm_out_count
    };
BROKEN
    //------------------------------------------------------------------------

    seven_segment_digit i_digit_0 ( number_to_display [ 3: 0], hex0 [6:0]);
    seven_segment_digit i_digit_1 ( number_to_display [ 7: 4], hex1 [6:0]);
    seven_segment_digit i_digit_2 ( number_to_display [11: 8], hex2 [6:0]);
    seven_segment_digit i_digit_3 ( number_to_display [15:12], hex3 [6:0]);
    seven_segment_digit i_digit_4 ( number_to_display [19:16], hex4 [6:0]);
    seven_segment_digit i_digit_5 ( number_to_display [23:20], hex5 [6:0]);

    assign { hex5 [7], hex4 [7], hex3 [7], hex2 [7], hex1 [7], hex0 [7] }
        = ~ sw_db [5:0];

endmodule
