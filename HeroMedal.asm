hirom
org $fdb3eb
lda $5e72,X ; Load PC's crit rate.
adc #$19    ; Add #25 to crit rate.
sta $5e72,X ; Store it.
rtl
nop #10     ; Write over the rest of the old Hero Medal routine.