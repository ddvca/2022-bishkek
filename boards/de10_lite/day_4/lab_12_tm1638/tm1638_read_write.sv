module tm1638_read_write
(
    input  clk,
    input  rst,

    output tm_clk,
    output tm_stb,
    inout  tm_dio

    input              rd,
    output logic [7:0] rd_data,

    input              wr,
    input        [7:0] wr_data,

    output logic       done
);

    //------------------------------------------------------------------------

    logic tm_clk_r;

    always_ff @ (posedge clk)
        tm_clk_r <= tm_clk;

    wire tm_clk_rise =   tm_clk & ~ tm_clk_r;
    wire tm_clk_fall = ~ tm_clk &   tm_clk_r;

    //------------------------------------------------------------------------

    logic       rd_r;
    logic [3:0] cnt;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
        begin
            rd_r <= '0;
            wr_r <= '0;
            cnt  <= '0;
        end
        else if (cnt != '0)
        begin
            cnt  <= cnt - 4'd1;
        end
        else if (rd | wr)
        begin
            rd_r <= rd;
            cnt  <= 4'd8;
        end

    //------------------------------------------------------------------------

    begin
        if (wr & tm_clk_fall)

        if (read & tm_clk_rise)
    end


    input              rd,
    output logic [7:0] rd_data,

    input              wr,


    always_ff @ (posedge clk)
    begin
        if (wr & tm_clk_fall)

        if (read & tm_clk_rise)
    end

endmodule
