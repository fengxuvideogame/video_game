#include p18f87k22.inc
    
    global	delay_ms, delay_x4us, LCD_delay

acs0	    udata_acs   ; reserve data space in access ram
LCD_cnt_ms  res 1   ; reserve one byte for a counter variable
LCD_cnt_l   res 1   ; reserve one byte for counter in the delay routine
LCD_cnt_h   res	1
   
Delays    code
 
; ** a few delay routines below here as LCD timing can be quite critical ****
delay_ms		    ; delay given in ms in W
	movwf	LCD_cnt_ms
lcdlp2	movlw	.250	    ; 1 ms delay
	call	delay_x4us	
	decfsz	LCD_cnt_ms
	bra	lcdlp2
	return
    
delay_x4us		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l   ; now need to multiply by 16
	swapf   LCD_cnt_l,F ; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l,W ; move low nibble to W
	movwf	LCD_cnt_h   ; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l,F ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1	decf 	LCD_cnt_l,F	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h,F	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return

        END
