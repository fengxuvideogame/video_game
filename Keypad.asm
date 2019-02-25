#include p18f87k22.inc
    
    global	kpd_ch_setup, kpd_read
    extern	delay_x4us
   
acs0	udata_acs
temp_byte   res	1
zero_byte   res	1
result_byte res	1 ; byte for storing ascii result

Keypad    code
	
kpd_ch_setup
	; Set Port D Pull Up
	banksel	PADCFG1
	bsf	PADCFG1, RDPU, BANKED
	movlb	0x00
	; Set LatD to 0x00
	clrf	LATD
	return

kpd_read
	call	read_columns
	call	convert_ascii
	
read_columns ; read columns, put result in temp_byte
	movlw	0x0F
	movwf	TRISD, ACCESS
	call	delay_x4us
	movff	PORTD, temp_byte
	
read_rows; read columns, add with temp_byte and put in W
	movlw	0xF0
	movwf	TRISD, ACCESS
	call	delay_x4us
	movf	PORTD, W
	addwf	temp_byte, 0
	return

convert_ascii ; find corresponding ascii at W and store result at W
	movwf	temp_byte
	clrf	zero_byte ; zero_byte is 0x0
	; 0
	movf	temp_byte, W
	sublw	0x7d ; 0
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set0
	; 1
	movf	temp_byte, W
	sublw	0xee
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set1
	; 2
	movf	temp_byte, W
	sublw	0xed ; 2
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set2
	; 3
	movf	temp_byte, W
	sublw	0xeb ; 3
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set3
	; 4
	movf	temp_byte, W
	sublw	0xde ; 4
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set4
	; 5
	movf	temp_byte, W
	sublw	0xdd ; 5
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set5
	; 6
	movf	temp_byte, W
	sublw	0xdb ; 6
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set6
	; 7
	movf	temp_byte, W
	sublw	0xbe ; 7
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set7
	; 8
	movf	temp_byte, W
	sublw	0xbd ; 8
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set8
	; 9
	movf	temp_byte, W
	sublw	0xbb ; 9
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Set9
	; *
	movf	temp_byte, W
	sublw	0x7e ; *
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Sets
	; #
	movf	temp_byte, W
	sublw	0x7b ; #
	cpfslt	zero_byte ; compare, skip if 0<W
	call	Seth
	; A
	movf	temp_byte, W
	sublw	0xe7 ; A
	cpfslt	zero_byte ; compare, skip if 0<W
	call	SetA
	; B
	movf	temp_byte, W
	sublw	0xd7 ; B
	cpfslt	zero_byte ; compare, skip if 0<W
	call	SetB
	; C
	movf	temp_byte, W
	sublw	0xb7 ; C
	cpfslt	zero_byte ; compare, skip if 0<W
	call	SetC
	; D
	movf	temp_byte, W
	sublw	0x77 ; D
	cpfslt	zero_byte ; compare, skip if 0<W
	call	SetD
	movf	result_byte, W ; put result in W
	return

Set0
        movlw   0x30
        movwf   result_byte
        return

Set1
        movlw   0x31
        movwf   result_byte
        return

Set2
        movlw   0x32
        movwf   result_byte
        return

Set3
        movlw   0x33
        movwf   result_byte
        return

Set4
        movlw   0x34
        movwf   result_byte
        return

Set5
        movlw   0x35
        movwf   result_byte
        return

Set6
        movlw   0x36
        movwf   result_byte
        return

Set7
        movlw   0x37
        movwf   result_byte
        return

Set8
        movlw   0x38
        movwf   result_byte
        return

Set9
        movlw   0x39
        movwf   result_byte
        return

Sets
        movlw   0x2a
        movwf   result_byte
        return

Seth
        movlw   0x23
        movwf   result_byte
        return

SetA
        movlw   0x41
        movwf   result_byte
        return

SetB
        movlw   0x42
        movwf   result_byte
        return

SetC
        movlw   0x43
        movwf   result_byte
        return

SetD
        movlw   0x44
        movwf   result_byte
        return



    end