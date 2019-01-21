	#include p18f87k22.inc
	
	code
	org 0x0
	goto	SPI
	
	org 0x100		    ; Main code starts here at address 0x100

start
	movlw	0x0
	movwf	TRISD, ACCESS
	movwf	TRISE, ACCESS
	; Initialization Address Bus
	call	enableadd
	; Set Data1 at PortD (Data Bus)
	movlw	0xaa		    ; Set W to 10101010b
	movwf	PORTE, ACCESS	    ; Move W to BankD
	; Set CP1 to LOW to HIGH
	movlw	0x0d		    ; 1101
	movwf	PORTD, ACCESS
	call	enableadd
	; Set Data2 at PortD (Data Bus)
	movlw	0x55		    ; Set W to 01010101b
	movwf	PORTE, ACCESS	    ; Move W to BankD
	; Set CP2 to LOW to HIGH
	movlw	0x7		    ; 0111
	movwf	PORTD, ACCESS
	call	enableadd
	; Set REPU and TRISE
	banksel	PADCFG1
	bsf	PADCFG1, REPU, BANKED
	movlb	0x00
	setf	TRISE		    ; Tri-state PortE
	; Set OE1* to low
	movlw	0x0e		    ; 1110
	movwf	PORTD, ACCESS
	; Set OE2* to low
	movlw	0xb		    ; 1011
	movwf	PORTD, ACCESS
	goto 0x0
	
enableadd
	movlw	0x0f		    ; Set W to 1111b
	movwf	PORTD, ACCESS	    ; Set OE1*, CP1, OE2*, CP2 to HIGH
	return
	


SPI
	call	SPI_MasterInit
	movlw	0x0
	movwf	0x26	; put in 0x26
loop	
	incf	0x26, 0 ; increase by 1
	movwf	0x26
	call	SPI_MasterTransmit
	call	Delay
	tstfsz	0x26
	bra	loop
	goto	0x0
	
	
SPI_MasterInit ; Set Clock edge to negative
	bcf	SSP2STAT, CKE
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw	(1<<SSPEN)|(1<<CKP)|(0x02)
	movwf	SSP2CON1
	; SDO2 output; SCK2 output
	bcf	TRISD, SDO2
	bcf	TRISD, SCK2
	return
	
SPI_MasterTransmit ; Start transmission of data (held in W)
	movwf	SSP2BUF	
Wait_Transmit ; Wait for transmission to complete
	btfss	PIR2, SSP2IF
	bra	Wait_Transmit
	bcf	PIR2, SSP2IF ; clear interrupt flag
	return

Delay ; Delay
	movlw	0x0a
	movwf	0x20
	call	PrimaryDelay
	
PrimaryDelay
	dcfsnz	0x20
	return
	movlw	0xff
	movwf	0x22
	call	SecondaryDelay
	bra	PrimaryDelay
	
SecondaryDelay
	dcfsnz	0x22
	return
	movlw	0xff
	movwf	0x24
	call	ThirdaryDelay
	bra	SecondaryDelay
	
ThirdaryDelay
	decfsz	0x24
	bra	ThirdaryDelay
	return
	
	
	end
