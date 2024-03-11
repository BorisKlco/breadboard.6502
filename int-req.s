ORB_IRB = $6000
ORA_IRA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600C
IFR = $600D
IER = $600E

val = $0200
mod10 = $0202
msg = $0204
counter = $020A

E = $10
RW = $20
RS = $40

 .org $8000
 
reset:
  LDX #$ff ;set pointer
  TXS
  
  LDA #$00
  STA PCR
  
  LDA #$82
  STA IER
  
  CLI ; clear int req

  LDA #$ff ;set VIA as autput
  STA DDRB
  STA DDRA
  
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
  STA counter
  STA counter + 1

  
loop:
  LDA #$02 ;Cursor Home
  JSR lcd_instruction
  
  LDA #0
  STA msg
  
  LDA counter
  STA val
  LDA counter + 1
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

number: .word 1729

lcd_wait:
 PHA 
 LDA #$F0 ;set VIA as in/out
 STA DDRB
lcd_busy:
 LDA #RW
 STA ORB_IRB
 LDA #(RW | E)
 STA ORB_IRB
 LDA ORB_IRB ;upper nibble
 PHA
 LDA #RW
 STA ORB_IRB
 LDA #(RW | E)
 STA ORB_IRB
 LDA ORB_IRB
 PLA
 AND #$08
 BNE lcd_busy
 
 LDA #RW ;Clear E bit
 STA ORB_IRB
 
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
 STA ORB_IRB ; set upper nibble
 ORA #E
 STA ORB_IRB
 EOR #E
 STA ORB_IRB
 PLA
 AND #%00001111
 STA ORB_IRB
 ORA #E 
 STA ORB_IRB
 EOR #E
 STA ORB_IRB
 RTS
 
lcd_init:
 LDA #$02 ;4bit mode
 STA ORB_IRB
 ORA #E
 STA ORB_IRB
 AND #%00001111
 STA ORB_IRB
 RTS
 
write_char:
 JSR lcd_wait
 PHA
 LSR
 LSR
 LSR
 LSR
 ORA #RS
 STA ORB_IRB ; set upper nibble
 ORA #E
 STA ORB_IRB
 EOR #E
 STA ORB_IRB
 PLA 
 AND #%00001111
 ORA #RS
 STA ORB_IRB
 ORA #E 
 STA ORB_IRB
 EOR #E
 STA ORB_IRB
 RTS
 
nmi:
irq:
 PHA
 INC counter
 BNE exit_irq
 INC counter + 1
exit_irq:
 BIT ORA_IRA
 PLA
 RTI
 
 .org $9ffa ;for 28c64 rom
 .word nmi
 .word reset
 .word irq

 ;.org $fffa
 ;.word nmi
 ;.word reset
 ;.word irq
