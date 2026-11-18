`timescale 1ns / 1ps

// Integration testbench for cpu_top_sap1.

//It loads the program via PROG_MODE, MANUEL_DATA, and the manual control pins. It then starts the CPU and checks the output.

// Program computes 13 + 7 and drives 0x14 onto OUT_PORT.


module cpu_prog_tb;

    reg        MAIN_CLK;
    reg        MAIN_RESET;
    reg        PROG_MODE;
    reg  [7:0] MANUEL_DATA;
    reg        MANUEL_DATA_OE;
    reg        MANUAL_LM;
    reg        MANUAL_L_MBR;
    reg        MANUAL_RI;
    reg        MANUAL_B_OUT;

    wire [7:0] OUT_PORT;

    // Program image loaded from the assembler output
    reg [7:0] program_data [0:15];
    integer   i;

    cpu_top_sap1 uut (
        .MAIN_CLK(MAIN_CLK),
        .MAIN_RESET(MAIN_RESET),
        .PROG_MODE(PROG_MODE),
        .MANUEL_DATA(MANUEL_DATA),
        .MANUEL_DATA_OE(MANUEL_DATA_OE),
        .MANUAL_LM(MANUAL_LM),
        .MANUAL_L_MBR(MANUAL_L_MBR),
        .MANUAL_RI(MANUAL_RI),
        .MANUAL_B_OUT(MANUAL_B_OUT),
        .OUT_PORT(OUT_PORT)
    );

    // Clock: 8 ns period
    initial MAIN_CLK = 0;
    always #4 MAIN_CLK = ~MAIN_CLK;

    // Program one byte via the manual interface, in three pulses:
    //   1) address -> MAR   (MANUAL_LM)
    //   2) data    -> MBR   (MANUAL_L_MBR)
    //   3) MBR     -> RAM   (MANUAL_RI)
    // Each control pin is raised while CLK is low and latched on the next
    // rising edge, matching the gated clocks inside the datapath.
    task prog_write_byte(input [3:0] addr, input [7:0] data);
        begin
            MANUEL_DATA    = {4'b0000, addr};
            MANUEL_DATA_OE = 1;
            @(negedge MAIN_CLK);
            MANUAL_LM      = 1;
            @(posedge MAIN_CLK);
            #1;
            MANUAL_LM      = 0;

            MANUEL_DATA    = data;
            @(negedge MAIN_CLK);
            MANUAL_L_MBR   = 1;
            @(posedge MAIN_CLK);
            #1;
            MANUAL_L_MBR   = 0;

            MANUEL_DATA_OE = 0;
            @(negedge MAIN_CLK);
            MANUAL_RI      = 1;
            @(posedge MAIN_CLK);
            #1;
            MANUAL_RI      = 0;
        end
    endtask

    initial begin
        $dumpfile("cpu_prog_dump.vcd");
        $dumpvars(0, cpu_prog_tb);

        // All pins idle, CPU held in programming mode
        MAIN_RESET     = 0;
        PROG_MODE      = 1;
        MANUEL_DATA    = 0;
        MANUEL_DATA_OE = 0;
        MANUAL_LM      = 0;
        MANUAL_L_MBR   = 0;
        MANUAL_RI      = 0;
        MANUAL_B_OUT   = 0;

        // System reset
        MAIN_RESET = 1;
        #24;
        MAIN_RESET = 0;

        // Read the assembler output into the program image
        $readmemh("asm/program.hex", program_data);

        // Program every byte that was loaded; unused addresses stay 'x'.
        for (i = 0; i < 16; i = i + 1)
            if (program_data[i] !== 8'hxx)
                prog_write_byte(i[3:0], program_data[i]);

        $display("Loaded      : [0]=%02h [1]=%02h [2]=%02h [3]=%02h [4]=%02h [5]=%02h",
            uut.ram.bank_0.reg_0.q_out, uut.ram.bank_0.reg_1.q_out,
            uut.ram.bank_0.reg_2.q_out, uut.ram.bank_0.reg_3.q_out,
            uut.ram.bank_1.reg_0.q_out, uut.ram.bank_1.reg_1.q_out);

        // Hand the bus back and start execution. This reset clears the PC and
        // step counter only; RAM is not tied to reset, so the program survives.
        MANUEL_DATA_OE = 0;
        PROG_MODE      = 0;
        MAIN_RESET     = 1;
        #24;
        MAIN_RESET     = 0;

        $display("After reset : [0]=%02h [1]=%02h [2]=%02h [3]=%02h [4]=%02h [5]=%02h",
            uut.ram.bank_0.reg_0.q_out, uut.ram.bank_0.reg_1.q_out,
            uut.ram.bank_0.reg_2.q_out, uut.ram.bank_0.reg_3.q_out,
            uut.ram.bank_1.reg_0.q_out, uut.ram.bank_1.reg_1.q_out);

        // Run until HLT freezes the step counter, giving up after 2000 cycles
        for (i = 0; i < 2000 && uut.control_unit.halted !== 1'b1; i = i + 1)
            @(posedge MAIN_CLK);

        if (uut.control_unit.halted !== 1'b1)
            $display("TIMEOUT: CPU did not reach HLT");

        if (OUT_PORT !== 8'h14)
            $display("FAIL: OUT_PORT=0x%02H, expected 0x14", OUT_PORT);
        else
            $display("PASS: OUT_PORT=0x%02H", OUT_PORT);

        $finish;
    end

endmodule
