.segment "TOKEN"

P:
 ldx #$01
READ_INPUT:
 lda INPUT_BUFFER, x
 cmp #$0D
 beq P_RETURN
 eor #$30
 cmp #$0A
 bmi NUM
 adc #$88
 cmp #$FA
 bmi P_RETURN

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
 ldy #$FF
 rts

