module tb;

    logic       clk;
    logic [3:0] key;
    logic [7:0] sw;

    top
    # (
        .clk_mhz (1),
        .strobe_to_update_xy_counter_width (1)
    )
    i_top
    (
        .clk ( clk ),
        .key ( key ),
        .sw  ( sw  )
    );

    initial
    begin
        clk = 1'b0;

        forever
            # 5 clk = ~ clk;
    end

    logic reset;

    always_comb
        key [3] = ~ reset;

    initial
    begin
        reset <= 1'bx;
        repeat (2) @ (posedge clk);
        reset <= 1'b1;
        repeat (2) @ (posedge clk);
        reset <= 1'b0;
    end

    initial
    begin
        `ifdef __ICARUS__
            $dumpvars;
        `endif

        key [2:0] <= 'b0;
        sw        <= 'b0;

        @ (negedge reset);

        repeat (1000)
        begin
            @ (posedge clk);

            key [2:0] <= $urandom ();
            sw        <= $urandom ();
        end

        `ifdef MODEL_TECH  // Mentor ModelSim and Questa
            $stop;
        `else
            $finish;
        `endif
    end

endmodule
