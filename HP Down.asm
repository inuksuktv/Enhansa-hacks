hirom

org $3db516 ; Sets HP Down timer at the start of battle
jsr $6710   ; Jump to set timer based on battle speed
nop #5

org $fd6710 ; Free space
lda $2990	; Load Battle Speed
and #$07    ; Keep the low three bits
clc
adc #$02    ; Add battle speed + two
sta $b12c,X ; Store HP Down timer reference
sta $af7f,X ; Store HP Down timer
rts
