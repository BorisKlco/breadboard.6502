.setcpu "65C02"
.segment "LCD"

ORB_VIA  =     $6000
ORA_VIA  =     $6001
DDRB     =     $6002
DDRA     =     $6003

E        =     $10
RW       =     $20
RS       =     $40

msg      =     $400

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

         JMP   RESET

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
		 
.segment "LCD_WRITE"
lcd_rewrite:
         PHA
         PHX

         LDA   #$01       ;clear Display
         JSR   lcd_instruction

         LDX   #$00
		 
custom_text:
         LDA   msg,X
         BEQ   halt
         JSR   write_char
         INX
         JMP   custom_text

halt:
         PLX
         PLA
         JMP   RESET