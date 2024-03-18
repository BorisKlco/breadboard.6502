 .org $0
 .org $1500
msg1: .asciiz "Oh, Hello,there!"
 .org $1600
msg2: .asciiz "Welcome in my                           custom Wozmon"
 .org $1700
msg3: .asciiz "Last step before                        bios and MSBASIC"

 PLA 
 PLX

 LDX #$00
 .org $2000
print_text:
	 LDA   msg1,X
	 BEQ   halt
	 STA $1000,X
	 INX
	 JMP   print_text

halt:
	 PLX
	 PLA
	 JMP   $F000

1500:4F 68 2C 20 48 65 6C 6C 6F 2C 74 68 65 72 65 21

1600: 57 65 6C 63 6F 6D 65 20 69 6E 20 6D 79 20 20 20
1610: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
1620: 20 20 20 20 20 20 20 20 63 75 73 74 6F 6D 20 57
1630: 6F 7A 6D 6F 6E 00

1700: 4C 61 73 74 20 73 74 65 70 20 62 65 66 6F 72 65
1710: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
1720: 20 20 20 20 20 20 20 20 62 69 6F 73 20 61 6E 64
1730: 20 4D 53 42 41 53 49 43 00 68 FA A2 00

2000: BD 00 15 F0 07 9D 00 10 E8 4C 00 20 FA 68 4C 00
2010: F0