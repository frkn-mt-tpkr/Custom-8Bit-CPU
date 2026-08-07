; Compute 50 - 20 and output the result (expected: 30 = 0x1E)

LDA 4      ; A <- RAM[4]       (load first number)
SUB 5      ; A <- A - RAM[5]   (subtract second number)
OUT        ; OUT_PORT <- A
HLT        ; stop

DB 50      ; address 4: first number  (50)
DB 20      ; address 5: second number (20)
