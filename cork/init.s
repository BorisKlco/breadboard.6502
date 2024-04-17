.segment "INIT"

RESET:
 cld
 jsr INIT_BUFFER
 cli
 lda #$1F ;8-N-1, BR 19200
 sta ACIA_CTRL
 lda #$89 ; no echo, rx INIT
 sta ACIA_CMD