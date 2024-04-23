.debuginfo +
.setcpu "65C02"

; -------------------------------------
; SETTING VARIABLES
; -----------------
LINE_WIDTH = $50 ; 80 characters
; -------------------------------------

.zeropage
INPUT_PTR := $00
P_LOWER := $01
P_HIGHER := $02

INPUT_BUFFER := $0200

.include "bios.s"
.include "main.s"
.include "text.s"
.include "token.s"