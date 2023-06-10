module tb;

    logic [1:0] key;
    logic [9:0] sw;

    top i_top (.key (key), .sw (sw));

    initial
    begin
        `ifdef __ICARUS__
            $dumpvars;
        `endif

        repeat (8) #10 { key, sw } <= $urandom ();

        `ifdef MODEL_TECH  // Mentor ModelSim and Questa
            $stop;
        `else
            $finish;
        `endif
    end

endmodule
