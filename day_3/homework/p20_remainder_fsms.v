module fsm_3_bits_coming_from_right
(
  input              clk,
  input              rst,
  input              new_bit,
  output logic [1:0] rem
);

  logic [1:0] n_rem;

  always_ff @ (posedge clk)
    if (rst)
      rem <= 0;
    else
      rem <= n_rem;

  always_comb
    case (rem)
    2'd0:  n_rem = new_bit ? 2'd1 : 2'd0;
    2'd1:  n_rem = new_bit ? 2'd0 : 2'd2;
    2'd2:  n_rem = new_bit ? 2'd2 : 2'd1;
    default: n_rem = 2'bx;
    endcase

endmodule

//----------------------------------------------------------------------------

module fsm_3_bits_coming_from_left
(
  input              clk,
  input              rst,
  input              new_bit,
  output logic [1:0] rem
);

  // TODO

endmodule

//----------------------------------------------------------------------------

module fsm_4_bits_coming_from_right
(
  input              clk,
  input              rst,
  input              new_bit,
  output logic [1:0] rem
);

  // TODO

endmodule

//----------------------------------------------------------------------------

module fsm_4_bits_coming_from_left
(
  input              clk,
  input              rst,
  input              new_bit,
  output logic [1:0] rem
);

  // TODO

endmodule

//----------------------------------------------------------------------------

module fsm_5_bits_coming_from_right
(
  input              clk,
  input              rst,
  input              new_bit,
  output logic [2:0] rem
);

  // TODO

endmodule

//----------------------------------------------------------------------------

module fsm_5_bits_coming_from_left
(
  input              clk,
  input              rst,
  input              new_bit,
  output logic [2:0] rem
);

  // TODO

endmodule

//----------------------------------------------------------------------------

module fsm_7_bits_coming_from_right
(
  input              clk,
  input              rst,
  input              new_bit,
  output logic [2:0] rem
);

  // TODO

endmodule

//----------------------------------------------------------------------------

module fsm_7_bits_coming_from_left
(
  input              clk,
  input              rst,
  input              new_bit,
  output logic [2:0] rem
);

  // TODO

endmodule

//----------------------------------------------------------------------------

module tb;

  parameter w = 8;

  logic clk;
  logic rst;
  logic new_bit;

  //------------------------------------------------------------------------

  wire [1:0] rem_3_bits_added_from_left;
  wire [1:0] rem_3_bits_added_from_right;

  fsm_3_bits_coming_from_left i_fsm_3_left
  (
    clk,
    rst,
    new_bit,
    rem_3_bits_added_from_left
  );

  fsm_3_bits_coming_from_right i_fsm_3_right
  (
    clk,
    rst,
    new_bit,
    rem_3_bits_added_from_right
  );

  //------------------------------------------------------------------------

  wire [1:0] rem_4_bits_added_from_left;
  wire [1:0] rem_4_bits_added_from_right;

  fsm_4_bits_coming_from_left i_fsm_4_left
  (
    clk,
    rst,
    new_bit,
    rem_4_bits_added_from_left
  );

  fsm_4_bits_coming_from_right i_fsm_4_right
  (
    clk,
    rst,
    new_bit,
    rem_4_bits_added_from_right
  );

  //------------------------------------------------------------------------

  wire [2:0] rem_5_bits_added_from_left;
  wire [2:0] rem_5_bits_added_from_right;

  fsm_5_bits_coming_from_left i_fsm_5_left
  (
    clk,
    rst,
    new_bit,
    rem_5_bits_added_from_left
  );

  fsm_5_bits_coming_from_right i_fsm_5_right
  (
    clk,
    rst,
    new_bit,
    rem_5_bits_added_from_right
  );

  //------------------------------------------------------------------------

  wire [2:0] rem_7_bits_added_from_left;
  wire [2:0] rem_7_bits_added_from_right;

  fsm_7_bits_coming_from_left i_fsm_7_left
  (
    clk,
    rst,
    new_bit,
    rem_7_bits_added_from_left
  );

  fsm_7_bits_coming_from_right i_fsm_7_right
  (
    clk,
    rst,
    new_bit,
    rem_7_bits_added_from_right
  );

  //------------------------------------------------------------------------

  initial
  begin
    clk = 0;

    forever
      # 5 clk = ~ clk;
  end

  logic [w - 1:0] bits_added_from_left;
  logic [w - 1:0] bits_added_from_right;

  always @ (posedge rst) bits_added_from_left <= 0;
  always @ (posedge rst) bits_added_from_right <= 0;

  //------------------------------------------------------------------------

  logic [1:0] expected_rem_3_bits_added_from_left;
  logic [1:0] expected_rem_3_bits_added_from_right;

  logic [1:0] expected_rem_4_bits_added_from_left;
  logic [1:0] expected_rem_4_bits_added_from_right;

  logic [2:0] expected_rem_5_bits_added_from_left;
  logic [2:0] expected_rem_5_bits_added_from_right;

  logic [2:0] expected_rem_7_bits_added_from_left;
  logic [2:0] expected_rem_7_bits_added_from_right;

  //------------------------------------------------------------------------

  initial
  begin
    repeat (4)
    begin
      new_bit <= 0;
      repeat (10) @ (posedge clk);
      rst <= 1;
      repeat (10) @ (posedge clk);
      rst <= 0;
      repeat (10) @ (posedge clk);

      for (int i = 0; i < w; i ++)
      begin
        new_bit <= $urandom;

        @ (posedge clk);
        # 1

        bits_added_from_left
          = bits_added_from_left | (new_bit << i);

        bits_added_from_right
          = (bits_added_from_right << 1) | new_bit;

        //------------------------------------------------------------

        expected_rem_3_bits_added_from_left
          = bits_added_from_left % 3;

        expected_rem_3_bits_added_from_right
          = bits_added_from_right % 3;

        //------------------------------------------------------------

        expected_rem_4_bits_added_from_left
          = bits_added_from_left % 4;

        expected_rem_4_bits_added_from_right
          = bits_added_from_right % 4;

        //------------------------------------------------------------

        expected_rem_5_bits_added_from_left
          = bits_added_from_left % 5;

        expected_rem_5_bits_added_from_right
          = bits_added_from_right % 5;

        //------------------------------------------------------------

        expected_rem_7_bits_added_from_left
          = bits_added_from_left % 7;

        expected_rem_7_bits_added_from_right
          = bits_added_from_right % 7;

        //------------------------------------------------------------

        if (   rem_3_bits_added_from_left
           !== expected_rem_3_bits_added_from_left )
        begin
          $display ("%s FAIL: %d added from left  word=%b %d rem_3=%0d expected=%0d",
            `__FILE__,
            $time,
            bits_added_from_left,
            bits_added_from_left,
            rem_3_bits_added_from_left,
            expected_rem_3_bits_added_from_left );

          $finish;
        end

        if (   rem_3_bits_added_from_right
           !== expected_rem_3_bits_added_from_right )
        begin
          $display ("%s FAIL: %d added from right new_bit %b word=%b %d rem_3=%0d expected=%0d",
            `__FILE__,
            $time,
            new_bit,
            bits_added_from_right,
            bits_added_from_right,
            rem_3_bits_added_from_right,
            expected_rem_3_bits_added_from_right );

          $finish;
        end

        //------------------------------------------------------------

        if (   rem_4_bits_added_from_left
           !== expected_rem_4_bits_added_from_left )
        begin
          $display ("%s FAIL: %d added from left  word=%b %d rem_4=%0d expected=%0d",
            `__FILE__,
            $time,
            bits_added_from_left,
            bits_added_from_left,
            rem_4_bits_added_from_left,
            expected_rem_4_bits_added_from_left );

          $finish;
        end

        if (   rem_4_bits_added_from_right
           !== expected_rem_4_bits_added_from_right )
        begin
          $display ("%s FAIL: %d added from right new_bit %b word=%b %d rem_4=%0d expected=%0d",
            `__FILE__,
            $time,
            new_bit,
            bits_added_from_right,
            bits_added_from_right,
            rem_4_bits_added_from_right,
            expected_rem_4_bits_added_from_right );

          $finish;
        end

        //------------------------------------------------------------

        if (   rem_5_bits_added_from_left
           !== expected_rem_5_bits_added_from_left )
        begin
          $display ("%s FAIL: %d added from left  word=%b %d rem_5=%0d expected=%0d",
            `__FILE__,
            $time,
            bits_added_from_left,
            bits_added_from_left,
            rem_5_bits_added_from_left,
            expected_rem_5_bits_added_from_left );

          $finish;
        end

        if (   rem_5_bits_added_from_right
           !== expected_rem_5_bits_added_from_right )
        begin
          $display ("%s FAIL: %d added from right new_bit %b word=%b %d rem_5=%0d expected=%0d",
            `__FILE__,
            $time,
            new_bit,
            bits_added_from_right,
            bits_added_from_right,
            rem_5_bits_added_from_right,
            expected_rem_5_bits_added_from_right );

          $finish;
        end

        //------------------------------------------------------------

        if (   rem_7_bits_added_from_left
           !== expected_rem_7_bits_added_from_left )
        begin
          $display ("%s FAIL: %d added from left  word=%b %d rem_7=%0d expected=%0d",
            `__FILE__,
            $time,
            bits_added_from_left,
            bits_added_from_left,
            rem_7_bits_added_from_left,
            expected_rem_7_bits_added_from_left );

          $finish;
        end

        if (   rem_7_bits_added_from_right
           !== expected_rem_7_bits_added_from_right )
        begin
          $display ("%s FAIL: %d added from right new_bit %b word=%b %d rem_7=%0d expected=%0d",
            `__FILE__,
            $time,
            new_bit,
            bits_added_from_right,
            bits_added_from_right,
            rem_7_bits_added_from_right,
            expected_rem_7_bits_added_from_right );

          $finish;
        end
      end
    end

    //--------------------------------------------------------------------

    $display ("%s PASS", `__FILE__);
    $finish;
  end

endmodule
