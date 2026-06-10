`timescale 1ns / 1ps

module control_unit_sap1_custom (
    input  wire       CLK,
    input  wire       RESET,
    input  wire [3:0] OPCODE,
    
    output wire PC_OUT,
    output wire PC_INC,
    output wire LI,
    output wire LM,
    output wire EI,
    output wire L_MBR,
    output wire RI,
    output wire RO,
    output wire LA,
    output wire LB,
    output wire ALU_OUT,
    output wire LO,
    output wire A_OUT
);

    // Ring Counter T0 - T7
    reg [2:0] step_counter;
    reg halted;

    always @(negedge CLK or posedge RESET) begin
        if (RESET) begin
            step_counter <= 3'b000;
            halted <= 1'b0;
        end else if (!halted) begin
            if (T3 & HLT_ins)
                halted <= 1'b1;
            else
                step_counter <= step_counter + 1;
        end
    end

    wire T0 = ~step_counter[2] & ~step_counter[1] & ~step_counter[0];
    wire T1 = ~step_counter[2] & ~step_counter[1] &  step_counter[0];
    wire T2 = ~step_counter[2] &  step_counter[1] & ~step_counter[0];
    wire T3 = ~step_counter[2] &  step_counter[1] &  step_counter[0];
    wire T4 =  step_counter[2] & ~step_counter[1] & ~step_counter[0];
    wire T5 =  step_counter[2] & ~step_counter[1] &  step_counter[0];

  
    wire ADD_ins = (OPCODE == 4'b0001); 
    wire LDA_ins = (OPCODE == 4'b0010); 
    wire OUT_ins = (OPCODE == 4'b1110); 
    wire HLT_ins = (OPCODE == 4'b1111); 
    
    // Control Logic
    
    assign PC_OUT  = T0;
    assign PC_INC  = T1;
    assign LI      = T2;
    
  
    assign EI      = T3 & (ADD_ins | LDA_ins);
    
    // L_MBR and RI are only needed during programming mode (MANUAL signals).
    // The control unit should NEVER assert them during normal execution.
    assign L_MBR   = 1'b0;
    assign RI      = 1'b0;

   
    assign LM      = T0 | (T3 & (ADD_ins | LDA_ins));
    
    // T3: OUT instruction
    assign LO      = T3 & OUT_ins;
    assign A_OUT   = LO;

    // T4: ADD instruction
    assign LB      = T4 & ADD_ins;
    
    // LA
    assign LA      = (T4 & LDA_ins) | (T5 & ADD_ins);

    // RO: Active in T2 or T4 (ADD/LDA)
    assign RO      = T2 | (T4 & (ADD_ins | LDA_ins));
    
    // T5: ADD instruction
    assign ALU_OUT = T5 & ADD_ins;

endmodule