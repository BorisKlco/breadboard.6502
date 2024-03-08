ORB = $6000
ORA = $6001
DDRB = $6002
DDRA = $6003

E = $10
RW = $20
RS = $40

 .org $8000
 
reset:
  LDX #$ff ;set pointer
  TXS

  LDA #$ff ;set VIA as autput
  STA DDRB
  
  JSR lcd_init
  LDA #$28 ;4bit-2lines
  JSR lcd_instruction
  LDA #$0F ; Display on, cursor on, blinking on
  JSR lcd_instruction
  LDA #$06 ; Increment,shift
  JSR lcd_instruction
  LDA #$01 ;clear Display
  JSR lcd_instruction
  LDX #$00
print:
  LDA msg,x
  BEQ loop
  JSR write_char
  INX
  JMP print
loop:
  JMP loop

msg: .asciiz "Hello, there! "
  
lcd_wait:
 PHA ;save A 
 LDA #$F0 ;set VIA as in/out
 STA DDRB
lcd_busy:
 LDA #RW
 STA ORB
 LDA #(RW | E)
 STA ORB
 LDA ORB ;upper nibble
 PHA
 LDA #RW
 STA ORB
 LDA #(RW | E)
 STA ORB
 LDA ORB
 PLA
 AND #$08
 BNE lcd_busy
 
 LDA #RW ;Clear E bit
 STA ORB
 
 LDA #$FF ;set VIA as output
 STA DDRB
 PLA 
 RTS
 
lcd_init:
 LDA #$02 ;4bit mode
 STA ORB
 ORA #E
 STA ORB
 AND #$0F
 STA ORB
 RTS
  
lcd_instruction:
 JSR lcd_wait
 PHA
 LSR
 LSR
 LSR
 LSR
 STA ORB ; set upper nibble
 ORA #E
 STA ORB
 EOR #E
 STA ORB
 PLA ; set lower nibble
 AND #$0F
 STA ORB
 ORA #E 
 STA ORB
 EOR #E
 STA ORB
 RTS
 
write_char:
 JSR lcd_wait
 PHA
 LSR
 LSR
 LSR
 LSR
 ORA #RS
 STA ORB ; set upper nibble
 ORA #E
 STA ORB
 EOR #E
 STA ORB
 PLA ; set lower nibble
 AND #(RS | $0F)
 STA ORB
 ORA #E 
 STA ORB
 EOR #E
 STA ORB
 RTS


  .org $fffc
  .word reset
  .word $0000