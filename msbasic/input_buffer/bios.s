.setcpu "65C02"
.debuginfo

.zeropage
.org ZP_START0
READ_PTR:  .res 1
WRITE_PTR: .res 1

.segment "INPUT_BUFFER"
INPUT_BUFFER: .res $100

.segment "BIOS"

ACIA_DATA =     $5000
ACIA_STATUS =     $5001     
ACIA_CMD =     $5002    
ACIA_CTRL =     $5003 

MONRDKEY:
CHRIN:
 ;lda ACIA_STATUS
 ;and #$08
 phx
 jsr BUFFER_SIZE
 ;
 beq @no_keypressed
 ;lda ACIA_DATA
 jsr READ_BUFFER
 ;
 jsr CHROUT
 plx
 sec
 rts
@no_keypressed:
 plx
 clc
 rts
 

MONCOUT:
CHROUT:
 PHA
 STA   ACIA_DATA
@txdelay:
 LDA   ACIA_STATUS
 AND   #$10
 BEQ   @txdelay
 PLA
 RTS

; set pointers as same
; Modifies: flags, A
INIT_BUFFER:
 lda READ_PTR
 sta WRITE_PTR
 rts

;write a character feom A register
; Modifies: flags, X
WRITE_BUFFER:
 ldx WRITE_PTR
 sta INPUT_BUFFER, x
 inc WRITE_PTR
 rts

;read a char from input buffer
; Modifies: flags, A, X
READ_BUFFER:
 ldx READ_PTR
 lda INPUT_BUFFER, x
 inc READ_PTR
 rts

;Modifies: flags, A
BUFFER_SIZE:
 lda WRITE_PTR
 sec
 sbc READ_PTR
 rts

IRQ:
 pha
 phx
 lda ACIA_STATUS
 lda ACIA_DATA
 jsr WRITE_BUFFER
 plx
 pla
 rti

.include "lcd.s"
.include "wozmon.s"

.segment "RRVEC"
 .WORD $0F00      ; NMI
 .WORD RESET      ; RESET
 .WORD IRQ        ; BRK/IRQ