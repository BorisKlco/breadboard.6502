.segment "MAIN"

RESET:
 lda #$1F ;8-N-1, BR 19200
 sta ACIA_CTRL
 lda #$0B
 sta ACIA_CMD
 stz INPUT_PTR
 cli
ESCAPE:
 lda #$5C ; "\"
 jsr CHROUT
NEW_LINE:
 lda #$0D ; CR
 jsr CHROUT
 lda #$0A ; LF
 jsr CHROUT
NEW_CHAR:
 lda ACIA_STATUS
 and #$08
 beq NEW_CHAR          ; Check new char
 ldy INPUT_PTR
 lda ACIA_DATA
 cmp #$08              ; Backspace?
 beq BACKSPACE
 cmp #$1B              ; Esc?
 beq ESCAPE         
 cmp #$0D
 beq ENTER             ; Enter?
 sta INPUT_BUFFER, y   ; Store
 inc INPUT_PTR
 jsr CHROUT
 bra NEW_CHAR
BACKSPACE:
 sec
 cpy #$01
 bcc NEW_CHAR
 clc
 dec INPUT_PTR
 bra NEW_CHAR
ENTER:
 ldy #$00
 lda INPUT_BUFFER, y
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
 rts

WRITE:
 rts

SET:
 rts

 
 


 

