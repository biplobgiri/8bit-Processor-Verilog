module instruction_decoder(
    input [19:0] instruction,
    output reg [3:0] opcode,
    output reg [2:0] reg_addr_a,
    output reg [2:0] reg_addr_b,
    output reg [2:0] reg_dest,
    output reg [7:0] immediate,
    output reg use_immediate,
    output reg reg_write,
    output reg [3:0] alu_op
);

    // Instruction Format:
    // [19:16] - Opcode (4 bits)
    // [15:13] - Destination register (3 bits)
    // [12:10] - Source register A (3 bits)
    // [9:7]   - Source register B (3 bits)
    // [6:0]   - Immediate value (7 bits, sign-extended to 8 bits)

    // Opcode Parameters
    parameter NOP       = 4'h0;
    parameter ADD       = 4'h1;
    parameter ADDI      = 4'h2;
    parameter SUB       = 4'h3;
    parameter AND_OP    = 4'h4;
    parameter OR_OP     = 4'h5;
    parameter XOR_OP    = 4'h6;
    parameter NOT_OP    = 4'h7;
    parameter SHL       = 4'h8;  // Shift left
    parameter SHR       = 4'h9;  // Shift right
    parameter ROL       = 4'hA;  // Rotate left
    parameter ROR       = 4'hB;  // Rotate right
    parameter CMP       = 4'hC;  // Compare
    parameter INC       = 4'hD;  // Increment
    parameter MOV       = 4'hE;  // Move (can be used as PASS_A)
    parameter HALT      = 4'hF;  // Halt processor

    always @(*) begin
        // Extract fields from instruction
        opcode = instruction[19:16];
        reg_dest = instruction[15:13];
        reg_addr_a = instruction[12:10];
        reg_addr_b = instruction[9:7];
        immediate = {instruction[6], instruction[6:0]};  // Sign extend 7-bit to 8-bit
        
        // Default control signals
        use_immediate = 1'b0;
        reg_write = 1'b0;
        alu_op = 4'h0;
        
        case (opcode)
            NOP: begin
                reg_write = 1'b0;
                alu_op = 4'h0;  // NOP
                use_immediate = 1'b0;
            end
            
            ADD: begin // ADD Rd, Ra, Rb
                reg_write = 1'b1;
                alu_op = 4'h2;  // ADD_REG
                use_immediate = 1'b0;
            end
            
            ADDI: begin // ADDI Rd, Ra, Immediate
                reg_write = 1'b1;
                alu_op = 4'h1;  // ADD_DIRECT
                use_immediate = 1'b1;
            end
            
            SUB: begin // SUB Rd, Ra, Rb
                reg_write = 1'b1;
                alu_op = 4'h3;  // SUBTRACT
                use_immediate = 1'b0;
            end
            
            AND_OP: begin // AND Rd, Ra, Rb
                reg_write = 1'b1;
                alu_op = 4'h4;  // AND
                use_immediate = 1'b0;
            end
            
            OR_OP: begin // OR Rd, Ra, Rb
                reg_write = 1'b1;
                alu_op = 4'h5;  // OR
                use_immediate = 1'b0;
            end
            
            XOR_OP: begin // XOR Rd, Ra, Rb
                reg_write = 1'b1;
                alu_op = 4'h6;  // XOR
                use_immediate = 1'b0;
            end
            
            NOT_OP: begin // NOT Rd, Ra
                reg_write = 1'b1;
                alu_op = 4'h7;  // NOT_A
                use_immediate = 1'b0;
            end
            
            SHL: begin // SHL Rd, Ra
                reg_write = 1'b1;
                alu_op = 4'h8;  // SHIFT_LEFT
                use_immediate = 1'b0;
            end
            
            SHR: begin // SHR Rd, Ra
                reg_write = 1'b1;
                alu_op = 4'h9;  // SHIFT_RIGHT
                use_immediate = 1'b0;
            end
            
            ROL: begin // ROL Rd, Ra
                reg_write = 1'b1;
                alu_op = 4'hA;  // ROTATE_LEFT
                use_immediate = 1'b0;
            end
            
            ROR: begin // ROR Rd, Ra
                reg_write = 1'b1;
                alu_op = 4'hB;  // ROTATE_RIGHT
                use_immediate = 1'b0;
            end
            
            CMP: begin // CMP Ra, Rb (compare, set flags only)
                reg_write = 1'b0;  // Don't write to register
                alu_op = 4'hC;  // COMPARE
                use_immediate = 1'b0;
            end
            
            INC: begin // INC Rd, Ra (increment)
                reg_write = 1'b1;
                alu_op = 4'hD;  // INCREMENT
                use_immediate = 1'b0;
            end
            
            MOV: begin // MOV Rd, Ra (move/copy register)
                reg_write = 1'b1;
                alu_op = 4'h2;  // ADD_REG with Rb = R0 (assuming R0 is always 0)
                use_immediate = 1'b1;
                immediate = 8'h00;  // Add 0 to Ra
            end
            
            HALT: begin // HALT - stop processor
                reg_write = 1'b0;
                alu_op = 4'h0;  // NOP
                use_immediate = 1'b0;
                // Note: HALT handling should be done in control unit
            end
            
            default: begin // Unknown instruction - treat as NOP
                reg_write = 1'b0;
                alu_op = 4'h0;
                use_immediate = 1'b0;
            end
        endcase
    end

endmodule