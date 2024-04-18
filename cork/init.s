.segment "INIT"

RESET:
 jsr INIT_BUFFER
 lda #$1F ;8-N-1, BR 19200
 sta ACIA_CTRL
 lda #$89 ; no echo, rx init
 sta ACIA_CMD
 cli
ESCAPE:
 lda #$5C
 jsr CHROUT
NEW_LINE:
 lda #$0D
 jsr CHROUT
 lda #$0A
 jsr CHROUT
BREAK:
 nop
 jmp BREAK


 

