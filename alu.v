module alu(
    input [7:0] operand_a,
    input [7:0] operand_b,
    input [3:0] alu_op,
    output reg [7:0] result,
    output reg zero,
    output reg carry,
    output reg negative,
    output reg overflow
);

    // ALU Operation Parameters
    parameter NOP         = 4'h0;
    parameter ADD_DIRECT  = 4'h1;  // Add immediate (operand_a + operand_b)
    parameter ADD_REG     = 4'h2;  // Add registers (same as ADD_DIRECT in ALU)
    parameter SUBTRACT    = 4'h3;  // Subtract (operand_a - operand_b)
    parameter AND         = 4'h4;  // Bitwise AND
    parameter OR          = 4'h5;  // Bitwise OR
    parameter XOR         = 4'h6;  // Bitwise XOR
    parameter NOT_A       = 4'h7;  // Bitwise NOT of operand_a
    parameter SHIFT_LEFT  = 4'h8;  // Logical shift left
    parameter SHIFT_RIGHT = 4'h9;  // Logical shift right
    parameter ROTATE_LEFT = 4'hA;  // Rotate left
    parameter ROTATE_RIGHT= 4'hB;  // Rotate right
    parameter COMPARE     = 4'hC;  // Compare (same as subtract but don't store result)
    parameter INCREMENT   = 4'hD;  // Increment operand_a by 1

    reg [8:0] temp_result;  // 9-bit to capture carry
    reg [7:0] temp_8bit;    // For operations that don't need carry

    always @(*) begin
        // Default values
        temp_result = 9'h000;
        temp_8bit = 8'h00;
        carry = 1'b0;
        overflow = 1'b0;
        
        case (alu_op)
            NOP: begin
                temp_result = 9'h000;
            end
            
            ADD_DIRECT, ADD_REG: begin
                temp_result = operand_a + operand_b;
                carry = temp_result[8];
                // Overflow: positive + positive = negative OR negative + negative = positive
                overflow = (~operand_a[7] & ~operand_b[7] & temp_result[7]) | 
                          (operand_a[7] & operand_b[7] & ~temp_result[7]);
            end
            
            SUBTRACT: begin
                temp_result = operand_a - operand_b;
                carry = (operand_a < operand_b) ? 1'b1 : 1'b0;  // Borrow
                // Overflow: positive - negative = negative OR negative - positive = positive
                overflow = (~operand_a[7] & operand_b[7] & temp_result[7]) | 
                          (operand_a[7] & ~operand_b[7] & ~temp_result[7]);
            end
            
            AND: begin
                temp_8bit = operand_a & operand_b;
                temp_result = {1'b0, temp_8bit};
            end
            
            OR: begin
                temp_8bit = operand_a | operand_b;
                temp_result = {1'b0, temp_8bit};
            end
            
            XOR: begin
                temp_8bit = operand_a ^ operand_b;
                temp_result = {1'b0, temp_8bit};
            end
            
            NOT_A: begin
                temp_8bit = ~operand_a;
                temp_result = {1'b0, temp_8bit};
            end
            
            SHIFT_LEFT: begin
                temp_result = {operand_a, 1'b0};  // Shift left, carry gets MSB
                carry = operand_a[7];
            end
            
            SHIFT_RIGHT: begin
                temp_8bit = operand_a >> 1;
                temp_result = {1'b0, temp_8bit};
                carry = operand_a[0];  // LSB goes to carry
            end
            
            ROTATE_LEFT: begin
                temp_8bit = {operand_a[6:0], operand_a[7]};
                temp_result = {1'b0, temp_8bit};
                carry = operand_a[7];
            end
            
            ROTATE_RIGHT: begin
                temp_8bit = {operand_a[0], operand_a[7:1]};
                temp_result = {1'b0, temp_8bit};
                carry = operand_a[0];
            end
            
            COMPARE: begin
                temp_result = operand_a - operand_b;
                carry = (operand_a < operand_b) ? 1'b1 : 1'b0;
                // For compare, we calculate but don't output the result
            end
            
            INCREMENT: begin
                temp_result = operand_a + 1;
                carry = temp_result[8];
                overflow = (~operand_a[7] & temp_result[7]);  // Only pos->neg overflow possible
            end
            
            default: begin
                temp_result = 9'h000;
            end
        endcase
        
        // Set result and flags
        if (alu_op == COMPARE) begin
            result = 8'h00;  // Don't output result for compare
        end else begin
            result = temp_result[7:0];
        end
        
        // Flag generation
        zero = (temp_result[7:0] == 8'h00);
        negative = temp_result[7];
    end

endmodule