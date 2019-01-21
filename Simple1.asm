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
	movlw	0x0f		    ; Set W to 1111b
	movwf	PORTD, ACCESS	    ; Set OE1*, CP1, OE2*, CP2 to HIGH
	; Set Data at PortD (Data Bus)
	movlw	0xaa		    ; Set W to 10101010b
	movwf	PORTE, ACCESS	    ; Move W to BankD
	; Set CP1 to LOW to high
	movlw	1101b
	movwf	PORTD, ACCESS
	movlw	1111b
	movwf	PORTD, ACCESS
	; Set REPU and TRISE
	banksel	PADCFG1
	bsf	PADCFG1, REPU, BANKED
	movlb	0x00
	setf	TRISE		    ; Tri-state PortE
	; Set OE1* to low
	movlw	1110b
	movwf	PORTD, ACCESS
	
	
	goto 0x0
	
	
	
	
	movlw 	0x0
	movwf	TRISB, ACCESS	    ; Port C all outputs
	bra 	test
loop	movff 	0x06, PORTB
	incf 	0x06, W, ACCESS
test	movwf	0x06, ACCESS	    ; Test for end of loop condition
	movlw 	0x63
	cpfsgt 	0x06, ACCESS
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start
	
	end
