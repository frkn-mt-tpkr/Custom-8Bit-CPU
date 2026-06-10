`timescale 1ns / 1ps

module alu_8b_add_sub (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire Subtraction,
    output wire [7:0] res,
    output wire Overflow
);

    wire [7:0] b_xor;
    wire c1, c2, c3, c4, c5, c6, c7;

    // Two's complement operation If Subtraction is 1 it inverts B
    assign b_xor[0] = B[0] ^ Subtraction;
    assign b_xor[1] = B[1] ^ Subtraction;
    assign b_xor[2] = B[2] ^ Subtraction;
    assign b_xor[3] = B[3] ^ Subtraction;
    assign b_xor[4] = B[4] ^ Subtraction;
    assign b_xor[5] = B[5] ^ Subtraction;
    assign b_xor[6] = B[6] ^ Subtraction;
    assign b_xor[7] = B[7] ^ Subtraction;

    // 8-bit Adder
    // Subtraction signal enters the first C_in pin as the +1 for two's complement
    full_adder_1b fa0 (.A(A[0]), .B(b_xor[0]), .C_in(Subtraction), .Sum(res[0]), .C_out(c1));
    full_adder_1b fa1 (.A(A[1]), .B(b_xor[1]), .C_in(c1), .Sum(res[1]), .C_out(c2));
    full_adder_1b fa2 (.A(A[2]), .B(b_xor[2]), .C_in(c2), .Sum(res[2]), .C_out(c3));
    full_adder_1b fa3 (.A(A[3]), .B(b_xor[3]), .C_in(c3), .Sum(res[3]), .C_out(c4));
    full_adder_1b fa4 (.A(A[4]), .B(b_xor[4]), .C_in(c4), .Sum(res[4]), .C_out(c5));
    full_adder_1b fa5 (.A(A[5]), .B(b_xor[5]), .C_in(c5), .Sum(res[5]), .C_out(c6));
    full_adder_1b fa6 (.A(A[6]), .B(b_xor[6]), .C_in(c6), .Sum(res[6]), .C_out(c7));
    full_adder_1b fa7 (.A(A[7]), .B(b_xor[7]), .C_in(c7), .Sum(res[7]), .C_out(Overflow));

endmodule