module program_counter (
    input clk,rst,pc_enable,pc_load,
    input[7:0] pc_in,
    output reg[7:0] pc_out
);
    always @(posedge clk) begin
        if(rst) begin
            pc_out<=8'h00;
        end
        else if(pc_load) begin
            pc_out<=pc_in;
        end

        else if (pc_enable) begin
        pc_out<=pc_out+8'd3;
    end
    end
endmodule