; -------------------------------------
; I/O Ports
ACIA_DATA   = $5000
ACIA_STATUS = $5001     
ACIA_CMD    = $5002    
ACIA_CTRL   = $5003
;
; VIA - LCD
ORB_VIA     = $6000
ORA_VIA     = $6001
DDRB        = $6002
DDRA        = $6003
; -------------------------------------

.segment "BIOS"

; -------------------------------------
; Character in,out routine
; -----------------
CHRIN:
 jsr BUFFER_SIZE
 beq @no_kp
 phx
 jsr READ_BUFFER
 jsr CHROUT
 plx
 sec
 rts
@no_kp:
 clc
 rts

; -----------------
CHROUT:
 pha
 sta ACIA_DATA
@delay:
 lda ACIA_STATUS
 and #$10
 beq @delay
 pla
 rts
; -------------------------------------

INIT_BUFFER:
 lda READ_PTR
 sta WRITE_BUFFER
 rts

WRITE_BUFFER:
 ldx WRITE_PTR
 sta INPUT_BUFFER, x
 inc WRITE_PTR
 rts

READ_BUFFER:
 ldx READ_PTR
 lda INPUT_BUFFER, x
 inc READ_PTR
 rts

BUFFER_SIZE:
 lda WRITE_BUFFER
 sec
 sbc READ_PTR
 rts

; -------------------------------------
IRQ:
 pha
 phx
 lda ACIA_STATUS
 lda ACIA_DATA
 jsr WRITE_BUFFER
 plx
 pla
 rti

NMI:
 rti

; -------------------------------------
; RESTART_VECTORS - $FFFA
; SIZE = 6
; -----------------
.segment "RESTART_VECTORS" 
    .WORD NMI
    .WORD RESET
    .WORD IRQ
; -------------------------------------