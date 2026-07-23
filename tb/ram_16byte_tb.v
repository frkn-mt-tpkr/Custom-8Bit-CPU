`timescale 1ns / 1ps

// Unit testbench for ram_16byte.
// Verifies reset, full 16-cell write/read, and isolation between banks.

module ram_16byte_tb;

    reg  [7:0] ADRES;
    reg        RI;
    reg        RO;
    reg        CLK;
    reg        RESET;
    reg  [7:0] DATA_IN;
    wire [7:0] DATA_OUT;

    integer errors = 0;
    integer k;

    ram_16byte dut (
        .ADRES(ADRES),
        .RI(RI),
        .RO(RO),
        .CLK(CLK),
        .RESET(RESET),
        .DATA_IN(DATA_IN),
        .DATA_OUT(DATA_OUT)
    );

    initial CLK = 0;
    always #5 CLK = ~CLK;

    // Write one byte. Address is 4-bit, zero-extended to the 8-bit port.
    // RI is raised only while CLK is low (single clean gated edge).
    task write_byte(input [3:0] addr, input [7:0] data);
        begin
            RI      = 0;
            ADRES   = {4'b0000, addr};
            DATA_IN = data;
            @(negedge CLK);
            RI      = 1;
            @(posedge CLK);
            #1;
            RI      = 0;
        end
    endtask

    task read_and_check(input [3:0] addr, input [7:0] expected);
        begin
            RI      = 0;
            ADRES   = {4'b0000, addr};
            RO      = 1;
            #1;
            if (DATA_OUT !== expected) begin
                $display("FAIL: RAM[0x%01H]=0x%02H, expected 0x%02H", addr, DATA_OUT, expected);
                errors = errors + 1;
            end else
                $display("PASS: RAM[0x%01H]=0x%02H", addr, DATA_OUT);
            RO      = 0;
        end
    endtask

    initial begin
        $dumpfile("ram_dump.vcd");
        $dumpvars(0, ram_16byte_tb);

        RI = 0; RO = 0; ADRES = 0; DATA_IN = 0;

        // Reset: all 16 cells read back 0
        RESET = 1;
        #12;
        RESET = 0;
        for (k = 0; k < 16; k = k + 1)
            read_and_check(k[3:0], 8'h00);

        // Write a distinct value (0xA0 | addr) to every cell, then read back
        for (k = 0; k < 16; k = k + 1)
            write_byte(k[3:0], 8'hA0 | k[3:0]);
        for (k = 0; k < 16; k = k + 1)
            read_and_check(k[3:0], 8'hA0 | k[3:0]);

        // Bank isolation: writing 0xF (bank 3) must not disturb 0x0 (bank 0)
        write_byte(4'h0, 8'hAA);
        write_byte(4'hF, 8'hBB);
        read_and_check(4'h0, 8'hAA);

        if (errors == 0) $display(" ALL TESTS PASSED ");
        else             $display(" %0d TEST(S) FAILED ", errors);

        $finish;
    end

endmodule
