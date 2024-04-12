; configuration
CONFIG_2A := 1

CONFIG_SCRTCH_ORDER := 2
CONFIG_PEEK_SAVE_LINNUM := 1

SAREG                   = $30C          ; Storage Area for .A Register (Accumulator)
SXREG                   = $30D          ; Storage Area for .X Index Register
SYREG                   = $30E          ; Storage Area for .Y Index Register
SPREG                   = $30F          ; Storage Area for .P (Status) Register

; zero page
ZP_START0 = $00
ZP_START1 = $02
ZP_START2 = $0C
ZP_START3 = $62
ZP_START4 = $6D

USR				:= GORESTART

; constants
SPACE_FOR_GOSUB := $3E
STACK_TOP		:= $FA
WIDTH			:= 40
WIDTH2			:= 30

RAMSTART2		:= $0400

LOAD:
 RTS
SAVE:
 RTS

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
