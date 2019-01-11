	#include p18f87k22.inc
	
	code
	org 0x0
	goto	start
	
	org 0x100		    ; Main code starts here at address 0x100

start
	movlw	0xff
	movwf	TRISD, ACCESS
	movlw 	0x0
	movwf	TRISC, ACCESS	    ; Port C all outputs
	movf	PORTD, W, ACCESS
	xorwf	0x0A, 1
	movlw	0x0
	bra 	test
loop	movff 	0x06, PORTC
	incf 	0x06, W, ACCESS
test	movwf	0x06, ACCESS	    ; Test for end of loop condition
	;movlw	0x63	
	movf	0x0A, W, ACCESS
	cpfsgt 	0x06, ACCESS
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start
	
	end
