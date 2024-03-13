ORB_VIA = $6000
ORA_VIA = $6001
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
  
 LDA #%10111111
 STA DDRA

wait:
 BIT ORA_VIA
 BVS wait

 LDX #8
 JSR half_bit
read_bit:
 JSR bit_delay
 BIT ORA_VIA
 BVS get_1
 CLC
 JMP rx_done
get_1:
 SEC
rx_done:
 ROR
 DEX
 BNE read_bit
 JSR write_char
 JMP wait

bit_delay:
 LDY #14
bit_loop:
 DEY 
 BNE bit_loop
 RTS

half_bit:
 LDY #7
half_bit_delay:
 DEY 
 BNE half_bit_delay
 RTS


lcd_wait:
 PHA ;save A 
 LDA #$F0 ;set VIA as in/out
 STA DDRB
lcd_busy:
 LDA #RW
 STA ORB_VIA
 LDA #(RW | E)
 STA ORB_VIA
 LDA ORB_VIA ;upper nibble
 PHA
 LDA #RW
 STA ORB_VIA
 LDA #(RW | E)
 STA ORB_VIA
 LDA ORB_VIA
 PLA
 AND #$08
 BNE lcd_busy
 
 LDA #RW ;Clear E bit
 STA ORB_VIA
 
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
 STA ORB_VIA ; set upper nibble
 ORA #E
 STA ORB_VIA
 EOR #E
 STA ORB_VIA
 PLA
 AND #$0F
 STA ORB_VIA
 ORA #E 
 STA ORB_VIA
 EOR #E
 STA ORB_VIA
 RTS
 
lcd_init:
 LDA #$02 ;4bit mode
 STA ORB_VIA
 ORA #E
 STA ORB_VIA
 AND #$0F
 STA ORB_VIA
 RTS
 
write_char:
 JSR lcd_wait
 PHA
 LSR
 LSR
 LSR
 LSR
 ORA #RS
 STA ORB_VIA ; set upper nibble
 ORA #E
 STA ORB_VIA
 EOR #E
 STA ORB_VIA
 PLA 
 AND #$0F
 ORA #RS
 STA ORB_VIA
 ORA #E 
 STA ORB_VIA
 EOR #E
 STA ORB_VIA
 RTS
 
 .org $9ffc ;for 28c64 rom
 .word reset
 .word $0000

  .org $fffc
  .word reset
  .word $0000