#include p18f87k22.inc
    
    global	high_int_setup
    extern	LED_array_update
    extern	read_columns, kpd_ch_setup
    extern	score_display

acs0	    udata_acs
counter1    res 1 ; primary counter
counter2    res	1 ; secondary counter
eog_counter res	1 ; end of game counter
c2_max	    res 1 ; max value for counter2
score	    res 1 ; user score
full_score  res 1 ; totoal score possible
temp	    res	1 ; for storing result from read_columns


int_hi	code	0x0008		; high vector
	;btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	;retfie	FAST		; if not then return
	bcf	INTCON,TMR0IF	; clear interrupt flag
	goto	timer_interrupt ; will not return

Interrupt   code	
high_int_setup ; setup counter interrupt for every beat
	movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	movlw	0xFF
	movwf	counter1
	movlw	0xFF		; counter 2 value, may be changed
	movwf	counter2
	movwf	c2_max
	movlw	0x0a		; end of game counter, may be changed
	movwf	eog_counter
	return
	
timer_interrupt ; interrupt on every beat when brick falls down
	dcfsnz	counter1	; skip if dec counter1 is not 0
	retfie	FAST
	movlw	0xFF		; reset counter 1
	movwf	counter1
	dcfsnz	counter2	; skip if dec counter2 is not 0
	retfie	FAST
	movff	c2_max, counter2; reset counter 2
	dcfsnz	eog_counter	; if it is the end of game
	goto	end_of_game_interrupt
	call	beat_interrupt
	retfie	FAST
	
beat_interrupt ; beat happens
	call	LED_array_update
	call	scoring
	return

scoring
	incf	full_score	; increment full score
	call	kpd_ch_setup	; re-initialize keypad
	call	read_columns	; result store in LSB of W
	movwf	temp
	swapf	temp, 1		; swap put in temp
	movlw	0xF0		; 11110000b
	andwf	PORTF, 0	; and, put in W
	addwf	temp, 1		; add, put in temp
	movlw	0xF0
	andwf	temp, 1		; give 0x00 if they match
	tstfsz	temp		; skip if zero
	return
	incf	score		; increment user score
	movf	score, W	; move current score to W
	call	score_display
	return
	
end_of_game_interrupt
	clrf	T0CON		; stop timer
	setf	LATE
	setf	LATH
        goto	$

    END

