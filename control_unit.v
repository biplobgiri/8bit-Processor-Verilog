module control_unit(
    input clk, rst,
    input instruction_ready,carry,zero,overflow,negative,
    input[3:0] opcode,

    output reg fetch_enable,
    output reg pc_enable,
    output reg pc_load,
    output reg [7:0] pc_load_value,
    output reg halt
);

    reg [2:0] state, next_state;

    parameter RESET     = 3'b000;
    parameter FETCH     = 3'b001;
    parameter WAIT_FETCH= 3'b010;
    parameter DECODE    = 3'b011;
    parameter EXECUTE   = 3'b100;
    parameter WRITEBACK = 3'b101;
    parameter HALTED    = 3'b110;

    parameter NOP       = 4'b0000;
    parameter ADD       = 4'b0001;
    parameter ADDI      = 4'b0010;
    parameter SUB       = 4'b0011;
    parameter AND_OP    = 4'b0100;
    parameter OR_OP     = 4'b0101;
    parameter XOR_OP    = 4'b0110;
    parameter NOT_OP    = 4'b0111;
    parameter SHL       = 4'b1000;
    parameter SHR       = 4'b1001;
    parameter ROL       = 4'b1010;
    parameter ROR       = 4'b1011;
    parameter CMP       = 4'b1100;
    parameter INC       = 4'b1101;
    parameter MOV       = 4'b1110;
    parameter HALT_OP   = 4'b1111;



always @(posedge clk ) begin
    if (rst) begin
        state<=RESET;
    end
    else begin
        state<=next_state;
end
end

always @(*) begin
    next_state = state;

    case(state)
        RESET: begin
            next_state = FETCH;
        end

        FETCH: begin
            next_state = WAIT_FETCH;
        end

        WAIT_FETCH: begin
            if (instruction_ready) begin
                next_state = DECODE;
            end
            else begin
                next_state = WAIT_FETCH;
            end
        end

        DECODE: begin
            if(opcode == HALT_OP) begin
                next_state = HALTED;
            end
            else begin
                next_state = EXECUTE;
            end 
        end

        EXECUTE: begin
            next_state = WRITEBACK;
        end

        WRITEBACK: begin
            next_state = FETCH;
        end

        HALTED: begin
            next_state = HALTED;
        end

        default: begin
            next_state = RESET;
        end
    endcase
end

always @(*) begin
    fetch_enable = 1'b0;
    pc_enable = 1'b0;
    pc_load = 1'b0;
    pc_load_value = 8'h00;
    halt = 1'b0;

    case(state)
        RESET: begin
            fetch_enable = 1'b0;
            pc_enable = 1'b0;
            pc_load = 1'b1;
            pc_load_value = 8'h00;
            halt = 1'b0;
        end

        FETCH: begin    
            fetch_enable = 1'b1;
            pc_enable = 1'b0;
            pc_load = 1'b0;
            halt = 1'b0;
        end

        WAIT_FETCH: begin  
            if(instruction_ready) begin  
            fetch_enable = 1'b0;
            pc_enable = 1'b0;
            pc_load = 1'b0;
            halt = 1'b0;
        end
        else begin
            fetch_enable=1'b1;
            pc_enable = 1'b0;
            pc_load = 1'b0;
            halt = 1'b0;
        end
        end
            

        DECODE: begin    
            fetch_enable = 1'b0;
            pc_enable = 1'b0;
            pc_load = 1'b0;
            halt = 1'b0;
        end

        EXECUTE: begin    
            fetch_enable = 1'b0;
            pc_enable = 1'b0;
            pc_load = 1'b0;
            halt = 1'b0;
        end

        WRITEBACK: begin    
            fetch_enable = 1'b0;
            pc_enable = 1'b1;
            pc_load = 1'b0;
            halt = 1'b0;
        end

        default: begin
            fetch_enable = 1'b0;
            pc_enable = 1'b0;
            pc_load = 1'b0;
            halt = 1'b0;
        end
    endcase
end


endmodule