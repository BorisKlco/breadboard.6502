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
NEW_LINE:
 ldx WRITE_PTR
 lda INPUT_BUFFER,x
 cmp #$0D ; CR?
 bne NEW_LINE
 lda #$01  ; disable CTS
 sta ACIA_CMD
 ldy #$FF
CH_SKIP:
 iny
COMMAND:
 lda INPUT_BUFFER, y
 cmp #$2E ; "."
 bcc CH_SKIP
 beq DOT
 cmp #$3A ; ":" 
 beq STORE
 cmp #$52 ; "R"
 beq RUNITEM
HEX:
 

