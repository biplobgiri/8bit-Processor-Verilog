module register_file(
    input clk, rst, reg_write,
    input [2:0] read_addr_a,read_addr_b,write_addr,
    input[7:0] write_data,
    
    output[7:0] read_data_a,read_data_b
    );

    reg[7:0] registers[0:7];

    assign read_data_a=registers[read_addr_a];
    assign read_data_b=registers[read_addr_b];


integer i=0;

initial begin        
    for (i =0 ;i<8 ;i=i+1 ) begin
            registers[i]<=8'h00;
            
        end
end
    
    
always @(posedge clk) begin
    
    if(rst) begin
        for (i =0 ;i<8 ;i=i+1 ) begin
            // registers[i]<=8'h00;
            
        end
    end
    if(reg_write) begin
    registers[write_addr]<=write_data;
    end
end



endmodule