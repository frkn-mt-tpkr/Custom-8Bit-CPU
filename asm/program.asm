; Compute 13 + 7 and output the result (expected: 20 = 0x14)

LDA 4      ; A <- RAM[4]       (load first number)
ADD 5      ; A <- A + RAM[5]   (add second number)
OUT        ; OUT_PORT <- A
HLT        ; stop

DB 13      ; address 4: first number  (13)
DB 7       ; address 5: second number (7)
