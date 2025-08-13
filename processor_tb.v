`timescale 1ns/1ps

module processor_tb;

    reg clk,rst;
    wire[7:0] pc_out;
    wire[19:0] current_instruction;
    wire halt_signal;
    wire [7:0] reg0_debug, reg1_debug, reg2_debug, reg3_debug;

    processor_top dut(
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .current_instruction(current_instruction),
        .halt_signal(halt_signal),
        .reg0_debug(reg0_debug),
        .reg1_debug(reg1_debug),
        .reg2_debug(reg2_debug),
        .reg3_debug(reg3_debug)
    );
    
    always begin
        clk=1'b0;
        #5;
        clk=1'b1;
        #5;
    end

//     always @(posedge clk) begin
//     $display("DEBUG: PC=%02h, State=%d, fetch_en=%b, instr_ready=%b, pc_en=%b", 
//              dut.pc_out, dut.controller.state, dut.fetch_enable, 
//              dut.instruction_ready, dut.pc_enable);
// end

    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0,processor_tb);
    

    // Display header
        $display("\n=== 8-bit Processor with 20-bit Instructions Test ===");
        $display("Time\tPC\tInstruction\tOpcode\tState\tR0\tR1\tR2\tR3\tHalt");
        $display("----\t--\t-----------\t------\t-----\t--\t--\t--\t--\t----");
        
        // Reset sequence
        rst = 1'b1;
        #25;  // Hold reset for 2.5 clock cycles
        rst = 1'b0;
        $display("Reset released - Processor starting...\n");
        
        // Run the processor and monitor
        repeat(100) begin  // Run for 100 clock cycles
            @(posedge clk);
            #1;  // Small delay to let signals settle
            
            //Display current state
        $display("%4d\t%02h\t%05h\t\t%1h\t%1d\t%02h\t%02h\t%02h\t%02h\t%1b",
         $time/10, pc_out, current_instruction, 
         current_instruction[19:16],  // opcode
         dut.controller.state,
                 // This shows the state
         reg0_debug, reg1_debug, reg2_debug, reg3_debug,
         halt_signal);
            
            // Stop if processor is halted
            if (halt_signal) begin
                $display("\n*** Processor HALTED at time %0t ***", $time);
                // disable ; CHECK THIS OUT
            end
        end
        
        // Final register dump
        $display("\n=== Final Register Values ===");
        $display("R0 = 0x%02h (%3d)", reg0_debug, reg0_debug);
        $display("R1 = 0x%02h (%3d)", reg1_debug, reg1_debug);
        $display("R2 = 0x%02h (%3d)", reg2_debug, reg2_debug);
        $display("R3 = 0x%02h (%3d)", reg3_debug, reg3_debug);
        
        // End simulation
        $display("\n=== Test Complete ===");
    $finish;
    end

endmodule