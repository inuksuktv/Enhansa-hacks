hirom

org $c1de9e ; Start of "Check attacker status" for hit/miss routines.
nop #81     ; Write over the routine.

org $c1def0 ; Start of "Check defender status" for hit/miss routines.
nop #277    ; Write over the routine.

org $c1de9e ; Write a fresh "Check attacker status" routine that only checks Blind.
CheckAttacker:
ldx $b1f4   ; Load attacker's stat block offset.
lda $5e4b,X ; Load attacker's status.
bit #$01    ; Test Blind.
beq .Return ; If not set, return.
tdc
lda #$01    ; Else load one.
sta $16     ; Store Hit.
.Return
rts

org $c1def0 ; Write a fresh "Check defender status" routine that omits the Slow check and the Level comparison.
CheckDefender:
ldx $b1f6   ; Load defender's stat block offset.
lda $5e4d,X ; Load constant status 2.
ora $5e52,X ; OR with permanent constant status 2.
bit #$40    ; Test Evade 2.5x
beq .Evade2x; If not set, test Evade 2x.
tdc
lda $18     ; Else load Evade.
asl         ; Evade*2.
sta $28     ; Store Evade*2.
lsr #2      ; (Evade*2)/4.
clc
adc $28     ; Add Evade*2 + Evade/2.
sta $18     ; Store Evade*2.5
bra .StopSleep
.Evade2x
bit #$01    ; Test Evade 2x.
beq .StopSleep  ; If not set, test Stop and Sleep.
tdc
lda $18     ; Else load Evade.
asl         ; Evade*2.
sta $18     ; Store Evade*2.
.StopSleep
lda $5e4b,X ; Load defender's status.
sta $0e     ; Store status to $0E.
bit #$82    ; Test Stop or Sleep.
beq .Blind  ; If not set, branch to test Blind.
tdc
lda #$01    ; Else load one.
sta #$18    ; Store Evade.
.Blind
lda $0e     ; Load status.
bit #$01    ; Test Blind.
beq .Return ; If not set, return.
lda $18     ; Else load Evade.
lsr         ; Evade / 2.
inc         ; Add one.
sta $18     ; Store Evade/2 + 1.
.Return
rts
