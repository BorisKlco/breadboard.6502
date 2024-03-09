ORB = $6000
ORA = $6001
DDRB = $6002
DDRA = $6003

val = $0200
mod10 = $0202
msg = $0204

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
  
  LDA #0
  TAX
  TAY
  STA msg
  
  LDA number
  STA val
  LDA number + 1
  STA val + 1
  
divide:
  LDA #0
  STA mod10
  STA mod10 + 1
  CLC
  
  LDX #16
div_loop:
  ROL val
  ROL val + 1
  ROL mod10
  ROL mod10 + 1
  SEC
  LDA mod10
  SBC #10
  TAY
  LDA mod10 + 1
  SBC #0
  BCC ignore_r
  STY mod10
  STA mod10 + 1
  
ignore_r:
  DEX
  BNE div_loop
  ROL val
  ROL val + 1
  
  LDA mod10
  CLC
  ADC #"0"
  STA mod10
  LDA mod10
  JSR push_char
  
  LDA val
  ORA val + 1
  BNE divide
  
  LDX #0
  
print:
 LDA msg,x
 BEQ loop
 JSR write_char
 INX
 JMP print

push_char:
 PHA
 LDY #0
 
 loop_char:
 LDA msg,y
 TAX
 PLA
 STA msg,y
 INY
 TXA
 PHA
 BNE loop_char
 
 PLA
 STA msg,y
 RTS

loop:
  JMP loop

number: .word 1729

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
 PLA
 AND #$0F
 STA ORB
 ORA #E 
 STA ORB
 EOR #E
 STA ORB
 RTS
 
lcd_init:
 LDA #$02 ;4bit mode
 STA ORB
 ORA #E
 STA ORB
 AND #$0F
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
 PLA 
 AND #$0F
 ORA #RS
 STA ORB
 ORA #E 
 STA ORB
 EOR #E
 STA ORB
 RTS
 
 .org $9ffc ;for 28c64 rom
 .word reset
 .word $0000

  .org $fffc
  .word reset
  .word $0000