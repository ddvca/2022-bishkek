module tb;

    logic [3:0] key_sw;

    top i_top (.key_sw (key_sw));

    initial
    begin
        $dumpvars;

        repeat (8) #10 key_sw <= $urandom ();

        `ifdef MODEL_TECH  // Mentor ModelSim and Questa
            $stop;
        `else
            $finish;
        `endif
    end

endmodule
