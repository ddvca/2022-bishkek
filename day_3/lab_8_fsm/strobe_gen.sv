// Asynchronous reset here is needed for the FPGA board we use

module strobe_gen
# (
    parameter w = 24
)
(
    input  clk,
    input  reset,
    output strobe
);

    wire [w - 1:0] cnt;

    always_ff @ (posedge clk or posedge reset)
      if (reset)
        cnt <= 32'b0;
      else
        cnt <= cnt + 32'b1;

    assign strobe = ~| cnt;  // Same as (cnt == '0)

endmodule
