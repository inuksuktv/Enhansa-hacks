hirom

org $0188fa     ; Poison effect routine fragment.
lda #$0a        ; Load ten.
sta $2a         ; Store divisor.
lda $5e32,X     ; Load max HP.
sta $28         ; Store dividend.
lda $5e33,X
sta $29
jsr $c92a       ; Divide max HP / 10.
jsl $cffed8     ; Calculate Poison tick damage and set timer.
nop #21

org $01e03a     ; Apply Status routine fragment.
lda $b0df,X     ; Load Poison timer reference.
lsr             ; /2
sta $af32,X     ; Store Poison timer.
nop #3

org $cffed8     ; Free space to calculate damage and set timer.
Poison:
php
rep #$30        ; Set A,X,Y to 16-bit.
tya             ; Transfer battle ID.
xba
lsr
tax             ; Calculate stat block offset.
lda $5e32,X     ; Load max HP.
clc
cmp #$1194      ; If max HP < #4,500,
bcc .NormalHP   ; Then branch to normal damage tick.
lda $2c         ; Else load maxHP/10.
.NormalHP
lsr
lsr             ; /4
clc
cmp $5e30,X     ; If damage tick is less than current HP,
bcc .StoreDamage; Then branch to store damage
lda $5e30,X     ; Else load current HP.
dec             ; Subtract one.
.StoreDamage
sta $ad89       ; Store damage.
tdc
sep #$20        ; Set A 8-bit.
lda $5e4d,X     ; Load constant status 2.
bit #$80        ; Test Haste.
beq .Slow       ; If not set, branch to test Slow.
lda $b0df,Y     ; Load Poison timer reference.
lsr             ; Halve it.
bra .Store      ; Branch to store timer.
.Slow
lda $5e4b,X     ; Load status.
bit #$20        ; Test Slow.
beq .LoadDefault; If not set, branch to load default timer.
lda $b0df,Y     ; Load Poison timer reference.
asl             ; Double it.
bra .Store      ; Branch to store timer.
.LoadDefault
lda $b0df,Y     ; Load Poison timer reference.
.Store
sta $af32,Y     ; Store Poison timer.
tya
sta $b1fd       ; Store battle ID to prepare for next code section.
plp
rtl

org $3db4f6     ; Sets Poison timer at the start of battle.
jsr $66b8       ; Jump to calculate timer reference based on Battle Speed.
nop #5

org $fd66b8     ; Free Space.
php             ; Push flags.
phy             ; Push Y.
phx             ; Push X.
rep #$30        ; Set A,X,Y 16-bit.
txa             ; X holds loop counter used as battle ID.
xba
lsr
tay             ; Calculate stat block offset based on battle ID.
tdc
sep #$20        ; Set A 8-bit.
lda $5e64,Y     ; Load Stamina.
lsr #2
sta $28         ; Store Stamina / 4.
lsr #2
sta $29         ; Store Stamina / 16.
lda $28
sec
sbc $29         ; Subtract Stamina/4 - Stamina/16.
sta $28         ; Store 3*Stamina/16.
lda $29
lsr #2
sta $29         ; Store Stamina / 64.
lda $28
sec
sbc $29         ; Subtract 3*Stamina/16 - Stamina/64.
adc #$28        ; Add Stamina/5.82 + 41. (Carry is set.)
sta $00         ; Store the base interval.
stz $29
lsr
sta $28         ; Store base Interval / 2
stz $2b
lda $2990       ; Load battle speed
and #$07        ; Keep the low three bites
sta $2a         ; Store battle speed
jsl $c1fdbf     ; Multiply Interval/2 * BattleSpeed ***new JSL at start of battle***
lda $2c         ; Load Battle Speed interval modifer
clc
adc $00         ; Add interval modifier + base interval
plx             ; Pull X, battle ID
sta $b0df,X     ; Store Poison timer reference
sta $af32,X     ; Store Poison timer
ply             ; Pull Y
plp             ; Pull flags
rts
