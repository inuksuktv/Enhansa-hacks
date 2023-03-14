hirom

org $c1fabd     ; Start of fragment that loads PC stat blocks and checks Ayla's Fist.
nop #73

org $c1fabd     ; Write the new routine.
LoadStatBlocks:
tdc
tay
.StartLoop
phy             ; Push battle ID.
jsl $fdae52     ; Load combat stat block from main stat block.
ply             ; Pull battle ID.
iny             ; Increment battle ID.
cpy #$0003      ; Compare battle ID to three
bcc .StartLoop  ; Loop if < 3
bra $39         ; Branch to start the next section when complete.