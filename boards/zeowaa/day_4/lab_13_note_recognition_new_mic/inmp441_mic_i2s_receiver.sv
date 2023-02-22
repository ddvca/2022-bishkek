module tb;

  logic clk = 1'b1;

  initial
  begin
    $dumpvars;
    repeat (5000) # 5 clk = ~ clk;
    $finish;
  end

  logic rst = 1'b1; 
  initial # 100 rst <= 1'b0;

  logic [8:0] cnt;

  always_ff @ (posedge clk)
    if (rst)
      cnt <= '0;
    else
      cnt <= cnt + 1'd1;

  wire sck = cnt [3];

  logic ws;

  always_ff @ (posedge clk)
    if (rst)
      ws <= '0;
    else if (cnt == 9'd15)
      ws <= ~ ws;

  wire start_sampling
    = ws & (cnt == 9'd39);

  wire sample
    = ws & (cnt >= 9'd39)
         & (cnt <= 9' (39 + 23 * 16))
         & (cnt [3:0] == 4'd7);

endmodule
