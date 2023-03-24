hirom

org $c1c021     ; Location at the end of Prepare Attack routine.
jsr $facd       ; Jump to free space from Fist Upgrade Stopper hack.

org $c1facd     ; Free space liberated by the Fist Upgrade Stopper hack.
DoubleAttack:
lda $b18b       ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load attacker's index.
cmp #$00        ; Compare to zero.
bne .Cleanup    ; Branch if not Crono.
lda $5e7c       ; Load double attack memory.
cmp #$01        ; Compare to one.
beq .Cleanup    ; Branch if one.
lda #$01        ; Else load one.
sta $5e7c       ; Store double attack memory.
jsr $bfaa       ; Jump to prepare another attack.
.Cleanup
lda #$ff        ; Load FF.
sta $5e7c       ; Store to double attack memory.
lda $b1fc       ; Command replaced by the JSR to get here.
rts