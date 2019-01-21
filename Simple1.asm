	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
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
	

	end
