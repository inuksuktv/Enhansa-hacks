hirom
org $01b4c1     ; Location in Confuse/Berserk script testing.
StatusScript:
lda $5e4b,X     ; Load status.
eor $5e50,X     ; Check immunity.
and $5e4b,X     ; AND status.
bit #$08        ; Test Lock.
bne .BersScript ; If set, branch to load Berserk script offset.
bit #$04        ; Test Confuse.
bne .ConfScript ; If set, branch to load Confuse script offset.
lda $5e4e,X     ; Load constant status 3.
ora $5e53,X     ; OR with permanent constant status 3.
bit #$80        ; Test Berserk.
beq .Return     ; Return if not set.
.BersScript
ldx #$8d08      ; Load Berserk script offset.
bra .Store
.ConfScript
ldx #$8d1e      ; Load Confuse script offset.
.Store
stx $b1d2
.Return
rts             ; 1 extra byte.

org $c1b0b6     ; Status bitflags routine.
nop #365        ; Erase the old one.
org $c1b0b6     ; Write the new one.
Bitflags:
lda $5e4a,X
bit #$80        ; Test actor is dead.
beq .SleepTest  ; Continue if not set.
jmp .Return     ; Else jump to return.
.SleepTest
lda $5e4b,X     ; Load status.
bit #$02        ; Test Sleep.
beq .Protect
tdc
sta $b03a,Y     ; Disable ATB.
cpy #$0003
bcc .Protect    ; Branch if actor is PC
sta $5e0a,Y     ; Else clear wander byte for enemy.
.Protect
lda $b024,Y
and #$fe        ; Clear Protect bitflag $01.
sta $b024,Y
lda $5e4e,X     ; Load constant status 3.
ora $5e53,X     ; OR with permanent constant status 3.
bit #$04        ; Test Protect.
beq .Poison
lda $b024,Y
ora #$01        ; Set Protect bitflag $01.
sta $b024,Y
.Poison
lda $afc1,Y
and #$fe        ; Clear Poison bitflag $01.
sta $afc1,Y
lda $5e4b,X     ; Load status.
bit #$40        ; Test Poison.
beq .HPDown
lda $afc1,Y
ora #$01        ; Set Poison bitflag $01.
sta $afc1,Y
.HPDown
lda $b00e,Y
and #$fe        ; Clear HP Down bitflag $01.
sta $b00e,Y
lda $5e4b,X     ; Load status.
bit #$10        ; Test HP Down.
beq .MPRegen
lda $b00e,Y
ora #$01        ; Set HP Down bitflag $01.
sta $b00e,Y
.MPRegen
lda $b019,Y
and #$fe        ; Clear MP Regen bitflag $01.
sta $b019,Y
lda $5e4e,X     ; Load constant status 3.
ora $5e53,X     ; OR with permanent constant status 3.
bit #$20        ; Test MP Regen.
beq .2xEvade
lda $b019,Y
ora #$01        ; Set MP Regen bitflag $01.
sta $b019,Y
.2xEvade
lda $b02f,Y
and #$fe        ; Clear 2x Evade bitflag $01.
sta $b02f,Y
lda $5e4d,X     ; Load constant status 2.
ora $5e52,X     ; OR with permanent constant status 2.
bit #$02        ; Test 2x Evade.
beq .Slow
lda $b02f,Y
ora #$01        ; Set 2x Evade bitflag $01.
sta $b02f,Y
.Slow
lda $afcc,Y
and #$fe        ; Clear Slow bitflag $01.
sta $afcc,Y
lda $5e4b,X     ; Load status.
bit #$20        ; Test Slow
beq .Barrier
lda $afcc,Y
ora #$01        ; Set Slow bitflag $01.
sta $afcc,Y
.Barrier
lda $afed,Y
and #$fe        ; Clear Barrier bitflag $01.
sta $afed,Y
lda $5e4e,X     ; Load constant status 3.
ora $5e53,X     ; OR with permanent constant status 3.
bit #$40        ; Test Barrier.
beq .Haste
lda $afed,Y
ora #$01        ; Set Barrier bitflag $01.
sta $afed,Y
.Haste
lda $afd7,Y
and #$fe        ; Clear Haste bitflag $01.
sta $afd7,Y
lda $5e4d,X     ; Load constant status 2.
ora $5e52,X     ; OR with permanent constant status 2.
bit #$80        ; Test Haste.
beq .25xEvade
lda $afd7,Y
ora #$01        ; Set Haste bitflag $01.
sta $afd7,Y
.25xEvade
lda $afe2,Y
and #$fe        ; Clear 2.5x Evade bitflag $01.
sta $afe2,Y
lda $5e4d,X     ; Load constant status 2.
ora $5e52,X     ; OR with permanent constant status 2.
bit #$40        ; Test 2.5x Evade.
beq .StopTest
lda $afe2,Y
ora #$01        ; Set 2.5x Evade bitflag $01.
sta $afe2,Y
.StopTest
lda $afb6,Y
and #$fe        ; Clear Stop bitflag $01.
sta $afb6,Y
lda $5e4b,X     ; Load status.
bit #$80        ; Test Stop.
beq .Lock
lda $afb6,Y
ora #$01        ; Set Stop bitflag $01.
sta $afb6,Y
lda #$04
sta $5e0a,Y     ; Set wander byte to $04.
.Lock
cpy #$0003      ; Compare battle ID to 3
bcc .LockPC     ; Branch if actor is a PC
lda $5e4b,X     ; Load status.
bit #$08        ; Test Lock.
beq .Confuse
cmp $ae7a,Y     ; Compare status to secondary status byte.
beq .Confuse    ; If equal, branch to test Confuse.
bra .Store      ; Else branch to store secondary status byte.
.LockPC
tdc
sta $a0d1,Y     ; Clear Lock bitflag $01 for PCs.
lda $5e4b,X     ; Load status.
bit #$08        ; Test Lock.
beq .Confuse    ; Branch if not set.
lda #$01
sta $a0d1,Y     ; Else set Lock bitflag $01 for PCs.
.Confuse
lda $5e4b,X     ; Load status.
bit #$04        ; Test Confuse.
beq .2ndTest    ; If not set, branch to secondary status test.
cmp $ae7a,Y     ; Compare to secondary status byte.
beq .Return     ; Return if equal.
bra .Store      ; Else branch to store secondary status byte.
.2ndTest
eor $ae7a,Y     ; EOR status with secondary status byte.
bit #$08        ; Test Lock.
bne .Clear      ; Branch if status was just cleared.
bit #$04        ; Test Confuse.
bne .Clear      ; Branch if status was just cleared.
bra .Return
.Clear
tdc
.Store
sta $ae7a,Y     ; Clear secondary status byte.
cpy #$0003      ; Compare battle ID to three.
bcc .Return     ; If PC, branch to return.
lda #$ff
sta $b268,Y     ; Else store FF to skip enemy's next action.
.Return
rts


