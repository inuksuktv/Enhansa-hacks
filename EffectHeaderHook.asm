exhirom

org $c1d6fa     ; Location of setup for Attack Effect routine.
jsl $5f0110     ; Jump to free space in an expanded ROM bank.
nop #6          ; The setup is ten bytes total. Setup moved to the cleanup section of the child routine. The routine call is at $c1d704 JSR.W ($d9d7,X).

org $5f0110
EffectHeaderHook:
php             ; Push flags.
lda $b18b       ; Load attacker's battle ID.
sta $00         ; Store it.
.Crono
tax
lda $aeff,X     ; Load PC ID.
sta $02
cmp #$00        ; Compare to zero.
bne .Marle      ; Branch if not Crono.
.Cyclone
lda $b2c8       ; Load effect header.
cmp #$01        ; Compare to one.
bne .RainbowCap ; Branch if Tech is not Cyclone.
lda $261c       ; Load Crono's upgrade memory byte.
bit #$01        ; Test bit $01.
beq .Marle      ; Branch if bit $01 not set.
lda $aeef       ; Load Tech Power (isCrono, isCyclone, isUpgraded all passed).
lsr #2          ; /4
clc
adc $aeef       ; Add TP + TP/4.
sta $aeef       ; Store 1.25*TP
bra .Marle
.RainbowCap
lda $2627       ; Load Crono's equipped helm.
cmp #$80        ; Compare to Rainbow Helm.
bne .Marle      ; Branch if not equal.
lda $b2c8       ; Load effect header.
cmp #$03        ; Compare to Lightning.
beq .LightningUp
cmp #$05        ; Compare to Lightning 2.
beq .LightningUp
cmp #$08        ; Compare to Luminaire.
beq .LightningUp
bra .Marle      ; Branch if Tech is not lightning element.
.LightningUp
lda $aeef       ; Load Tech Power (isRainbowCap, isLightning both passed).
lsr             ; /2
clc
adc $aeef       ; Add TP + TP/2.
sta $aeef       ; Store 1.5*TP.
.Marle
lda $00         ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
cmp #$01        ; Compare to one.
bne .Lucca      ; Branch if not Marle.
.Aura
lda $b2c8       ; Load effect header.
cmp #$09        ; Compare to nine.
bne .MermaidCap ; Branch if Tech is not Aura.
lda $266c       ; Load Marle's upgrade memory byte.
bit #$10
beq .Lucca      ; Branch if bit 10 not set.
lda #$02        ; Load two. (isMarle, isAura, isUpgraded all passed.)
sta $aee9       ; Set status mode to 02.
lda #$40
sta $aeea       ; Set status bitflag to $40 (Regen).
.MermaidCap
lda $2677       ; Load Marle's equipped helmet.
cmp #$83        ; Compare to MermaidCap.
bne .Lucca
lda $b2c8       ; Load effect header.
cmp #$0b        ; Compare to Ice.
beq .IceUp
cmp #$0e        ; Compare to Ice 2.
beq .IceUp
bra .Lucca      ; Branch if Tech is not Water element.
.IceUp
lda $aeef       ; Load Tech Power (isMermaidCap, isWater both passed).
lsr             ; /2
clc
adc $aeef       ; Add TP + TP/2.
sta $aeef       ; Store 1.5*TP.
.Lucca
lda $00         ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
cmp #$02        ; Compare to two.
bne .Robo       ; Branch if not Lucca.
.HypnoWave
lda $b2c8       ; Load effect header.
cmp #$12        ; Compare to $12
bne .Robo       ; Branch if Tech is not Hypno Wave
lda $26bc       ; Load Lucca's upgrade memory byte.
bit #$01
beq .Robo       ; Branch if bit 01 not set.
lda $aeed       ; (isLucca, isHypnoWave, isUpgraded all passed.)
ora #$20
sta $aeed       ; Set always hit flag.
bra .Robo
.Robo
lda $00         ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
cmp #$03        ; Compare to three.
bne .Frog       ; Branch if not Robo.
.LaserSpin
lda $b2c8       ; Load effect header.
cmp #$1b
bne .CureBeam   ; Branch if Tech is not Laser Spin.
lda $270c       ; Load Robo's upgrade memory byte.
bit #$01        ; Test bit $01.
beq .Frog
lda $aeef       ; Load Tech Power (isRobo, isLaserSpin, isUpgraded all passed).
lsr #2          ; /4
clc
adc $aeef       ; Add TP + TP/4.
sta $aeef       ; Store 1.25*TP
bra .Frog
.CureBeam
lda $b2c8       ; Load effect header.
cmp #$1a
bne .Frog       ; Branch if Tech is not Cure Beam.
lda $270c       ; Load Robo's upgrade memory byte.
bit #$10        ; Test bit $10
beq .Frog
lda #$01        ; (isRobo, isCureBeam, isUpgraded all passed.)
sta $aee6       ; Set Tech Mode 01 Status Recovery
lda $aee7       ; Load healing power.
ora #$40        ; Set bit $40
sta $aee7       ; Store it.
bra .Frog
.Frog
lda $00         ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
cmp #$04        ; Compare to four.
bne .Ayla       ; Branch if not Frog
.SlurpCut
lda $b2c8       ; Load Tech header
cmp #$22
beq .SlurpCutUp ; Continue if Tech is Slurp Cut.
cmp #$40
beq .SlurpCutUp ; Continue if Combo Tech uses Slurp Cut.
bra .Water
.SlurpCutUp
lda $275c       ; Load Frog's upgrade memory byte.
bit #$01
beq .Ayla
lda $aeef       ; Load Tech Power (isFrog, isSlurpCut, isUpgraded all passed).
lsr #2
clc
adc $aeef
sta $aeef
bra .Ayla
.Water
lda $b2c8       ; Load Tech header.
cmp #$23
beq .WaterUp    ; Continue if Tech is Water.
cmp #$26
beq .WaterUp    ; Continue if Tech is Water 2.
bra .Heal
.WaterUp
lda $275c       ; Load Frog's upgrade memory byte.
bit #$10
beq .Ayla
lda $aeef       ; Load Tech Power (isFrog, isWater, isUpgraded all passed).
lsr #2          ; /4
clc
adc $aeef       ; Add TP + TP/4.
sta $aeef       ; Store 1.25*TP
.Heal
lda $b2c8
cmp #$24
bne .Ayla       ; Branch if Tech is not Heal.
lda $275c       ; Load Frog's upgrade memory byte.
bit #$20
beq .Ayla
lda #$02        ; (isFrog, isHeal, isUpgraded all passed.)
sta $aee9       ; Set status mode to 02.
lda #$40
sta $aeea       ; Set status bitflag to $40 (Regen).
bra .Ayla
.Ayla
lda $00         ; Load attacker's battle ID.
tax
lda $aeff,X     ; Load PC ID.
cmp #$05        ; Compare to five.
bne .Magus      ; Branch if not Ayla.
.Kiss
lda $b2c8       ; Load effect header.
cmp #$29
bne .Magus      ; Branch if Tech is not Kiss.
lda $27ac       ; Load Ayla's upgrade memory byte.
bit #$10
beq .Magus
lda #$04        ; (isAyla, isKiss, isUpgraded all passed.)
sta $aee9       ; Set status mode to 04.
lda #$20
sta $aeea       ; Set status bitflag to $20 (MP Regen).
.Magus
lda $00         ; Load attacker's battle ID
tax
lda $aeff,X     ; Load PC ID.
cmp #$06        ; Compare to six.
bne .Cleanup    ; Branch if not Magus.
.DarkBomb
lda $b2c8       ; Load effect header.
cmp #$34
bne .Cleanup    ; Branch if Tech is not Dark Bomb.
lda $27fc       ; Load Magus's upgrade memory byte.
bit #$10
beq .Cleanup
lda $aeef       ; Load Tech Power (isMagus, isDarkBomb, isUpgraded all passed).
lsr #2          ; /4
clc
adc $aeef       ; Add TP + TP/4.
sta $aeef       ; Store 1.25*TP
.Cleanup
plp             ; Pull flags.
lda $aee6       ; Load Tech mode.
rep #$20        ; Set A 16-bit.
asl a           ; Mode*2.
tax             ; Use as index.
tdc
sep #$20        ; Set A 8-bit.
rtl             ; Return to indirect indexed JSR to resolve Tech effect.