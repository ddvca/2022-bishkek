module tb;

    logic         clk;
    logic         rst_n;
    logic  [ 3:0] key;
    logic  [ 9:0] sw;

    top
    # (.shift_strobe_width (1))
    i_top
    (
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .key   ( key   ),
        .sw    ( sw    )
    );

    initial
    begin
        clk = 0;

        forever
            # 5 clk = ~ clk;
    end

    logic reset;
    assign rst_n = ~ reset;

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

        key <= '0;
        sw  <= '0;

        @ (negedge reset);

        repeat (1000)
        begin
            @ (posedge clk);

            key <= $urandom ();
            sw  <= $urandom ();
        end

        `ifdef MODEL_TECH  // Mentor ModelSim and Questa
            $stop;
        `else
            $finish;
        `endif
    end

endmodule
