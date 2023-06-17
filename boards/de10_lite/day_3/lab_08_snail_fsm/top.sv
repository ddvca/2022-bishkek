module top
#(
    parameter shift_strobe_width = 23
)
(
    input           clk,

    input   [ 1:0]  key,
    input   [ 9:0]  sw,
    output  [ 9:0]  led,

    output  [ 7:0]  hex0,
    output  [ 7:0]  hex1,
    output  [ 7:0]  hex2,
    output  [ 7:0]  hex3,
    output  [ 7:0]  hex4,
    output  [ 7:0]  hex5,

    output          vga_hs,
    output          vga_vs,
    output  [ 3:0]  vga_r,
    output  [ 3:0]  vga_g,
    output  [ 3:0]  vga_b,

    inout   [35:0]  gpio
);

    //------------------------------------------------------------------------

    wire reset = ~ key [0];

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
        .seq_in  ( ~ key [1]         ),
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

    logic [7:0] hgfedcba;

    always_comb
      case ({ mealy_fsm_out, moore_fsm_out })
      2'b00: hgfedcba = 8'b1111_1111;
      2'b01: hgfedcba = 8'b1001_1100;  // Moore only
      2'b10: hgfedcba = 8'b1010_0011;  // Mealy only
      2'b11: hgfedcba = 8'b1000_0000;
      endcase

    assign hex0 = hgfedcba;
    assign { hex5, hex4, hex3, hex2, hex1 } = '1;

    // Exercise: Implement FSM for recognizing other sequence,
    // for example 0101

endmodule
