.debuginfo +
.setcpu "65C02"

; -------------------------------------
; SETTING VARIABLES
; -----------------
LINE_WIDTH = $50 ; 80 characters
; -------------------------------------

.zeropage
READ_PTR := $FE
WRITE_PTR := $FF
INPUT_PTR := $00
P_LOWER := $01
P_HIGHER := $02

INPUT_BUFFER := $0200
TEXT_BUFFER := $0300

.include "bios.s"
.include "main.s"
.include "text.s"
.include "token.s"