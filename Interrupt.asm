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
	movlw	b'11000101'	; Set timer0 to 8-bit, presacle factor of 6
	movwf	T0CON		; 1.024ms interrupt interval
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	movlw	0x01		; 425 loops in total for C1 and C2 combined
	movwf	counter1
	movlw	0xA9		; 425d=1A9h
	movwf	counter2
	movwf	c2_max		; maximum value of C2
	movlw	0x3c		; end of game counter, may be changed
	movwf	eog_counter
	clrf	score
	clrf	full_score
	return
	
timer_interrupt ; interrupt on every beat when brick falls down
	decfsz	counter1	; decrement C1, skip if 0
	retfie	FAST		; fast return
	decfsz	counter2	; decrement C2, skip if 0
	retfie	FAST		; fast return
	movlw	0x01		; 425 loops in total for C1 and C2 combined
	movwf	counter1
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
	andwf	LATH, 0		; and, put in W
	addwf	temp, 1		; add, put in temp
	comf	temp, 1		; complement temp
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

