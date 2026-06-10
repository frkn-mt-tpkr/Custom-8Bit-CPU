`timescale 1ns / 1ps

module program_counter (
    input  wire       CLK,
    input  wire       PC_INC,
    input  wire       RESET,
    input  wire       PC_OUT,
    output wire [7:0] Bus_Out
);

    // Internal connections
    wire       gated_clk;    
    wire [7:0] pc_monitor;   // Current PC
    wire [7:0] next_pc;      // PC + 1
    wire       overflow_nc;  // Overflow output

    // Allows clock signal when PC_INC is 1
    assign gated_clk = CLK & PC_INC;

    // 8-bit Register
    register_unit_8b reg_inst (
        .Data_In(next_pc),
        .CLK(gated_clk),
        .RESET(RESET),
        .REG_OUT(PC_OUT),
        .Bus_Out(Bus_Out),
        .MONITOR(pc_monitor)
    );

    // ALU used to increment PC value by 1
    alu_8b_add_sub alu_inst (
        .A(pc_monitor),
        .B(8'b00000001),     // Constant 1 value
        .Subtraction(1'b0),  // Addition mode
        .res(next_pc),
        .Overflow(overflow_nc)
    );

endmodule