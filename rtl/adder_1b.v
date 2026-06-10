`timescale 1ns / 1ps

module full_adder_1b (
    input  wire A,
    input  wire B,
    input  wire C_in,
    output wire Sum,
    output wire C_out
);

    wire xor_ab;
    wire and_ab;
    wire and_cin;

    assign xor_ab = A ^ B;
    assign and_ab = A & B;

    assign Sum = xor_ab ^ C_in;
    assign and_cin = xor_ab & C_in;
    
    assign C_out = and_ab | and_cin;

endmodule