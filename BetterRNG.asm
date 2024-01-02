hirom

org $c1af22 ; Address of the RNG routine.
fillbyte $FF
fill 87     ; Write over it.

org $c1af79 ; Address of the alternate RNG routine.
fill 89

org $c1af22
BetterRNG:
sep #$10
stx.b $25   ; Store the inclusive lower bound of the range.
cpx #$FF    ; If lowerBound == 0xFF...
bne +
jmp .Cleanup; ...then return upperBound.
+
sta.b $28   ; Store the exclusive upper bound of the range.
lda.w $2989
bit.b #$20  ; If Attract Mode is set...
beq +
txa         ; ...then return lowerBound.
bra .Cleanup
+
lda.b $28   ; Check for divide by zero.
cmp.b #$00  ; If upperBound == zero...
beq .Cleanup; ...then return zero.
cmp.b $25   ; If upperBound == lowerBound...
beq .Cleanup; ...then return zero.
ldx.b $26   ; Load seed index.
sec
sbc.b $25   ; Calculate range = upperBound - lowerBound.
sta.b $2a   ; Store range.
cmp.b #$FF  ; If range == -1...
bne .RejectionThreshold
lda.l $fdba61,X; ...then return value 00-FF from lookup table.
bra .Cleanup
.RejectionThreshold ; Calculate the rejection threshold.
lda.b #$FF    ; rejectionThreshold = Floor(0xFF / range) * range.
sta.l $004204 ; Write FF to low byte of dividend.
lda.b #$00
sta.l $004205 ; Write zero to high byte of dividend.
lda.b $2a
sta.l $004206 ; Write range to the divisor. Quotient ready in 16 cycles.
nop #6
sta.l $004202 ; Store the range to first multiplicand.
lda.l $004214 ; Load low byte of quotient.
jmp $af7c

org $c1af79
jmp $af22   ; A safe entry point for anything calling the alternate RNG routine. Jump to the start of this routine.

org $c1af7c ; Pick up immediately after the jump instruction.
sta.l $004203 ; Write quotient as the other multiplicand. Product ready in 8 cycles.
nop #2
.Lookup
lda.l $fdba61, X
cmp $004216   ; Compare lookupValue to rejection threshold (product).
bcc .Remainder; If lookupValue < threshold, branch to calculate remainder.
inc $26     ; Else increment the seed index.
ldx $26
bra .Lookup ; Branch to try another lookup value.
.Remainder
sta.l $004204 ; The lookup value is the dividend.
lda.b #$00
sta.l $004205
lda.b $2a
sta.l $004206 ; The range is the divisor. Remainder ready in 16 cycles.
nop #8
lda.l $004216 ; Load the remainder.
clc
adc.b $25   ; Add lower bound.
inc $26     ; Increment seed index.
.Cleanup
rep #$10
rts

