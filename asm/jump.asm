; Jump over an instruction and output the result (expected: 5 = 0x05)
;
; If JMP did not work, execution would fall through to ADD 7, leaving
; A = 105, and the HLT at address 3 would stop the CPU before OUT ran.

LDA 6      ; A <- RAM[6]   (5)
JMP 4      ; continue at address 4
ADD 7      ; skipped; would add 100
HLT        ; skipped
OUT        ; address 4: OUT_PORT <- A
HLT        ; address 5: stop

DB 5       ; address 6: first number
DB 100     ; address 7: the value that must not be added
