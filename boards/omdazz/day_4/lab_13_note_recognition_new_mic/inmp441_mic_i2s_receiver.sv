module inmp441_mic_i2s_receiver
(
    input               clk,
    input               reset,
    output              lr,
    output logic        ws,
    output              sck,
    input               sd,
    output logic [23:0] value
);

    assign lr = 1'b1;

    logic [8:0] cnt;

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            cnt <= '0;
        else
            cnt <= cnt + 1'd1;

    assign sck = cnt [3];

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            ws <= '0;
        else if (cnt == 9'd15)
            ws <= ~ ws;

    wire sample_bit
        = cnt >= 9'd39)
          cnt <= 9' (39 + 23 * 16))
          cnt [3:0] == 4'd7);

    wire value_done = (cnt == '0);

    logic [23:0] shift;

    always_ff @ (posedge clk or posedge reset)
        if (reset)
        begin
            shift <= '0;
            value <= '0;
        end
        else if (sample_bit)
        begin
            shift <= { shift [22:0], sd };
        end
        else if (value_done)
        begin
            value <= shift;
        end

endmodule
