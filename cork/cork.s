.debuginfo +
.setcpu "65C02"

BUFFER_PTR = $00

.segment "INPUT_BUFFER"
INPUT_BUFFER: .res $100

.include "zeropage.s"
.include "bios.s"