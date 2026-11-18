; Count down from 5, showing 5, 4, 3, 2, 1 on the output, then halt.
;
; The loop does not know in advance how many times it will run: after each
; SUB it checks the Z flag and leaves once A reaches zero.

LDA 7      ; A <- 5
OUT        ; address 1: loop start, show A
SUB 8      ; A <- A - 1, updates Z
JZ  5      ; leave the loop when A = 0
JMP 1      ; otherwise repeat
HLT        ; address 5

DB 0       ; address 6: unused
DB 5       ; address 7: start value
DB 1       ; address 8: step
