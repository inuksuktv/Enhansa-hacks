hirom

org $01bd82 ; Location that adjusts ATB timer for Haste.
jsl $cfff30 ; Jump to free space. This JSL writes over 4 bytes that load ATB then lsr. The value in A gets stored immediately after this.

org $c1bd90 ; Location that adjusts ATB timer for Slow.
jsl $cfff58 ; Jump to free space. This JSL writes over 4 bytes that load ATB then asl. The value in A gets stored immediately after this.

org $cfff30 ; Free space to calculate new Haste ATB bonus.
lda $afab,X ; Load ATB.
sta $2a     ; Store ATB.
php
rep #$20    ; Set A 16-bit.
asl #2      ; x4
sta $28     ; Store ATB*4.
clc
adc $2a     ; Add (4+1)*ATB.
sta $2a     ; Store 5*ATB.
lda $28     ; Load 4*ATB.
asl #2      ; x4 to get 16*ATB.
sec
sbc $2a     ; Subtract (16-5)*ATB.
lsr #4      ; /16
plp
rtl         ; We store 11*ATB/16 (ATB*0.688) approximately 2*ATB/3 when we get back.

org $cfff58 ; Free space to calculate new Slow ATB malus.
lda $afab,X ; Load ATB.
sta $2a     ; Store ATB.
php
rep #$20    ; Set A 16-bit.
asl #2      ; x4
sta $28     ; Store 4*ATB.
clc
adc $2a     ; Add (4+1)*ATB.
sta $2a     ; Store 5*ATB.
lda $28     ; Load 4*ATB.
asl #2      ; x4 to get 16*ATB.
clc
adc $2a     ; Add (16+5)*ATB.
lsr #4      ; /16
plp
rtl         ; We store 21*ATB/16 (ATB*1.313) approximately 4*ATB/3 when we get back.