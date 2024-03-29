exhirom

org $c1bc4a     ; Location in the Tech command stream after animation and some Charm processing.
jsl $5f0050
bit #$80        ; Test bit $80 of temp memory byte.
bne $04         ; Continue if set.
jsr $bb93       ; Else call another Tech.
nop

org $5f0050     ; Free space in expanded rom
TechRepeater:   ; As we arrive, A holds control header. X holds PC ID.
php
phx
phy
lda $aecc       ; The hook at $c1bc4a wrote over this and the next four lines.
cmp #$03        ; Compare to three.
bcc $05         ; Branch if target is PC.
lda #$01
sta $b2c0       ; Set counterattack flag for enemy.
.isSingleTech
lda $b2eb       ; Load second actor ID.
cmp #$ff
beq .FirstAttack ; Continue if Single Tech.
jmp .Cleanup    ; Return if Combo Tech.
.FirstAttack
ldx $b1f4       ; Load attacker's stat block offset.
lda $5e7c,X     ; Load attacker's temporary memory byte (unused, default FF).
bit #$80
bne .isUpgraded
jmp .Cleanup    ; Return if bit $80 not set.
.isUpgraded
lda $5e49,X     ; Load attacker's upgrade byte.
bit #$80
beq .NoUpgrade  ; Return if bit $80 not set.
.WithUpgrade
lda $5e57,X     ; Load attacker's accessory.
cmp #$bb        ; Compare to Prism Specs.
beq .TestMagic  ; Branch to Branch to determine Tech if talented and Prism Specs equipped.
bra .RNG        ; Branch to RNG if talented and Prism Specs not equipped.
.NoUpgrade
lda $5e57,X     ; Load attacker's accessory.
cmp #$bb        ; Compare to Prism Specs
beq .RNG
jmp .Cleanup    ; Return if not equipped.
.RNG
tdc
tax
lda #$63        ; Return a value 0-99.
jsl $c1fdcb     ; RNG routine hook.
ldx $b1f4       ; Load attacker stat block offset.
cmp #$32        ; Compare RNG result to fifty.
bcc .TestMagic  ; Test isMagicTech if less than fifty.
jmp .Cleanup    ; Else return.
.TestMagic
lda $b2ea       ; Load actor's ID.
cmp #$00        ; Compare to Crono.
bne .Marle
lda $ae93       ; Load animation index.
cmp #$02        ; Compare to Slash.
beq .Success
cmp #$03        ; Compare to Lightning.
beq .Success
cmp #$05        ; Compare to Lightning 2.
beq .Success
cmp #$08        ; Compare to Luminaire.
beq .Success
bra .Cleanup
.Marle
cmp #$01        ; Compare to Marle.
bne .Lucca
lda $ae93       ; Load animation index.
cmp #$0c        ; Compare to Ice.
beq .Success
cmp #$0f        ; Compare to Ice 2.
beq .Success
bra .Cleanup
.Lucca
cmp #$02        ; Compare to Lucca.
bne .Robo
lda $ae93       ; Load animation index.
cmp #$13        ; Compare to Fire.
beq .Success
cmp #$16        ; Compare to Fire 2.
beq .Success
cmp #$18        ; Compare to Flare.
beq .Success
bra .Cleanup
.Robo
cmp #$03        ; Compare to Robo.
bne .Frog
lda $ae93       ; Load animation index.
cmp #$1c        ; Compare to Laser Spin.
beq .Success
cmp #$1f        ; Compare to Area Bomb.
beq .Success
cmp #$20        ; Compare to Shock.
beq .Success
bra .Cleanup
.Frog
cmp #$04        ; Compare to Frog.
bne .Ayla
lda $ae93       ; Load animation index.
cmp #$23        ; Compare to Water.
beq .Success
cmp #$26        ; Compare to Water 2.
beq .Success
bra .Cleanup
.Ayla
cmp #$05        ; Compare to Ayla.
bne .Magus
lda #$ae93      ; Load animation index.
cmp #$2f        ; Compare to Tail Spin.
beq .Success
bra .Cleanup
.Magus
lda $ae93       ; Load animation index.
cmp #$36        ; Compare to Barrier.
beq .Cleanup
cmp #$35        ; Compare to Vamp.
beq .Cleanup
cmp #$37        ; Compare to Black Hole.
beq .Cleanup
.Success
lda $5e7c,X     ; Load 2x Tech memory.
and #$7f        ; Clear bit $80.
sta $5e7c,X     ; Store memory.
bra .Return     ; Return without setting bit.
.Cleanup
lda $5e7c,X     ; Load 2x Tech temporary memory.
ora #$80        ; Set bit 80.
sta $5e7c,x     ; Store 2x Tech temporary memory.
.Return
ply
plx
plp
rtl

; --------------------------------------------------------------------------------

; The following section is to allow a repeated Tech to cast without sufficient MP.

; This routine checks the actor's current MP against the Tech's MP cost.
; I've added a check on the 2x Tech memory to bypass the MP test if the PC is currently casting a repeated Tech.
org $c1d769
CheckMP:
stx $32         ; Store battle ID.
tdc
lda $b2d0       ; Load loop counter.
asl
tax
lda $b18c       ; Load control header.
jsr ($da31,X)   ; Get MP cost.
tay             ; Transfer MP cost to Y.
ldx $32         ; Load battle ID.
lda $b3ba,X     ; Load accessory.
jsr $cbf6       ; Stud discount check.
lda $32         ; Load battle ID.
rep #$20        ; Set accumulator 16-bit.
txa
xba
lsr
tax
sep #$20        ; Set accumulator 8-bit.
lda $5e7c,X     ; Load 2x Tech temporary memory.
bit #$80
beq .ActorPassed
rep #$20
lda $5e34,X     ; Load current MP.
sta $ae5b
tdc
sep #$20
cpy $ae5b       ; Compare MP cost to current MP.
beq .ActorPassed
bcs .TechFailed
nop
lda $5e4b,X
bit #$08
bne .TechFailed
.ActorPassed
tdc
inc $b2d0
lda $b2d0
cmp #$03
bcc $9d
bra $07
.TechFailed
lda #$ff
sta $b3c8       ; Store FF for failed Tech.
bra $04
tdc
sta $b3c8       ; Store 00 for passed Tech.
rts

; This routine subtracts the MP cost from the PC's current MP during execution of the Tech.
; Now that we can arrive here with insufficient MP, this routine can return a negative number. I added a floor of zero to the subtraction.
org $c1cc71
nop #90
org $c1cc71
SubtractMP:
PHP	
PHX	
PHY	
CMP #$FF    ; Test actor ID.
BEQ .Return ; Return if actor is not present.
TAX	
LDA $B1BE,X	; Load battle ID.
TAX
LDA $B3BA,X	; Load accessory.
JSR $CBF6
TYA	
REP #$20
STA $0E		; Store MP cost.
TXA	
XBA	
LSR	
TAX	
LDA $5E34,X	; Load current MP.
SEC
SBC $0E		; Subtract current MP – MP cost.
BPL $03
LDA #$0000
STA $5E34,X	; Store new current MP.
.Return
PLY	
PLX	
PLP
RTS         ; 45 bytes of new free space here.
