.segment "INIT"

RESET:
 jsr INIT_BUFFER
 lda #$1F ;8-N-1, BR 19200
 sta ACIA_CTRL
 lda #$89 ; no echo, rx init
 sta ACIA_CMD
 cli
ESCAPE:
 lda #$5C ; "\"
 jsr CHROUT
NEW_LINE:
 lda #$0D ; CR
 jsr CHROUT
 lda #$0A ; LF
 jsr CHROUT
ENTER:
 ldx WRITE_PTR
 lda INPUT_BUFFER, x
 cmp #$0D
 beq PRINT
 jmp ENTER
BREAK:
 nop
 jmp BREAK
PRINT:
 ldy #$00
@print_loop:
 lda INPUT_BUFFER, y
 jsr CHROUT
 cpy WRITE_PTR
 beq NEW_LINE
 iny
 jmp @print_loop
 
 


 

