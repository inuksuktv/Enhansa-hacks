hirom

org $c1c021     ; Location at the end of Prepare Attack routine.
jsr $facd       ; Jump to free space from Fist Upgrade Stopper hack.

org $c1facd     ; Free space liberated by the Fist Upgrade Stopper hack.
DoubleAttack:
lda $b18b       ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load attacker's index.
cmp #$03        ; Compare to three.
bne .Cleanup    ; Branch if not Robo.
lda $5e6c       ; Load double attack memory.
cmp #$00        ; Compare to zero.
bne .Cleanup    ; Branch if nonzero.
inc $5e6c       ; Else increment double attack memory.
jsr $bfaa       ; Jump to prepare another attack.
.Cleanup
stz $5e6c       ; Clear double attack memory.
lda $b1fc       ; Command replaced by the JSR to get here.
rts