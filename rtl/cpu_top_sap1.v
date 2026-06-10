`timescale 1ns / 1ps

module cpu_top_sap1 (
    // System Signals
    input  wire       MAIN_CLK,
    input  wire       MAIN_RESET,
    
    // Programming Mode Signals
    input  wire       PROG_MODE,
    input  wire [7:0] MANUEL_DATA,
    input  wire       MANUEL_DATA_OE,
    
    // Manual Control Pins
    input  wire       MANUAL_LM,
    input  wire       MANUAL_L_MBR,
    input  wire       MANUAL_RI,
    input  wire       MANUAL_Sub,
    input  wire       MANUAL_B_OUT,
    
    // Output
    output wire [7:0] OUT_PORT
);

    wire [7:0] main_bus;

    // If PROG_MODE is 1, Control Unit's clock is disabled
    wire cu_clk = MAIN_CLK & ~PROG_MODE;

    wire cu_pc_out, cu_pc_inc, cu_li, cu_lm, cu_ei, cu_l_mbr;
    wire cu_ri, cu_ro, cu_la, cu_lb, cu_alu_out, cu_lo, cu_a_out;

    control_unit_sap1_custom control_unit (
        .CLK(cu_clk),
        .RESET(MAIN_RESET),
        .OPCODE(ir_monitor[7:4]),
        .PC_OUT(cu_pc_out),
        .PC_INC(cu_pc_inc),
        .LI(cu_li),
        .LM(cu_lm),
        .EI(cu_ei),
        .L_MBR(cu_l_mbr),
        .RI(cu_ri),
        .RO(cu_ro),
        .LA(cu_la),
        .LB(cu_lb),
        .ALU_OUT(cu_alu_out),
        .LO(cu_lo),
        .A_OUT(cu_a_out)
    );

    // Prevent CU from occupying the Bus when PROG_MODE is 1
    wire pc_out   = cu_pc_out  & ~PROG_MODE;
    wire ei       = cu_ei      & ~PROG_MODE;
    wire a_out    = cu_a_out   & ~PROG_MODE;
    wire alu_out  = cu_alu_out & ~PROG_MODE;
    wire ro       = cu_ro      & ~PROG_MODE;

    // Manual Override — CU signals gated by ~PROG_MODE to prevent
    // interference during programming (cu_lm = T0 = 1 when step_counter is frozen)
    wire active_lm    = (cu_lm    & ~PROG_MODE) | MANUAL_LM;
    wire active_l_mbr = (cu_l_mbr & ~PROG_MODE) | MANUAL_L_MBR;
    wire active_ri    = (cu_ri    & ~PROG_MODE) | MANUAL_RI;

    // COMPONENTS

    program_counter pc (
        .CLK(MAIN_CLK),
        .PC_INC(cu_pc_inc),
        .RESET(MAIN_RESET),
        .PC_OUT(pc_out),
        .Bus_Out(main_bus)
    );

    wire [7:0] ir_monitor;
    register_unit_8b ir (
        .Data_In(main_bus),
        .CLK(MAIN_CLK & cu_li),
        .RESET(MAIN_RESET),
        .REG_OUT(1'b0),
        .Bus_Out(),
        .MONITOR(ir_monitor)
    );
    assign main_bus = ei ? {4'b0000, ir_monitor[3:0]} : 8'bzzzzzzzz; 

    wire [7:0] a_monitor;
    register_unit_8b reg_a (
        .Data_In(main_bus),
        .CLK(MAIN_CLK & cu_la),
        .RESET(MAIN_RESET),
        .REG_OUT(a_out), 
        .Bus_Out(main_bus),
        .MONITOR(a_monitor)
    );

    wire [7:0] b_monitor;
    register_unit_8b reg_b (
        .Data_In(main_bus),
        .CLK(MAIN_CLK & cu_lb),
        .RESET(MAIN_RESET),
        .REG_OUT(MANUAL_B_OUT),
        .Bus_Out(main_bus),
        .MONITOR(b_monitor)
    );

    wire [7:0] alu_res;
    alu_8b_add_sub alu (
        .A(a_monitor),
        .B(b_monitor),
        .Subtraction(MANUAL_Sub),
        .res(alu_res),
        .Overflow()
    );
    assign main_bus = alu_out ? alu_res : 8'bzzzzzzzz; 

    wire [7:0] mar_monitor;
    register_unit_8b mar (
        .Data_In(main_bus),
        .CLK(MAIN_CLK & active_lm),
        .RESET(MAIN_RESET),
        .REG_OUT(1'b0),
        .Bus_Out(),
        .MONITOR(mar_monitor)
    );

    wire [7:0] mbr_monitor;
    register_unit_8b mbr (
        .Data_In(main_bus),
        .CLK(MAIN_CLK & active_l_mbr),
        .RESET(MAIN_RESET),
        .REG_OUT(1'b0),
        .Bus_Out(),
        .MONITOR(mbr_monitor)
    );

    ram_16byte ram (
        .ADRES(mar_monitor),
        .RI(active_ri),
        .RO(ro), 
        .CLK(MAIN_CLK),
        .RESET(MAIN_RESET),
        .DATA_IN(mbr_monitor),
        .DATA_OUT(main_bus)
    );

    wire [7:0] out_reg_monitor;
    register_unit_8b out_reg (
        .Data_In(main_bus),
        .CLK(MAIN_CLK & cu_lo),
        .RESET(MAIN_RESET),
        .REG_OUT(1'b0),
        .Bus_Out(),
        .MONITOR(out_reg_monitor)
    );
    assign OUT_PORT = out_reg_monitor;

    // MANUAL DATA INPUT
    assign main_bus = MANUEL_DATA_OE ? MANUEL_DATA : 8'bzzzzzzzz;

endmodule