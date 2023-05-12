exhirom

org $c2929d ; Hook for HP calculation.
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
