.segment "TOKEN"

P:
 ldx #$01
READ_INPUT:
 lda TEXT_BUFFER, x
 eor #$30
 cmp #$0A
 bcc NUM
 adc #$88
 cmp #$FA
 bcc P_RETURN

NUM:
 asl
 asl
 asl
 asl
 ldy #$04
HEX:
 asl
 rol P_LOWER
 rol P_HIGHER
 dey
 bne HEX
 inx
 bra READ_INPUT

P_RETURN:
 rts

