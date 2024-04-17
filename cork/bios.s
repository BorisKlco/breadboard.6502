; -------------------------------------
; I/O Ports
;
ACIA_DATA = $5000
ACIA_STATUS = $5001     
ACIA_CMD = $5002    
ACIA_CTRL = $5003
;
; Zeropage
;
BUFFER_PTR = $00
;
; Input buffer - $0200
.segment "INPUT_BUFFER"
INPUT_BUFFER: .res $100
; -------------------------------------

.segment "BIOS"

; -------------------------------------
; Character in,out routine
; -----------------
CHRIN:
 jsr BUFFER_SIZE
 beq @no_input
 phx
 jsr READ_BUFFER
 plx
 jsr CHROUT
 pha
 jsr BUFFER_SIZE
 cmp #$E0
 bcs @mostly_full
 lda #$09
 sta ACIA_CMD
@mostly_full:
 pla
 clc
 rts
@no_input:
 clc
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


; -------------------------------------
; Mod: Flags, A
; -----------------
INIT_BUFFER:
 lda READ_PTR
 sta WRITE_PTR
 rts

; -----------------
; BUFFER SIZE
; Mod: Flags, A
; -----------------

BUFFER_SIZE:
 lda WRITE_PTR
 sec
 sbc READ_PTR
 rts

; -------------------------------------


; -------------------------------------
; READING BUFFER
; Mod: Flags, X
; -----------------

READ_BUFFER:
 ldx READ_BUFFER
 lda INPUT_BUFFER, X
 inc READ_BUFFER
 rts
 
; -----------------
; WRITING TO BUFFER
; Mod: Flags, X
; -----------------

WRITE_BUFFER:
 ldx WRITE_PTR
 sta INPUT_BUFFER,X
 inc WRITE_PTR
 rts

; -------------------------------------


; -------------------------------------
; IRQ - Input
; Mod: Flags, A, X
; -----------------
IRQ:
 pha
 phx
 lda ACIA_STATUS
 lda ACIA_DATA
 jsr WRITE_BUFFER
 jsr BUFFER_SIZE
 cmp #$F0
 bcc @not_full
 lda #$01
 sta ACIA_CMD
@not_full:
 clc
 plx
 pla
 rti
; -------------------------------------

; -------------------------------------
; RESTART_VECTORS - $FFFA
; SIZE = 6
; -----------------
.segment "RESTART_VECTORS" 
    .WORD $0F00 ;NMI
    .WORD RESET
    .WORD IRQ
; -------------------------------------