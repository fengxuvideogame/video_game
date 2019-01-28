#include p18f87k22.inc
    
    global	KBD_Ch_Setup, Read_Columns, Read_Rows, Test_Ascii
    extern	LCD_delay_x4us

KEYBOARD    code
	
KBD_Ch_Setup
	; Set Port E Pull Up
	banksel	PADCFG1
	bsf	PADCFG1, REPU, BANKED
	movlb	0x00
	; Set LatE to 0x00
	clrf	LATE
	; Set Port D to Output
	clrf	LATD
	movlw	0x0
	movwf	TRISD, ACCESS

Read_Columns
	movlw	0x0F
	movwf	TRISE, ACCESS
	call	LCD_delay_x4us
	movff	PORTE, PORTD
	
Read_Rows
	movlw	0xF0
	movwf	TRISE, ACCESS
	call	LCD_delay_x4us
	movf	PORTE, W
	addwf	PORTD, 0
	movwf	LATD, A
	return

Test_Ascii ; find corresponding ascii and store at 0x32
	movlw	0x0
	movwf	0x30 ; 0x30 is 0x0
	; 0
	movf	PORTD, W
	sublw	0x7d ; 0
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set0
	; 1
	movf	PORTD, W
	sublw	0xee
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set1
	; 2
	movf	PORTD, W
	sublw	0xed ; 2
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set2
	; 3
	movf	PORTD, W
	sublw	0xeb ; 3
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set3
	; 4
	movf	PORTD, W
	sublw	0xde ; 4
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set4
	; 5
	movf	PORTD, W
	sublw	0xdd ; 5
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set5
	; 6
	movf	PORTD, W
	sublw	0xdb ; 6
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set6
	; 7
	movf	PORTD, W
	sublw	0xbe ; 7
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set7
	; 8
	movf	PORTD, W
	sublw	0xbd ; 8
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set8
	; 9
	movf	PORTD, W
	sublw	0xbb ; 9
	cpfslt	0x30 ; compare, skip if 0<W
	call	Set9
	; *
	movf	PORTD, W
	sublw	0x7e ; *
	cpfslt	0x30 ; compare, skip if 0<W
	call	Sets
	; #
	movf	PORTD, W
	sublw	0x7b ; #
	cpfslt	0x30 ; compare, skip if 0<W
	call	Seth
	; A
	movf	PORTD, W
	sublw	0xe7 ; A
	cpfslt	0x30 ; compare, skip if 0<W
	call	SetA
	; B
	movf	PORTD, W
	sublw	0xd7 ; B
	cpfslt	0x30 ; compare, skip if 0<W
	call	SetB
	; C
	movf	PORTD, W
	sublw	0xb7 ; C
	cpfslt	0x30 ; compare, skip if 0<W
	call	SetC
	; D
	movf	PORTD, W
	sublw	0x77 ; D
	cpfslt	0x30 ; compare, skip if 0<W
	call	SetD
	return

Set0
        movlw   0x30
        movwf   0x32
        return

Set1
        movlw   0x31
        movwf   0x32
        return

Set2
        movlw   0x32
        movwf   0x32
        return

Set3
        movlw   0x33
        movwf   0x32
        return

Set4
        movlw   0x34
        movwf   0x32
        return

Set5
        movlw   0x35
        movwf   0x32
        return

Set6
        movlw   0x36
        movwf   0x32
        return

Set7
        movlw   0x37
        movwf   0x32
        return

Set8
        movlw   0x38
        movwf   0x32
        return

Set9
        movlw   0x39
        movwf   0x32
        return

Sets
        movlw   0x2a
        movwf   0x32
        return

Seth
        movlw   0x23
        movwf   0x32
        return

SetA
        movlw   0x41
        movwf   0x32
        return

SetB
        movlw   0x42
        movwf   0x32
        return

SetC
        movlw   0x43
        movwf   0x32
        return

SetD
        movlw   0x44
        movwf   0x32
        return



    end