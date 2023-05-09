exhirom

; Tech Handling Section

; This hack allows Tech mode 00 (Healing) to also apply status effects. The mode 00 and 02 (Status) routines are re-written from scratch to be able to
; work together. Modes 00 and 02 both pass control to a new routine that will resolve any context conflicts of the effect header bytes between
; modes. Mode 02 works the same as the base game. Mode 00 can read in four additional bytes to also apply a status.

; Tech Mode 00 bytes 00-07 meaning: Tech mode, Healing Power, HP/MP healing, status mode, status bitflags, base success, bonus success, bit $20 always hit.

;org $cc21ab     ; Uncomment this line and the following one if you'd like Aura to set Regen.
;db $00, $05, $80, $02, $40, $00, $00, $20

org $01e3cd     ; First we harvest some free space. Damage formulas 07, 08, 09, and 0A are unused.
jmp $e575       ; Jump past the unused section so that the damage formula routine doesn't break.
nop #421        ; Write over the unused section.

org $01d221     ; Write over the Tech mode 00 Healing routine.
nop #29         ; We use this space to jump to FlowController, for the new healing routine, and for the Regen effect.

org $01d267     ; Write over the Tech mode 02 Status Impact routine.
nop #119        ; We use this space to jump to FlowController and for the new status impact routine.

org $c1e3d0     ; Flow control for Tech modes 00 Healing, 02 Status Impact, and 07 Transfer HP/MP.
FlowController:
jsr $e9a3       ; Get attacker's stat block offset.
.StartOfLoop
jsr $e9b8       ; Get affected unit's stat block offset.
lda $aee6       ; Load Tech mode.
cmp #$02        ; If Tech mode == 02 Status Impact,
beq .StatusMode ; Then branch to status mode.
jsr $d224       ; Else run healing routine.
lda $aee6       ; Load Tech mode.
cmp #$07        ; If Tech mode == 07 Transfer HP/MP,
beq .CheckIndex ; Then branch to loop.
tdc
ora #$20
sta $aeed       ; Set to always hit.
lda $aee9       ; Load status mode.
sta $16         ; Store to $16.
lda $aeea       ; Load status bitflag.
sta $18         ; Store to $18.
bra .ApplyStatus; Branch to apply status.
.StatusMode
jsr $d1a4       ; Get Base and Bonus success chance.
ldx $16
stx $1a         ; Store Base success chance to $1a.
ldx $18
stx $1c         ; Store Bonus success byte to $1c.
jsr $d14f       ; Get status mode and status bitflag.
.ApplyStatus
jsr $d26a       ; Apply status.
.CheckIndex
jsr $d508       ; Load attack data.
dec $ad8d       ; Decrement affected unit counter.
lda $ad8d
bne .StartOfLoop; Loop if nonzero.
rts

org $01d221     ; Tech mode 00 Healing.
jmp $e3d0       ; Pass control to flow control routine.
Healing:        ; Start status routine.
jsr $d132       ; Load attacker's Magic and byte 2,3 of effect header.
jsr $da37       ; Apply healing.
lda #$00
sta $b200
rts             ; Some free bytes remain here, but we make use of them for the Regen effect.

org $01d267     ; Tech mode 02 Status Impact.
jmp $e3d0       ; Pass control to flow control routine.
StatusImpact:   ; Start Status routine.
lda $ae4d       ; Load special bitflags.
bit #$20        ; Test always hits.
bne .Effect     ; If set, branch to apply status.
tdc
ldx $b1f4
lda $5e66,X     ; Load attacker's Magic.
tax
stx $0028       ; Store Magic.
lda $1c         ; Load bonus success byte.
tax
stx $002a       ; Store bonus.
jsr $c92a       ; Divide Magic / bonus.
lda $2c         ; Load quotient.
clc
adc $1a         ; Add to base success chance.
sta $1a         ; Store success chance.
tdc
tax
lda #$64
jsr $af22       ; Generate random value 0-99.
cmp $1a         ; Compare random value to success chance.
beq .Effect
bcc .Effect     ; If value == or < success%, branch to apply status.
.Miss
jsr $d1b5       ; Else prepare miss.
jsr $e8e2       ; Load miss animation flags? to damage register.
lda #$80
sta $b200
bra .Return
.Effect
jsr $dbaa       ; Apply status.
lda #$00
sta $b200
lda $16         ; $16 is zero here if everything went as planned, this is just copied faithfully from the original status routine.
cmp #$80        ; Not sure why $16 would ever be #$80.
beq .Miss
.Return
rts             ; Free bytes remain, some of which are used for Regen/HP Down interactions.

; Regen Section

; This hack to implement HP Regen has several different sections. It makes use of some unused status ATB tracking. Regen is constant status 1 bit $40.
; First we correct a bug in the Apply Status routine where status mode 02 returns early. We also add some hooks for Regen to remove HP Down and vice versa.
; Second we point status effect 07 (RAM index) at our new routine. That pointer is used when the status's ATB hits zero. Third we write a compact routine
; using some of the free space liberated in the Tech handing section. Fourth we write the actual Regen effect in some free space in bank $C2. Fifth we
; edit the routine that sets status timer references at the start of battle to adjust the tick interval for Regen. This solution includes some logic
; to account for the player's Battle Speed setting.

org $01e078 ; Location in Apply Status routine.
beq $24     ; branch to test status mode 03 instead of jump to return.
nop         ; we wrote over a JMP so NOP the 3rd byte.

org $01e062 ; Location in the fragment that applies HP Down.
jsr $d2b5   ; Clear Regen status. Overwritten lda opcode moved to child routine.

org $01e091 ; Location in the fragment that sets Regen.
jsr $d2c7   ; Clear HP Down status. Overwritten lda opcode moved to child routine.

org $01b93b ; Location of pointer for new status effect 07 "Regen" (RAM index).
db $30, $d2 ; Little endian pointer to free space liberated in the Healing mode routine.

org $01d230 ; Location of free space from old Healing effect routine.
jsl $5f0300 ; Execute Regen effect.
jsr $ebf8	; Load damage registers.
jsr $ec7f	; Apply damage registers to HP/MP.
rts

org $c1d2b5 ; Location of free space from old Status Impact routine.
lda $5e4c,Y ; Load Constant status 1.
and #$bf    ; Clear Regen bit $40.
sta $5e4c,Y ; Store Constant status 1.
lda #$00    ; Load zero.
sta $b003,X ; Clear Regen bitflag.
lda $b12c,X ; Load HP Down timer reference to store it when we return from this routine.
rts

org $c1d2c7 ; Contiguous free space from the old Status Impact routine
lda $5e4b,Y ; Load status
and #$ef    ; Clear HP Down
sta $5e4b,Y ; Store status
lda #$00    ; Load zero
sta $b00e,X ; Clear HP Down bitflag
lda $b121,X ; Load Regen timer reference to store it when we return from this routine.
rts

org $5f0300 ; Vanilla free space.
Main:
tdc
lda $b180	; Regen is status effect 07 (RAM order) so load $B179+7.
bne $03		; If nonzero, branch to keep value loaded.
lda $aec7	; Else load unknown value.
dec		    ; Subtract 1.
tax		    ; Use as index to
lda $b163,X	; Load battle ID of affected unit.
tay		    ; Transfer battle ID to Y.
rep #$20    ; Full disclosure I don't really understand the last 5 lines, I just copied them from similar status routines. They find the unit's battle ID.
xba
lsr		    ; Convert battle ID to stat block offset.
tax		    ; Transfer stat block offset to X.
sta $10		; And store offset to $10 for some reason, just copied this from the original routine.
tdc
sep #$20
lda #$01	; Load one.
sta $b003,Y	; Set Regen active.
lda $b121,Y	; Load Regen timer reference.
sta $af74,Y	; Store Regen ATB timer.
rep #$20
lda $b186	; Load status effect controller.
and #$1fdf	; Clear Regen bit $20.
sta $b186	; Store it.
tdc
sep #$20
lda $5e4c,X	; Load status byte 1.
bit #$40	; Test Regen.
beq .exit	; If not set, exit.
ldx #$0001	; Load one.
stx $ad89	; Store damage.
tya		    ; Transfer battle ID.
sta $b1fd	; Store unit's battle ID.
lda #$80	; Load $80 for healing.
sta $b202	; Store healing bitflag.
.exit
rtl

org $3db50e ; Location where timer gets initialized.
jsl $5f0360 ; Calculate and store timer reference.
nop #4      ; Opcodes to store ATB moved to subroutine.

org $5f0360 ; Free space.
php         ; Push flags.
rep #$30    ; Set A,X,Y 16-bit.
tdc
sep #$20    ; Set A 8-bit.
lda $2990   ; Load battle speed.
and #$07    ; Keep the low three bits.
clc
adc #$02    ; Add 2 + battle speed.
sta $af72,X ; Store timer.
sta $b121,X ; Store timer reference.
plp         ; Pull flags.
rtl
