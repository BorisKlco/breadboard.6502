.setcpu "65C02"
.debuginfo
.segment "BIOS"

ACIA_DATA =     $5000
ACIA_STATUS =     $5001      ; status register
ACIA_CMD =     $5002      ; control register
ACIA_CTRL =     $5003      ; command register

CHRIN:
 lda ACIA_STATUS
 and #$08
 beq @no_keypressed
 lda ACIA_DATA
 jsr CHROUT
 sec
 rts
@no_keypressed:
 clc
 rts
 
CHROUT:
 PHA
 STA   ACIA_DATA
@txdelay:
 LDA   ACIA_STATUS
 AND   #$10
 BEQ   @txdelay
 PLA
 RTS
 
.include "lcd.s"
.include "wozmon.s"

.segment "RRVEC"
 .WORD $0F00      ; NMI
 .WORD RESET      ; RESET
 .WORD $0000      ; BRK/IRQ