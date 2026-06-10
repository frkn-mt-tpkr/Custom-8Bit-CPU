`timescale 1ns / 1ps

module cpu_tb;

    // Testbench Signals
    reg MAIN_CLK;
    reg MAIN_RESET;
    reg PROG_MODE;
    reg [7:0] MANUEL_DATA;
    reg MANUEL_DATA_OE;
    reg MANUAL_LM;
    reg MANUAL_L_MBR;
    reg MANUAL_RI;
    reg MANUAL_Sub;
    reg MANUAL_B_OUT;

    wire [7:0] OUT_PORT;

    // Unit Under Test
    cpu_top_sap1 uut (
        .MAIN_CLK(MAIN_CLK),
        .MAIN_RESET(MAIN_RESET),
        .PROG_MODE(PROG_MODE),
        .MANUEL_DATA(MANUEL_DATA),
        .MANUEL_DATA_OE(MANUEL_DATA_OE),
        .MANUAL_LM(MANUAL_LM),
        .MANUAL_L_MBR(MANUAL_L_MBR),
        .MANUAL_RI(MANUAL_RI),
        .MANUAL_Sub(MANUAL_Sub),
        .MANUAL_B_OUT(MANUAL_B_OUT),
        .OUT_PORT(OUT_PORT)
    );

    // 125 MHz Clock Signal (Period: 8ns)
    initial MAIN_CLK = 0;
    always #4 MAIN_CLK = ~MAIN_CLK;


    // RAM Initialization via $readmemh
    // Temporary array to load hex file contents
    reg [7:0] program_data [0:15];
    integer i;

    // SIMULATION
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, cpu_tb);

        // Load program from hex file into array
        $readmemh("tb/program.hex", program_data);

        // Reset all CPU registers
        MAIN_RESET = 1;
        PROG_MODE  = 1;  // Stop the Control Unit
        MANUEL_DATA = 0;
        MANUEL_DATA_OE = 0;
        MANUAL_LM = 0;
        MANUAL_L_MBR = 0;
        MANUAL_RI = 0;
        MANUAL_Sub = 0;
        MANUAL_B_OUT = 0;

        #24;
        MAIN_RESET = 0;

        // Load program into RAM

        // Bank 0 (Address 0x0 - 0x3)
        uut.ram.bank_0.reg_0.q_out = program_data[0];
        uut.ram.bank_0.reg_1.q_out = program_data[1];
        uut.ram.bank_0.reg_2.q_out = program_data[2];
        uut.ram.bank_0.reg_3.q_out = program_data[3];

        // Bank 1 (Address 0x4 - 0x7)
        uut.ram.bank_1.reg_0.q_out = program_data[4];
        uut.ram.bank_1.reg_1.q_out = program_data[5];
        uut.ram.bank_1.reg_2.q_out = program_data[6];
        uut.ram.bank_1.reg_3.q_out = program_data[7];

        // Bank 2 (Address 0x8 - 0xB)
        uut.ram.bank_2.reg_0.q_out = program_data[8];
        uut.ram.bank_2.reg_1.q_out = program_data[9];
        uut.ram.bank_2.reg_2.q_out = program_data[10];
        uut.ram.bank_2.reg_3.q_out = program_data[11];

        // Bank 3 (Address 0xC - 0xF)
        uut.ram.bank_3.reg_0.q_out = program_data[12];
        uut.ram.bank_3.reg_1.q_out = program_data[13];
        uut.ram.bank_3.reg_2.q_out = program_data[14];
        uut.ram.bank_3.reg_3.q_out = program_data[15];

        // Display loaded program
        $display("Program loaded from program.hex");
        for (i = 0; i < 16; i = i + 1) begin
            if (program_data[i] !== 8'hxx)
                $display("  RAM[%0d] = 0x%02H", i, program_data[i]);
        end

        // Start the processor
        PROG_MODE = 0; // Release Control Unit — processor starts executing

        $display("Processor is running...");

        #600;

        // End simulation
        $finish;
    end

endmodule