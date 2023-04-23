hirom

; This routine drains 50% of the caster's max HP including a check for Charm Top to drain 100%.
; Edit the damage formula on the desired Tech using Temporal Flux/Hi-Tech to use formula 04.

org $01d3bf ; The old Stealing routine. Tech mode 06 for old Charm.
nop #53     ; NOP it out.

org $01d9df ; Pointer for Tech mode 04.
db $c0, $d3 ; Pointer to new Drain routine.

org $01d3bf
rts         ; Failsafe return for anything calling the old Stealing routine.
DrainMode:
jsr $e9a3   ; Get attacker's stat block offset.
jsr $e9b8   ; Get defender's stat block offset.
lda #$03    ; Load three.
sta $1a     ; Store HP stat offset.
rep #$20    ; Set A 16-bit.
clc
adc $b1f4   ; Add to attacker's stat block offset.
tax
lda $5e2f,X ; Load attacker's max HP.
sta $00     ; Scratch memory.
sep #$20    ; Set A 8-bit.
lda $5e54,X ; Load attacker's accessory.
cmp #$a5    ; Compare to Charm Top.
beq .Execute
rep #$20    ; Set A 16-bit.
lda $00     ; Load attacker's maxHP.
lsr         ; /2
sta $00     ; Store damage
.Execute
jsr $e7cb   ; Jump into the Drain execution routine after the damage calculation.
jsr $d508   ; Load attack data.
tdc
sta $b200
rts
