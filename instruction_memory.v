module instruction_memory(
    input clk,
    input rst,
    input [7:0] pc,
    input fetch_enable,
    output reg [19:0] instruction,
    output reg instruction_ready
);

    reg [7:0] mem [0:255];
    reg [1:0] fetch_state;
    reg [7:0] byte0, byte1, byte2;
    
    parameter IDLE     = 2'b00;
    parameter FETCH_B0 = 2'b01;
    parameter FETCH_B1 = 2'b10;
    parameter FETCH_B2 = 2'b11;
    
    initial begin
        $readmemh("program.txt", mem);
        fetch_state = IDLE;
        instruction = 20'h00000;
        instruction_ready = 1'b0;
    end
    
    always @(posedge clk) begin
        if (rst) begin
            fetch_state <= IDLE;
            instruction <= 20'h00000;
            instruction_ready <= 1'b0;
        end
        else begin
            case (fetch_state)
                IDLE: begin
                    instruction_ready <= 1'b0;
                    if (fetch_enable) begin
                        fetch_state <= FETCH_B0;
                    end
                end
                
                FETCH_B0: begin
                    byte0 = mem[pc];
                    fetch_state <= FETCH_B1;

                end
                
                FETCH_B1: begin
                    byte1 = mem[pc + 8'd1];
                    fetch_state <= FETCH_B2;
                end
                
                FETCH_B2: begin
                    byte2 = mem[pc + 8'd2];
                    instruction <= {byte2[3:0], byte1, byte0};
                    instruction_ready <= 1'b1;
                    fetch_state <= IDLE;

                end
            endcase
        end
    end
    
endmodule