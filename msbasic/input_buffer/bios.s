.setcpu "65C02"
.debuginfo

.zeropage
.org ZP_START0
READ_PTR:  .res 1
WRITE_PTR: .res 1

.segment "INPUT_BUFFER"
INPUT_BUFFER: .res $100

SAREG = $90C          ; Storage Area for .A Register (Accumulator)
SXREG = $90D          ; Storage Area for .X Index Register
SYREG = $90E          ; Storage Area for .Y Index Register
SPREG = $90F          ; Storage Area for .P (Status) Register

.segment "BIOS"

ACIA_DATA =     $5000
ACIA_STATUS =     $5001     
ACIA_CMD =     $5002    
ACIA_CTRL =     $5003 

MONRDKEY:
CHRIN:
 phx
 jsr BUFFER_SIZE
 beq @no_keypressed
 jsr READ_BUFFER
 jsr CHROUT
 pha
 jsr BUFFER_SIZE
 cmp #$B0
 bcs @mostly_full
 lda #$09
 sta ACIA_CMD
@mostly_full:
 pla
 plx
 sec
 rts
@no_keypressed:
 plx
 clc
 rts
 

MONCOUT:
CHROUT:
    pha
    sta     ACIA_DATA
    phx
    ldx #$03
@dual_delay:
    lda     #$FF
@txdelay:       
    dec
    bne     @txdelay
    dex
    bne     @dual_delay
    plx
    pla
    rts

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
 jsr BUFFER_SIZE
 sec
 cmp #$F0
 bcc @not_full
 lda #$01
 sta ACIA_CMD
@not_full:
 clc
 plx
 pla
 rti


.include "lcd.s"
.include "wozmon.s"

.segment "RRVEC"
 .WORD $0F00      ; NMI
 .WORD RESET      ; RESET
 .WORD IRQ        ; BRK/IRQ