hirom

org $01de9e ; Start of "Check attacker status" for hit/miss routines.
nop #82     ; Write over the routine.

org $01def0 ; Start of "Check defender status" for hit/miss routines.
nop #278    ; Write over the routine.

org $01dc64 ; Start of "Determine hit/miss" routine.
nop #73     ; Write over the routine.

org $01de9e ; Write a fresh "Check attacker status" routine that only checks Blind.
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

org $01def0 ; Write a fresh "Check defender status" routine that omits the Slow check and the Level comparison.
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
sta $18     ; Store Evade.
.Blind
lda $0e     ; Load status.
bit #$01    ; Test Blind.
beq .Return ; If not set, return.
lda $18     ; Else load Evade.
lsr         ; Evade / 2.
inc         ; Add one.
sta $18     ; Store Evade/2 + 1.
.AttackerBlind
ldx $b1f4   ; Load attacker stat block offset.
lda $5e4b,X ; Load status.
bit #$01    ; Test blind.
beq .Return
lda $18     ; Load Evade.
cmp #$32    ; Compare to fifty.
bcs .Return ; Return if greater than.
lda #$32    ; Else load fifty.
sta $18     ; Store Evade0
.Return
rts

org $01dc64
DetermineHit:
lda $18     ; Load Evade.
cmp $16     ; Compare Evade to Hit.
bcc .Hit    ; Branch to record a hit if Evade < Hit.
sec
sbc $16     ; Else subtract Evade - Hit.
sta $16     ; Store Miss%.
tdc
tax
lda #$64
jsr $af22   ; Generate random value 0-99.
cmp $16     ; Compare random value to Miss%.
bcc .Miss   ; Branch if random value < Miss%.
.Hit
lda #$01    ; Load one.
sta $16     ; Set $16 to one to record a hit.
bra .Return ; Skip Miss.
.Miss
tdc
sta $16     ; Set $16 to zero to record a miss.
.Return
tdc
sta $ae4f   ; Set unknown location to zero.
rts
