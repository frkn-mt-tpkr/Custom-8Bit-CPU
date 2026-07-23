`timescale 1ns / 1ps
//
// Unit testbench for register_unit_8b.
// Verifies async reset, clocked load, and tri-state output.
//

module register_unit_tb;

    // Testbench signals
    reg  [7:0] Data_In;
    reg        CLK;
    reg        RESET;
    reg        REG_OUT;
    wire [7:0] Bus_Out;
    wire [7:0] MONITOR;

    integer errors = 0;

    // Unit under test
    register_unit_8b dut (
        .Data_In(Data_In),
        .CLK(CLK),
        .RESET(RESET),
        .REG_OUT(REG_OUT),
        .Bus_Out(Bus_Out),
        .MONITOR(MONITOR)
    );

    // Clock: 10 ns period
    initial CLK = 0;
    always #5 CLK = ~CLK;

    initial begin
        $dumpfile("register_dump.vcd");
        $dumpvars(0, register_unit_tb);

        // Async reset clears the register
        Data_In = 8'hFF;
        REG_OUT = 0;
        RESET   = 1;
        #12;
        RESET   = 0;
        if (MONITOR !== 8'h00) begin
            $display("FAIL: reset -> MONITOR=0x%02H, expected 0x00", MONITOR);
            errors = errors + 1;
        end else
            $display("PASS: reset");

        // Value latches on the rising clock edge
        Data_In = 8'hA5;
        @(posedge CLK);
        #1;
        if (MONITOR !== 8'hA5) begin
            $display("FAIL: MONITOR=0x%02H, expected 0xA5", MONITOR);
            errors = errors + 1;
        end else
            $display("PASS: load");

        // Output stays high-Z while REG_OUT is 0
        if (Bus_Out !== 8'bzzzzzzzz) begin
            $display("FAIL: Bus_Out driven while REG_OUT=0");
            errors = errors + 1;
        end else
            $display("PASS: Bus_Out high-Z");

        // REG_OUT=1 drives the stored value onto the bus
        REG_OUT = 1;
        #1;
        if (Bus_Out !== 8'hA5) begin
            $display("FAIL: Bus_Out=0x%02H, expected 0xA5", Bus_Out);
            errors = errors + 1;
        end else
            $display("PASS: Bus_Out driven");

        REG_OUT = 0;
        #1;
        if (Bus_Out !== 8'bzzzzzzzz) begin
            $display("FAIL: Bus_Out driven after REG_OUT=0");
            errors = errors + 1;
        end else
            $display("PASS: Bus_Out high-Z again");

        // No load-enable: every clock edge overwrites the stored value
        Data_In = 8'h3C;
        @(posedge CLK);
        #1;
        if (MONITOR !== 8'h3C) begin
            $display("FAIL: MONITOR=0x%02H, expected 0x3C", MONITOR);
            errors = errors + 1;
        end else
            $display("PASS: overwrites on every clock edge");

        if (errors == 0) $display(" ALL TESTS PASSED ");
        else             $display(" %0d TEST(S) FAILED ", errors);

        $finish;
    end

endmodule
