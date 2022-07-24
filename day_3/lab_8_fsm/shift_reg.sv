// Asynchronous reset here is needed for the FPGA board we use

module shift_reg
# (
    parameter w = 1
) 
(
    input                  clk,
    input                  reset,
    input                  en,
    input                  seq_in,
    output                 seq_out,
    output logic [w - 1:0] par_out
);

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            par_out <= '0;
        else if (en)
            par_out <= { seq_in, par_out [w - 1 : 1] };

    assign seq_out = par_out [0];

endmodule
