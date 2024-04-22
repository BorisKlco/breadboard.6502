.segment "MAIN"

RESET:
 lda #$1F ;8-N-1, BR 19200
 sta ACIA_CTRL
 lda #$0B
 sta ACIA_CMD
 lda #$00
 sta INPUT_PTR
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
 cmp #$1B
 beq ESCAPE         
 sta INPUT_BUFFER, y   ; Store
 inc INPUT_PTR
 jsr CHROUT
 jmp NEW_CHAR
BACKSPACE:
 sec
 cpy #$01
 bcc NEW_CHAR
 clc
 dec INPUT_PTR
 jmp NEW_CHAR

 
 


 

