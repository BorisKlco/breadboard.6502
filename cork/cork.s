.debuginfo +
.setcpu "65C02"

; -------------------------------------
; SETTING VARIABLES
; -----------------
LINE_WIDTH = $50 ; 80 characters
; -------------------------------------

.zeropage
INPUT_PTR := $FF

INPUT_BUFFER := $0200

.include "bios.s"
.include "main.s"