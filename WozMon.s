ORB_VIA  =     $6000
ORA_VIA  =     $6001
DDRB     =     $6002
DDRA     =     $6003

E        =     $10
RW       =     $20
RS       =     $40

XAML     =     $24        ;  Last "opened" location Low
XAMH     =     $25        ;  Last "opened" location High
STL      =     $26        ;  Store address Low
STH      =     $27        ;  Store address High
L        =     $28        ;  Hex value parsing Low
H        =     $29        ;  Hex value parsing High
YSAV     =     $2A        ;  Used to see if hex value is given
MODE     =     $2B        ;  $00=XAM, $7F=STOR, $AE=BLOCK XAM

IN       =     $0200      ;  Input buffer to $027F
msg      =     $1000

ACIA_DATA =     $5000
ACIA_STATUS =     $5001      ; status register
ACIA_CMD =     $5002      ; control register
ACIA_CTRL =     $5003      ; command register

         .org  $8000

lcd_reset:
         PHA
         PHX
         LDA   #$ff       ;set VIA as autput
         STA   DDRB

         JSR   lcd_init
         LDA   #$28       ;4bit-2lines
         JSR   lcd_instruction
         LDA   #$0F       ; Display on, cursor on, blinking on
         JSR   lcd_instruction
         LDA   #$06       ; Increment,shift
         JSR   lcd_instruction
         LDA   #$01       ;clear Display
         JSR   lcd_instruction

         PLX
         PLA

         JMP   $FF00

         .org  $9000

lcd_rewrite:
         PHA
         PHX

         LDA   #$01       ;clear Display
         JSR   lcd_instruction


         LDX   #$00
         STX   $1080

custom_text:
         LDA   msg,X
         BEQ   halt
         JSR   write_char
         INX
         JMP   custom_text

halt:
         PLX
         PLA
         JMP   $FF00


lcd_init:
         LDA   #$02       ;4bit mode
         STA   ORB_VIA
         ORA   #E
         STA   ORB_VIA
         AND   #$0F
         STA   ORB_VIA
         RTS

lcd_wait:
         PHA              ;save A 
         LDA   #$F0       ;set VIA as in/out
         STA   DDRB
lcd_busy:
         LDA   #RW
         STA   ORB_VIA
         LDA   #(RW       | E)
         STA   ORB_VIA
         LDA   ORB_VIA    ;upper nibble
         PHA
         LDA   #RW
         STA   ORB_VIA
         LDA   #(RW       | E)
         STA   ORB_VIA
         LDA   ORB_VIA
         PLA
         AND   #$08
         BNE   lcd_busy

         LDA   #RW        ;Clear E bit
         STA   ORB_VIA

         LDA   #$FF       ;set VIA as output
         STA   DDRB
         PLA
         RTS

lcd_instruction:
         JSR   lcd_wait
         PHA
         PHA
         LSR
         LSR
         LSR
         LSR
         STA   ORB_VIA    ; set upper nibble
         ORA   #E
         STA   ORB_VIA
         EOR   #E
         STA   ORB_VIA
         PLA
         AND   #$0F
         STA   ORB_VIA
         ORA   #E
         STA   ORB_VIA
         EOR   #E
         STA   ORB_VIA
         PLA
         RTS

write_char:
         JSR   lcd_wait
         PHA
         PHA
         LSR
         LSR
         LSR
         LSR
         ORA   #RS
         STA   ORB_VIA    ; set upper nibble
         ORA   #E
         STA   ORB_VIA
         EOR   #E
         STA   ORB_VIA
         PLA
         AND   #$0F
         ORA   #RS
         STA   ORB_VIA
         ORA   #E
         STA   ORB_VIA
         EOR   #E
         STA   ORB_VIA
         PLA
         RTS

         .org  $FF00

RESET:
         LDA   #$1F       ;8-N-1,19200bps
         STA   ACIA_CTRL
         LDY   #$0B       ; no echo, no intrq
         STY   ACIA_CMD
         LDA   #$1B
NOTCR:
         CMP   #$08       ; "_"?
         BEQ   BACKSPACE  ; Yes.
         CMP   #$1B       ; ESC?
         BEQ   ESCAPE     ; Yes.
         INY              ; Advance text index.
         BPL   NEXTCHAR   ; Auto ESC if > 127.
ESCAPE:
         LDA   #$5C       ; "\".
         JSR   ECHO       ; Output it.
GETLINE:
         LDA   #$0D       ; CR.
         JSR   ECHO       ; Output it.
         LDY   #$01       ; Initialize text index.
BACKSPACE:
         DEY              ; Back up text index.
         BMI   GETLINE    ; Beyond start of line, reinitialize.
NEXTCHAR:
         LDA   ACIA_STATUS ; Key ready?
         AND   #$08
         BEQ   NEXTCHAR   ; Loop until ready.
         LDA   ACIA_DATA  ; Load character. B7 should be ‘1’.
         STA   IN,Y       ; Add to text buffer.
         JSR   ECHO       ; Display character.
         CMP   #$0D       ; CR?
         BNE   NOTCR      ; No.
         LDY   #$FF       ; Reset text index.
         LDA   #$00       ; For XAM mode.
         TAX              ; 0->X.
SETBLOCK: ASL
SETSTOR: ASL              ; Leaves $7B if setting STOR mode.
SETMODE: STA   MODE       ; $00=XAM, $74=STOR, $B8=BLOCK XAM.
BLSKIP:  INY              ; Advance text index.
NEXTITEM:
         LDA   IN,Y       ; Get character.
         CMP   #$0D       ; CR?
         BEQ   GETLINE    ; Yes, done this line.
         CMP   #$2E       ; "."?
         BCC   BLSKIP     ; Skip delimiter.
         BEQ   SETBLOCK   ; Set BLOCK XAM mode.
         CMP   #$3A       ; ":"?
         BEQ   SETSTOR    ; Yes. Set STOR mode.
         CMP   #$52       ; "R"?
         BEQ   RUN        ; Yes. Run user program.
         STX   L          ; $00->L.
         STX   H          ;  and H.
         STY   YSAV       ; Save Y for comparison.
NEXTHEX:
         LDA   IN,Y       ; Get character for hex test.
         EOR   #$30       ; Map digits to $0-9.
         CMP   #$0A       ; Digit?
         BCC   DIG        ; Yes.
         ADC   #$88       ; Map letter "A"-"F" to $FA-FF.
         CMP   #$FA       ; Hex letter?
         BCC   NOTHEX     ; No, character not hex.
DIG:
         ASL
         ASL              ; Hex digit to MSD of A.
         ASL
         ASL
         LDX   #$04       ; Shift count.
HEXSHIFT:
         ASL              ; Hex digit left, MSB to carry.
         ROL   L          ; Rotate into LSD.
         ROL   H          ; Rotate into MSD’s.
         DEX              ; Done 4 shifts?
         BNE   HEXSHIFT   ; No, loop.
         INY              ; Advance text index.
         BNE   NEXTHEX    ; Always taken. Check next character for hex.
NOTHEX:
         CPY   YSAV       ; Check if L, H empty (no hex digits).
         BEQ   ESCAPE     ; Yes, generate ESC sequence.
         BIT   MODE       ; Test MODE byte.
         BVC   NOTSTOR    ; B6=0 STOR, 1 for XAM and BLOCK XAM
         LDA   L          ; LSD’s of hex data.
         STA   (STL,X)    ; Store at current ‘store index’.
         INC   STL        ; Increment store index.
         BNE   NEXTITEM   ; Get next item. (no carry).
         INC   STH        ; Add carry to ‘store index’ high order.
TONEXTITEM: JMP   NEXTITEM   ; Get next command item.
RUN:     JMP   (XAML)     ; Run at current XAM index.
NOTSTOR: BMI   XAMNEXT    ; B7=0 for XAM, 1 for BLOCK XAM.
         LDX   #$02       ; Byte count.
SETADR:
         LDA   L-1,X      ; Copy hex data to
         STA   STL-1,X    ;  ‘store index’.
         STA   XAML-1,X   ; And to ‘XAM index’.
         DEX              ; Next of 2 bytes.
         BNE   SETADR     ; Loop unless X=0.
NXTPRNT:
         BNE   PRDATA     ; NE means no address to print.
         LDA   #$0D       ; CR.
         JSR   ECHO       ; Output it.
         LDA   XAMH       ; ‘Examine index’ high-order byte.
         JSR   PRBYTE     ; Output it in hex format.
         LDA   XAML       ; Low-order ‘examine index’ byte.
         JSR   PRBYTE     ; Output it in hex format.
         LDA   #$3A       ; ":".
         JSR   ECHO       ; Output it.
PRDATA:
         LDA   #$20       ; Blank.
         JSR   ECHO       ; Output it.
         LDA   (XAML,X)   ; Get data byte at ‘examine index’.
         JSR   PRBYTE     ; Output it in hex format.
XAMNEXT:
         STX   MODE       ; 0->MODE (XAM mode).
         LDA   XAML
         CMP   L          ; Compare ‘examine index’ to hex data.
         LDA   XAMH
         SBC   H
         BCS   TONEXTITEM ; Not less, so no more data to output.
         INC   XAML
         BNE   MOD8CHK    ; Increment ‘examine index’.
         INC   XAMH
MOD8CHK: LDA   XAML       ; Check low-order ‘examine index’ byte
         AND   #$07       ;  For MOD 8=0
         BPL   NXTPRNT    ; Always taken.
PRBYTE:
         PHA              ; Save A for LSD.
         LSR
         LSR
         LSR              ; MSD to LSD position.
         LSR
         JSR   PRHEX      ; Output hex digit.
         PLA              ; Restore A.
PRHEX:
         AND   #$0F       ; Mask LSD for hex print.
         ORA   #$30       ; Add "0".
         CMP   #$3A       ; Digit?
         BCC   ECHO       ; Yes, output it.
         ADC   #$06       ; Add offset for letter.
ECHO:
         PHA
         STA   ACIA_DATA
         LDA   #$FF
TX_DELAY:
                          ;LDA   ACIA_STATUS
                          ;AND   #$10
                          ;BEQ   TX_DELAY
         DEC
         BNE   TX_DELAY
         PLA
         RTS


         .org  $FFFA

         .WORD $0F00      ; NMI
         .WORD RESET      ; RESET
         .WORD $0000      ; BRK/IRQ
