typedef struct packed {
    logic sign;
    logic exponent [7:0];
    logic mantissa [22:0];
} float_t;

typedef struct packed {
    logic sign;
    logic exponent [7:0];
    logic mantissa [47:0];
} internal_float_t;

module fpmad(
    // Input signals
    input float_t i_a, i_b, i_c,
    input clk, rst, valid,
    // Output signals
    output float_t o_res
);

// convert & mantissa multiply
internal_float_t mult_r;
float_t pipe_c;
always_ff@(posedge clk) begin
    if (!rst) begin
        mult_r <= 0;
        pipe_c <= 0;
    end else begin
        mult_r.sign <= i_a.sign ^ i_b.sign;
        mult_r.mantissa[47:0] <= (i_a.mantissa[22:0] | 24'h800000) * (i_b.mantissa[22:0] | 24'h800000);
        mult_r.exponent[7:0] <= i_a.exponent[7:0] + i_b.exponent[7:0] - 127;
        pipe_c <= i_c;
    end
end

// exponent adjust
float_t a, b;
float_t adj_r, adj_c;
always_ff@(posedge clk) begin
    if(!rst) begin
        adj_r <= 0;
        adj_c <= 0;
    end else begin
        if (mult_r.mantissa[47] == 1) begin
            adj_r.mantissa[22:0] <= mult_r.mantissa[47:25] >> 1;
            adj_r.exponent[7:0] <= mult_r.exponent[7:0] + 1;
        end else begin
            adj_r.mantissa[22:0] <= mult_r.mantissa[47:25];
            adj_r.exponent[7:0] <= mult_r.exponent[7:0];
        end
        adj_c <= pipe_c;
    end
end

// Equate exponents & shift mantissas


endmodule
