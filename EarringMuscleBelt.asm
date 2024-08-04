exhirom

org $c2929d     ; Hook for menu HP bonus.
jsl $5f0470
nop #9

org $5f0470     ; Free space in expanded ROM.
First:
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

org $fdb3aa     ; Hook for battle HP bonus.
Second:
lda $5e57,x     ; Load accessory ID.
tay
rep #$20
lda $5e32,X     ; Load max HP.
cpy #$00a1      ; Compare to Gold Earring.
beq .AHalf
cpy #$00a0      ; Compare to Silver Earring.
beq .AQuarter
cpy #$00b4      ; Compare to Muscle Ring.
beq .AQuarter
lda #$0000
.AQuarter
lsr
.AHalf
lsr
clc
adc $5e32,X
cmp #$03e7
bcc $03
lda #$03e7      ; 999 ceiling
sta $5e32,X     ; Store max HP.
tdc
sep #$20
rtl
nop #17

org $c28d26     ; Hook for HP restore points
jsl $5f0510
nop #11

org $5f0510     ; Free space in expanded ROM.
Third:
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
