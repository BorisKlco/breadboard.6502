; nothing - ISCNTC is a KERNAL function

ISCNTC:
 JSR MONRDKEY
 BCC not_cntc
 CMP #3
 BNE not_cntc
 JMP is_cntc

not_cntc:
 rts

is_cntc: