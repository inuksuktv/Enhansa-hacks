hirom

org $01e078 ; Location in status application routine
BEQ $24     ; branch to test status mode 3 instead of jump to return
NOP         ; we wrote over a JMP so NOP the 3rd byte

org $01b93b ; Location of pointer for new status effect 07 "Regen" (RAM index)
db $30, $d2 ; Little endian pointer to free space in the shrunken Healing effect routine

org $01d230 ; Location of free space in shrunken Healing effect routine
JSL $c27df0 ; Execute Regen effect
JSR $ebf8	; Load damage registers
JSR $ec7f	; Apply damage registers to HP/MP
RTS

org $c27df0 ; Free space
Main:
TDC
LDA $b180	; Regen is status effect 07 (RAM order) so load $B179+7
BNE $03		; If nonzero, branch to keep value loaded
LDA $aec7	; Else load unknown value
DEC		    ; Subtract 1
TAX		    ; Use as index to
LDA $b163,X	; Load battle ID of affected unit
TAY		    ; Transfer battle ID to Y
REP #$20    ; Full disclosure I don't really understand the last 7 lines, I just copied them from similar routines. They find the unit's battle ID.
XBA
LSR		    ; Convert battle ID to stat block offset
TAX		    ; Transfer stat block offset to X
STA $10		; And store it to $10
TDC
SEP #$20
LDA #$01	; Load 1
STA $b003,Y	; Set Regen active
LDA $b121,Y	; Load Regen timer reference
STA $af74,Y	; Store Regen ATB timer
REP #$20
LDA $b186	; Load status effect controller
AND #$1fdf	; Clear Regen bit $20
STA $b186	; Store it
TDC
SEP #$20
LDA $5e4c,X	; Load status byte 1
BIT #$40	; Test Regen
BEQ .exit	; If not set, exit
LDX #$0001	; Load 1
STX $ad89	; Store damage
TYA		    ; Transfer battle ID
STA $b1fd	; Store unit's battle ID
LDA #$80	; Load $80 for healing
STA $b202	; Store healing bitflag
.exit
RTL         ; #73 bytes in length

org $3db50e ; Location where timer reference gets stored
JSR $6700   ; Calculate and store timer reference
NOP #5      ; Opcodes to store ATB moved to child routine

org $fd6700 ; Free space
PHP         ; Push flags
PHY         ; Push Y
REP #$30    ; Set A,X,Y 16-bit
TXA         ; X holds loop counter used as battle ID
XBA
LSR
TAY         ; Calculate stat block offset based on battle ID
TDC
SEP #$20    ; Set A 8-bit
LDA #6      ; Quickie just load 6 but this will be replaced with a dynamic tick rate
STA $af72,X ; Store ATB
STA $b121,X ; Store ATB timer reference
PLY         ; Pull Y
PLP         ; Pull flags
RTS
