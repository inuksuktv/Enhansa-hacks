hirom

org $3db516 ; Sets HP Down timer at the start of battle
jsr $6693   ; Jump to set timer based on battle speed
nop #5

org $fd6693 ; Free space
php         ; Calculate interval based on battle speed
phy
rep #$30
txa
xba
lsr
tay		    ; Calculate stat block offset based on loop counter in parent routine
tdc
sep #$20
lda $2990	; Load Battle Speed
and #$07    ; Keep the low three bits
clc
adc #$02    ; Add battle speed + two
sta $b12c,X ; Store HP Down timer reference
sta $af7f,X ; Store HP Down timer
ply
plp
rts
