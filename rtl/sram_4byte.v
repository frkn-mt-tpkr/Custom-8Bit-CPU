`timescale 1ns / 1ps

module sram_4byte (
    input  wire [1:0] Address,   // 2-bit address input
    input  wire       RI,        // Write enable (RAM In)
    input  wire       CLK,       
    input  wire       RESET,     
    input  wire [7:0] DATA_IN,   // Data input
    input  wire       RO,        // Read enable (RAM Out)
    output wire [7:0] DATA_OUT   // Data output
);

    // 2-4 Decoder
    wire [3:0] dec_out;
    assign dec_out[0] = (Address == 2'b00);
    assign dec_out[1] = (Address == 2'b01);
    assign dec_out[2] = (Address == 2'b10);
    assign dec_out[3] = (Address == 2'b11);

    // Routes clock to the selected register if RI is 1
    wire clk_0 = RI & CLK & dec_out[0];
    wire clk_1 = RI & CLK & dec_out[1];
    wire clk_2 = RI & CLK & dec_out[2];
    wire clk_3 = RI & CLK & dec_out[3];

    // Internal data bus
    wire [7:0] internal_bus;

    // Memory Cells
    register_unit_8b reg_0 (
        .Data_In(DATA_IN),
        .CLK(clk_0),
        .RESET(RESET),
        .REG_OUT(dec_out[0]),
        .Bus_Out(internal_bus),
        .MONITOR() 
    );

    register_unit_8b reg_1 (
        .Data_In(DATA_IN),
        .CLK(clk_1),
        .RESET(RESET),
        .REG_OUT(dec_out[1]),
        .Bus_Out(internal_bus),
        .MONITOR()
    );

    register_unit_8b reg_2 (
        .Data_In(DATA_IN),
        .CLK(clk_2),
        .RESET(RESET),
        .REG_OUT(dec_out[2]),
        .Bus_Out(internal_bus),
        .MONITOR()
    );

    register_unit_8b reg_3 (
        .Data_In(DATA_IN),
        .CLK(clk_3),
        .RESET(RESET),
        .REG_OUT(dec_out[3]),
        .Bus_Out(internal_bus),
        .MONITOR()
    );

    // Outputs internal_bus to DATA_OUT if RO is 1
    assign DATA_OUT = (RO) ? internal_bus : 8'bzzzzzzzz;

endmodule