`timescale 1ns / 1ps

module register_unit_8b (
    input  wire [7:0] Data_In,
    input  wire       CLK,     
    input  wire       RESET, 
    input  wire       REG_OUT,
    output wire [7:0] Bus_Out,
    output wire [7:0] MONITOR   // directly monitor outputs
);

    // register holding the state
    reg [7:0] q_out;

    // 8-bit Memory
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            q_out <= 8'b00000000;
        end else begin
            q_out <= Data_In;
        end
    end

    assign MONITOR = q_out;

    // Outputs q_out to Bus_Out if REG_OUT is 1
    assign Bus_Out = (REG_OUT) ? q_out : 8'bzzzzzzzz;

endmodule