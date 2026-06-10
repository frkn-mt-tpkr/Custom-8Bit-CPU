`timescale 1ns / 1ps

module ram_16byte (
    input  wire [7:0] ADRES,     
    input  wire       RI,        // RAM In
    input  wire       RO,        // RAM Out
    input  wire       CLK,       
    input  wire       RESET,     
    input  wire [7:0] DATA_IN,   
    output wire [7:0] DATA_OUT   
);

    // Address Splitting and Decoding
    wire [1:0] bank_select = ADRES[3:2]; // 2 bits for bank selection
    wire [1:0] word_select = ADRES[1:0]; // 2 bits for word selection

    wire [3:0] dec_out;
    assign dec_out[0] = (bank_select == 2'b00); 
    assign dec_out[1] = (bank_select == 2'b01); 
    assign dec_out[2] = (bank_select == 2'b10); 
    assign dec_out[3] = (bank_select == 2'b11); 

    
    
    wire ri_0 = RI & dec_out[0];
    wire ro_0 = RO & dec_out[0];

    wire ri_1 = RI & dec_out[1];
    wire ro_1 = RO & dec_out[1];

    wire ri_2 = RI & dec_out[2];
    wire ro_2 = RO & dec_out[2];

    wire ri_3 = RI & dec_out[3];
    wire ro_3 = RO & dec_out[3];

    // Memory Banks
    
    sram_4byte bank_0 (
        .Address(word_select),
        .RI(ri_0),
        .CLK(CLK),
        .RESET(RESET),
        .DATA_IN(DATA_IN),
        .RO(ro_0),
        .DATA_OUT(DATA_OUT)
    );

    sram_4byte bank_1 (
        .Address(word_select),
        .RI(ri_1),
        .CLK(CLK),
        .RESET(RESET),
        .DATA_IN(DATA_IN),
        .RO(ro_1),
        .DATA_OUT(DATA_OUT)
    );

    sram_4byte bank_2 (
        .Address(word_select),
        .RI(ri_2),
        .CLK(CLK),
        .RESET(RESET),
        .DATA_IN(DATA_IN),
        .RO(ro_2),
        .DATA_OUT(DATA_OUT)
    );

    sram_4byte bank_3 (
        .Address(word_select),
        .RI(ri_3),
        .CLK(CLK),
        .RESET(RESET),
        .DATA_IN(DATA_IN),
        .RO(ro_3),
        .DATA_OUT(DATA_OUT)
    );

endmodule