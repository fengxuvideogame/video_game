	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Send_Byte_I, LCD_Send_Byte_D
	extern	KBD_Ch_Setup, Read_Columns, Read_Rows, Convert_Ascii
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern	Test_Mul_8_16
	extern	Test_Mul_16_16
	extern	Test_Mul_8_24
	extern	Convert_hex_dec, Test_convert
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	KBD_main

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello Link!\n"	; message, plus carriage return
	constant    myTable_l=.12	; length of data
	
main	code
	; *******  Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	goto	measure_loop_in_dec
	
	; ******* Main programme ****************************************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	
	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message
	
measure_loop
	call	ADC_Read
	call	MyDelay
	movf	ADRESH,W
	call	LCD_Write_Hex
	movf	ADRESL,W
	call	LCD_Write_Hex
	call	MyDelay
	call	clear_display
	goto	measure_loop		; goto current line in code

measure_loop_in_dec
	call	ADC_Read
	call	MyDelay
	movff	ADRESH, 0x3f
	movff	ADRESL, 0x40
	call	Convert_hex_dec
	movf	0x49, W
	call	LCD_Write_Hex
	movf	0x4a, W
	call	LCD_Write_Hex
	call	MyDelay
	call	clear_display
	goto	measure_loop_in_dec	; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	
clear_display
	movlw	b'00000001'
	call	LCD_Send_Byte_I
	return
	

MyDelay ; Delay
	movlw	0x3f
	movwf	0x20
	call	PrimaryDelay
	return
	
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
	
ShiftLine
	movlw	b'11000000'
	call	LCD_Send_Byte_I
	return

KBD_main
	call	KBD_Ch_Setup
	call	Read_Columns
	call	Convert_Ascii
	goto	setup2

	
setup2	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	;call	clear_display
start2	movf	0x32, 0
	call	LCD_Send_Byte_D
	call	MyDelay
	;call	clear_display
	goto	$

	end
