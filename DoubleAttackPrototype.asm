hirom

org $c1c021     ; Location at the end of Prepare Attack routine.
jsr $fadd       ; Jump to free space from Fist Upgrade Stopper hack.

org $c1fadd     ; Free space liberated by the Fist Upgrade Stopper hack.
DoubleAttack:
lda $b18b       ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load attacker's index.
cmp #$00        ; Compare to zero.
bne .Cleanup    ; Branch if not Crono.
lda $5e7c       ; Load temporary memory.
cmp #$00        ; Compare to zero.
bne .Cleanup    ; Branch if set.
inc $5e7c       ; Increment double attack memory.
jsr $bfaa       ; Jump to prepare another attack.
.Cleanup
stz $5e7c       ; Clear double attack memory.
lda $b1fc       ; Command replaced by the JSR to get here.
rts