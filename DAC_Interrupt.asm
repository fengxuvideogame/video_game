	#include p18f87k22.inc
	
	global	DAC_Setup
	
	extern	delay_ms

acs0	udata_acs
counter	res 1
	
int_hi	code	0x0008	; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	;incf	LATD		; increment PORTD
	tblrd*+
	movf	TABLAT, W
	movwf	LATD
	DCFSNZ	counter
	call	Sine_Setup
	clrf	LATC
	call	delay_ms
	movlw	b'00000001'	; Set Write Enable * to HIGH
	movwf	PORTC
	bcf	INTCON,TMR0IF	; clear interrupt flag
	retfie	FAST		; fast return from interrupt

DAC	code
DAC_Setup
	call	Sine_Setup
	clrf	TRISD		; Set PORTD as all outputs
	clrf	LATD		; Clear PORTD outputs
	movlw	b'10000110'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	clrf	TRISC
	movlw	b'00000001'	; Set Write Enable * to HIGH
	movwf	PORTC
	return

sine_table
	db	0x80, 0x98, 0xb0, 0xc7, 0xda, 0xea, 0xf6, 0xfd, 0xff, 0xfd, 0xf6, 0xea, 0xda, 0xc7, 0xb0, 0x98, 0x80, 0x67, 0x4f, 0x38, 0x25, 0x15, 0x9, 0x2, 0x0, 0x2, 0x9, 0x15, 0x25, 0x38, 0x4f, 0x67
	constant    sine_table_l=.32
	
Sine_Setup
	movlw	upper(sine_table)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(sine_table)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(sine_table)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	sine_table_l	; bytes to read
	movwf 	counter		; our counter register
	return
	
	end

