; Branch on carry: 200 + 100 overflows 8 bits (expected output: 44 = 0x2C)
;
; If JC did not take the jump, the HLT at address 3 would stop the CPU before
; OUT ran and the output would stay 0x00.

LDA 6      ; A <- 200
ADD 7      ; A <- 200 + 100 = 300, wraps to 44 and sets C
JC  4      ; taken because C = 1
HLT        ; skipped
OUT        ; address 4
HLT        ; address 5

DB 200     ; address 6
DB 100     ; address 7
