module processor_top(
    input clk,rst,
    output[7:0] pc_out,
    output[19:0] current_instruction,
    output halt_signal,
    output [7:0] reg0_debug,
    output [7:0] reg1_debug,
    output [7:0] reg2_debug,
    output [7:0] reg3_debug
);
//program counter
wire [7:0] pc;
wire pc_enable, pc_load;
wire[7:0] pc_load_value;

//instruction memory 
wire[19:0] instruction;
wire instruction_ready;
wire fetch_enable;

//Instruction Decoder 
wire[3:0] opcode;
wire[2:0] reg_addr_a,reg_addr_b,reg_dest;
wire[7:0] immediate;
wire use_immediate, reg_write;
wire[3:0] alu_op;

// Register File 
wire [7:0] reg_data_a, reg_data_b;
wire [7:0] alu_result;

//ALU
wire [7:0] alu_operand_b;
wire zero,carry,negative,overflow;

wire halt;

assign alu_operand_b=use_immediate?immediate:reg_data_b;

//debug outputs
assign pc_out=pc;
assign current_instruction=instruction;
assign halt_signal=halt;

//INSTANTIATIONS

//PROGRAM COUNTER
    program_counter pc_unit(
        .clk(clk),
        .rst(rst),
        .pc_enable(pc_enable),
        .pc_load(pc_load),
        .pc_in(pc_load_value),
        .pc_out(pc)
    );

instruction_memory imem(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .fetch_enable(fetch_enable),
        .instruction(instruction),
        .instruction_ready(instruction_ready)
    );

    // Instruction Decoder
    instruction_decoder decoder(
        .instruction(instruction),
        .opcode(opcode),
        .reg_addr_a(reg_addr_a),
        .reg_addr_b(reg_addr_b),
        .reg_dest(reg_dest),
        .immediate(immediate),
        .use_immediate(use_immediate),
        .reg_write(reg_write),
        .alu_op(alu_op)
    );


    register_file regfile(
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_addr_a(reg_addr_a),
        .read_addr_b(reg_addr_b),
        .write_addr(reg_dest),
        .write_data(alu_result),
        .read_data_a(reg_data_a),
        .read_data_b(reg_data_b)
    );

    alu alu_unit(
        .operand_a(reg_data_a),
        .operand_b(alu_operand_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(zero),
        .carry(carry),
        .negative(negative),
        .overflow(overflow)
    );

        control_unit controller(
        .clk(clk),
        .rst(rst),
        .instruction_ready(instruction_ready),
        .zero(zero),
        .carry(carry),
        .negative(negative),
        .overflow(overflow),
        .opcode(opcode),
        .fetch_enable(fetch_enable),
        .pc_enable(pc_enable),
        .pc_load(pc_load),
        .pc_load_value(pc_load_value),
        .halt(halt)
    );

    assign reg0_debug = regfile.registers[0];
    assign reg1_debug = regfile.registers[1];
    assign reg2_debug = regfile.registers[2];
    assign reg3_debug = regfile.registers[3];



endmodule