`timescale 1ns / 1ps
//
// Unit testbench for sram_4byte.
// Verifies reset, per-cell write/read, and write isolation between cells.
//

module sram_4byte_tb;

    reg  [1:0] Address;
    reg        RI;
    reg        CLK;
    reg        RESET;
    reg  [7:0] DATA_IN;
    reg        RO;
    wire [7:0] DATA_OUT;

    integer errors = 0;
    integer k;

    sram_4byte dut (
        .Address(Address),
        .RI(RI),
        .CLK(CLK),
        .RESET(RESET),
        .DATA_IN(DATA_IN),
        .RO(RO),
        .DATA_OUT(DATA_OUT)
    );

    initial CLK = 0;
    always #5 CLK = ~CLK;

    // Write one byte to a cell. RI is raised only while CLK is low, so the
    // gated cell clock (RI & CLK & dec_out[N]) sees a single clean rising edge.
    task write_byte(input [1:0] addr, input [7:0] data);
        begin
            RI      = 0;
            Address = addr;
            DATA_IN = data;
            @(negedge CLK);
            RI      = 1;
            @(posedge CLK);
            #1;
            RI      = 0;
        end
    endtask

    // Read one cell (combinational) and compare against the expected value.
    task read_and_check(input [1:0] addr, input [7:0] expected);
        begin
            RI      = 0;
            Address = addr;
            RO      = 1;
            #1;
            if (DATA_OUT !== expected) begin
                $display("FAIL: RAM[%0d]=0x%02H, expected 0x%02H", addr, DATA_OUT, expected);
                errors = errors + 1;
            end else
                $display("PASS: RAM[%0d]=0x%02H", addr, DATA_OUT);
            RO      = 0;
        end
    endtask

    initial begin
        $dumpfile("sram_dump.vcd");
        $dumpvars(0, sram_4byte_tb);

        RI = 0; RO = 0; Address = 0; DATA_IN = 0;

        // Reset: all cells read back 0
        RESET = 1;
        #12;
        RESET = 0;
        for (k = 0; k < 4; k = k + 1)
            read_and_check(k[1:0], 8'h00);

        // Write four distinct values, then read them all back
        write_byte(2'b00, 8'h11);
        write_byte(2'b01, 8'h22);
        write_byte(2'b10, 8'h33);
        write_byte(2'b11, 8'h44);
        read_and_check(2'b00, 8'h11);
        read_and_check(2'b01, 8'h22);
        read_and_check(2'b10, 8'h33);
        read_and_check(2'b11, 8'h44);

        // Isolation: writing cell 1 must not disturb cell 0
        write_byte(2'b00, 8'hAA);
        write_byte(2'b01, 8'hBB);
        read_and_check(2'b00, 8'hAA);

        if (errors == 0) $display(" ALL TESTS PASSED ");
        else             $display(" %0d TEST(S) FAILED ", errors);

        $finish;
    end

endmodule
