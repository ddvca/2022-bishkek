module top
#(
    parameter shift_strobe_width = 23
)
(
    input           clk,
    input           rst_n,

    input   [ 3:0]  key,
    input   [ 9:0]  sw,
    output  [ 9:0]  led,
    output  [ 7:0]  ledg,

    output  [ 6:0]  hex0,
    output  [ 6:0]  hex1,
    output  [ 6:0]  hex2,
    output  [ 6:0]  hex3,

    inout   [35:0]  gpio
);

    //------------------------------------------------------------------------

    assign ledg = '0;

    wire reset = ~ rst_n;

    //------------------------------------------------------------------------

    wire enable;
    wire fsm_in, moore_fsm_out, mealy_fsm_out;

    wire [9:0] shift_reg_par_out;
    assign led = shift_reg_par_out;

    strobe_gen # (shift_strobe_width) i_strobe_gen
        (.strobe (enable), .*);

    shift_reg # (.depth (10)) i_shift_reg
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
    //   --d--
    //
    //  0 means light

    logic [6:0] gfedcba;

    always_comb
      case ({ mealy_fsm_out, moore_fsm_out })
      2'b00: gfedcba = 7'b111_1111;
      2'b01: gfedcba = 7'b001_1100;  // Moore only
      2'b10: gfedcba = 7'b010_0011;  // Mealy only
      2'b11: gfedcba = 7'b000_0000;
      endcase

    assign hex0 = gfedcba;
    assign { hex3, hex2, hex1 } = '1;

    // Exercise: Implement FSM for recognizing other sequence,
    // for example 0101

endmodule
