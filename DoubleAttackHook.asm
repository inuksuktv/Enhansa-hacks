hirom

; This patch depends with my FistUpgradeStopper.asm hack. No particular reason, I just wrote them around the same time.

org $c1c021     ; Location at the end of Prepare Attack routine.
jsr $facd       ; Jump to free space from Fist Upgrade Stopper hack.
nop #5

org $c1facd     ; Free space liberated by the Fist Upgrade Stopper hack.
DoubleAttack:
phx
ldx $b1f4       ; Load attacker's battle stat block local offset.
lda $5e49,X     ; Load attacker's upgrade memory byte.
bit #$08        ; Test "2x attack" upgrade bit.
beq .Cleanup    ; Return if not set.
lda $5e7c,X     ; Load attacker's temp memory byte (unused, default FF).
bit #$01
beq .Cleanup    ; Return if not set.
and #$fe        ; Else clear bit 01.
sta $5e7c,X     ; Store memory.
jsr $bfaa       ; Prepare a second attack.
.Cleanup
lda $5e7c,X     ; Load 2x attack memory.
ora #$01        ; Set bit 01.
sta $5e7c,x     ; Store 2x attack memory.
plx
lda $b1fc       ; This section of cleanup was overwritten by the JSR to get here.
and #$fd
sta $b1fc
rts