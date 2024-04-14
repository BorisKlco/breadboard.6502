; configuration
CONFIG_2A := 1

CONFIG_SCRTCH_ORDER := 2

; zero page
ZP_START0 = $00
ZP_START1 = $02
ZP_START2 = $0C
ZP_START3 = $62
ZP_START4 = $6D

; extra/override ZP variables
;USR := GORESTART
USR := $910

; constants
SPACE_FOR_GOSUB := $3E
STACK_TOP := $FA
WIDTH := 40
WIDTH2 := 30
RAMSTART2 := $0400

LOAD:
SAVE:
 rts

SYS:                
    jsr FRMNUM              ; Eval formula
    jsr GETADR              ; Convert to int. addr
    lda #>SYSRETURN         ; Push return address
    pha
    lda #<SYSRETURN
    pha
    lda SPREG               ; Status reg
    pha
    lda SAREG               ; Load 6502 regs
    ldx SXREG
    ldy SYREG
    plp                     ; Load 6502 status reg
    jmp (LINNUM)            ; Go do it
SYSRETURN=*-1                
    php                     ; Save status reg
    sta SAREG               ; Save 6502 regs
    stx SXREG
    sty SYREG
    pla                     ; Get status reg
    sta SPREG
    rts 