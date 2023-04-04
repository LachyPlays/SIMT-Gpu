module gpu (
    input clk,
    input rst,
    output out
);
    logic flip;
    assign out = flip;

    always@(posedge clk, negedge rst ) begin
        if(!rst) begin
            flip <= 0;
        end else begin
            flip <= !flip;
        end
    end

endmodule
