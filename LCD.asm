#include p18f87k22.inc

    global  LCD_setup, LCD_Write_Message, LCD_Send_Byte_I
    global  LCD_Send_Byte_D
    global  LCD_Write_Hex
    global  score_display,wlcm_display
    
    extern  delay_ms, delay_x4us, LCD_delay
    extern  Convert_hex_dec

acs0    udata_acs   ; named variables in access ram
LCD_cnt_l   res 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h   res 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms  res 1   ; reserve 1 byte for ms counter
LCD_tmp	    res 1   ; reserve 1 byte for temporary use
LCD_counter res 1   ; reserve 1 byte for counting through nessage
scr_save  res	1   ;save the score obtained

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data  
  
acs_ovr	access_ovr
LCD_hex_tmp res 1   ; reserve 1 byte for variable LCD_hex_tmp	

	constant    LCD_E=5	; LCD enable bit
    	constant    LCD_RS=4	; LCD register select bit

LCD	code
	
openScn data	    "Welcome!"	; message
	constant    openScn_l=.8	; length of data

scrScn	data	    "Score:"	;message
	constant    scrScn_l=.6
	
	
LCD_setup
	clrf    LATB
	movlw   b'11000000'	    ; RB0:5 all outputs
	movwf	TRISB
	movlw   .40
	call	delay_ms	; wait 40ms for LCD to start up properly
	movlw	b'00110000'	; Function set 4-bit
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	movlw	b'00101000'	; 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	movlw	b'00101000'	; repeat, 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	movlw	b'00001111'	; display on, cursor on, blinking on
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	movlw	b'00000001'	; display clear
	call	LCD_Send_Byte_I
	movlw	.2		; wait 2ms
	call	delay_ms
	movlw	b'00000110'	; entry mode incr by 1 no shift
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	return

LCD_Write_Hex	    ; Writes byte stored in W as hex
	movwf	LCD_hex_tmp
	swapf	LCD_hex_tmp,W	; high nibble first
	call	LCD_Hex_Nib
	movf	LCD_hex_tmp,W	; then low nibble
LCD_Hex_Nib	    ; writes low nibble as hex character
	andlw	0x0F
	movwf	LCD_tmp
	movlw	0x0A
	cpfslt	LCD_tmp
	addlw	0x07	; number is greater than 9 
	addlw	0x26
	addwf	LCD_tmp,W
	call	LCD_Send_Byte_D ; write out ascii
	return
	
LCD_Write_Message	    ; Message stored at FSR2, length stored in W
	movwf   LCD_counter
LCD_Loop_message
	movf    POSTINC2, W
	call    LCD_Send_Byte_D
	decfsz  LCD_counter
	bra	LCD_Loop_message
	return

LCD_Send_Byte_I		    ; Transmits byte stored in W to instruction reg
	movwf   LCD_tmp
	swapf   LCD_tmp,W   ; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bcf	LATB, LCD_RS	; Instruction write clear RS bit
	call    LCD_Enable  ; Pulse enable Bit 
	movf	LCD_tmp,W   ; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bcf	LATB, LCD_RS    ; Instruction write clear RS bit
        call    LCD_Enable  ; Pulse enable Bit 
	return

LCD_Send_Byte_D		    ; Transmits byte stored in W to data reg
	movwf   LCD_tmp
	swapf   LCD_tmp,W   ; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bsf	LATB, LCD_RS	; Data write set RS bit
	call    LCD_Enable  ; Pulse enable Bit 
	movf	LCD_tmp,W   ; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bsf	LATB, LCD_RS    ; Data write set RS bit	    
        call    LCD_Enable  ; Pulse enable Bit 
	movlw	.10	    ; delay 40us
	call	delay_x4us
	return

LCD_Enable	    ; pulse enable bit LCD_E for 500ns
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	    LATB, LCD_E	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	    LATB, LCD_E	    ; Writes data to LCD
	return

clear_display
	movlw	b'00000001'
	call	LCD_Send_Byte_I
	return
	
	
wlcm_display
	;print"Welcome!"
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(openScn)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(openScn)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(openScn)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	openScn_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	openScn_l	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	return
	
	
score_display
	movwf	scr_save	;save the score
	call	clear_display	;clear the screen
	;print"score:"
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(scrScn)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(scrScn)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(scrScn)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	scrScn_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	scrScn_l	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	;print score
	movlw   0x00
	movwf   0x3f
	movf	scr_save
	movwf   0x40
	call    Convert_hex_dec
	; display them
	movf    0x49, W
	call    LCD_Write_Hex
	movf    0x4a, W
	call    LCD_Write_Hex
	return
	

    end


