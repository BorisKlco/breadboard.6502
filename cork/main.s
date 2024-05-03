.segment "MAIN"

RESET:
 lda #$1F ;8-N-1, BR 19200
 sta ACIA_CTRL
 lda #$09 ;no echo, irq
 sta ACIA_CMD
 jsr INIT_BUFFER
 cli
ESCAPE:
 lda #$5C ; "\"
 jsr CHROUT
NEW_LINE:
 lda #$0D ; CR
 jsr CHROUT
 lda #$0A ; LF
 jsr CHROUT
 stz INPUT_PTR
NEW_CHAR:
 jsr CHRIN
 bcc NEW_CHAR          ; Check new char
 ldy INPUT_PTR         
 cmp #$08              ; Backspace?
 beq BACKSPACE
 cmp #$1B              ; Esc?
 beq ESCAPE
 sta TEXT_BUFFER, y    ; Store
 cmp #$0D
 beq ENTER             ; Enter?
 inc INPUT_PTR
 bra NEW_CHAR

BACKSPACE:
 cpy #$01
 bcc NEW_CHAR
 dec INPUT_PTR
 bra NEW_CHAR

ENTER:
 lda #$0A ; LF
 jsr CHROUT
 ldy #$00
 lda TEXT_BUFFER, y
 cmp #$50              ; "P" ?
 beq PRINT
 cmp #$53              ; "S" ?
 beq SET
 cmp #$57              ; "W" ?
 beq WRITE
ERROR:
 lda error_cmd, y
 beq NEW_LINE
 jsr CHROUT
 iny
 bra ERROR
 
; -------------------------------------
;  - PRINT: print data on addr
;  - WRITE: write to LCD
;  - SET: set data to addr
; -------------------------------------

PRINT:
 jsr P
 jsr HEX_TO_ADDR
 lda (P_LOWER)
 jsr P_BYTE
 jmp NEW_LINE

WRITE:
 jsr P
 jsr HEX_TO_ADDR
 ldy #$02
@find_set
 cpy #$10
 beq ERROR
 lda TEXT_BUFFER,y
 cmp #$3A
 beq @new_value
 iny
 bra @find_set
@new_value
 jmp NEW_LINE

SET:
 lda s_msg, y
 beq @done
 jsr CHROUT
 iny
 bra SET
@done:
 jmp NEW_LINE

P_BYTE:
 pha
 lsr
 lsr
 lsr
 lsr
 jsr @comp
 pla
@comp:
 and #$0F
 ora #$30
 cmp #$3A
 bcc @digit
 adc #$06      ; Add offstet for A-F
@digit:
 jsr CHROUT
 rts
 

HEX_TO_ADDR:
 lda #$20
 jsr CHROUT
 lda P_HIGHER
 jsr P_BYTE
 lda P_LOWER
 jsr P_BYTE
 lda #$3A
 jsr CHROUT


 

