exhirom

org $c2929d     ; Hook for HP calculation.
jsl $5f0470
nop #9

org $5f0470     ; Free space in expanded ROM.
Main:
cpx #$a1        ; Compare to Gold Earring.
beq .OneHalf
cpx #$a0        ; Compare to Silver Earring.
beq .OneQuarter
cpx #$b4        ; Compare to Muscle Belt.
beq .OneQuarter
tdc
.OneQuarter
lsr
.OneHalf
lsr
rtl

org $c28d26     ; Hook for HP restore points
jsl $5f0510
nop #11

org $5f0510     ; Free space in expanded ROM.
SecondMain:
cpx #$00a1      ; Compare to Gold Earring.
beq .Half
cpx #$00a0      ; Compare to Silver Earring.
beq .Quarter
cpx #$00b4      ; Compare to Muscle Belt.
beq .Quarter
lda #$0000      ; Else load zero.
.Quarter
lsr
.Half
lsr
rtl
