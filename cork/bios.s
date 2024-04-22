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
 rts
; -----------------
; Delay for 6mhz
; -----------------
CHROUT:
 pha
 sta ACIA_DATA
 phx
 ldx #$03
@dual_delay:
 lda #$FF
@txdelay:       
 dec
 bne @txdelay
 dex
 bne @dual_delay
 plx
 pla
 rts
; -------------------------------------

IRQ:
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