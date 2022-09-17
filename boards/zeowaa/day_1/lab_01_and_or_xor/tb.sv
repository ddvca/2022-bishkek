module tb;

    logic [3:0] key;
    logic [7:0] sw;

    top i_top (.key (key), .sw (sw));

    initial
    begin
        `ifdef __ICARUS__
            $dumpvars;
        `endif

        repeat (8) #10 { key, sw } <= $random;

        `ifdef MODEL_TECH  // Mentor ModelSim and Questa
            $stop;
        `else
            $finish;
        `endif
    end

endmodule
