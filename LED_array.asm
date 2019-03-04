#include p18f87k22.inc
    
    global	LED_array_setup, LED_array_update
    global	LED_array_test
    extern	Mp3file
    extern	delay_ms

acs0	udata_acs
count	res 1    
obt	res 1
upd	res 1
zero	res 1
    
LED_Array    code

LED_array_setup
    clrf    TRISE ;port E, upper one, follow 7654 3210
    clrf    TRISH ;port F, lower one, follow 3210 7654
    setf    LATE
    setf    LATH
    movlw   0x64 ; delay 100ms
    call    delay_ms
    clrf    LATE
    clrf    LATH
    movlw	upper(Mp3file)	; address of data in PM
    movwf	TBLPTRU		; load upper bits to TBLPTRU
    movlw	high(Mp3file)	; address of data in PM
    movwf	TBLPTRH		; load high byte to TBLPTRH
    movlw	low(Mp3file)	; address of data in PM
    movwf	TBLPTRL		; load low byte to TBLPTRL    
    movlw	0xff		; bytes to read
    movwf 	count		; our counter register
    return
    
    
LED_array_update
    ;read 7654 from TRISE
    swapf   LATH,1,0 ;swap for port F, saved in port F
    movlw   0xf0 ;set W for AND operation
    andwf   LATH,1,0 ;make port F only 7654, saved to port F
    movlw   0x0f; set W for AND operation
    andwf   LATE,0,0 ;save in W, only 3210 of Port E
    xorwf   LATH,1,0 ; xor W to port F, saved in port F
    swapf   LATE,1,0 ; swap for port E, saved in port E
    movlw   0x0f ;set W for AND operation
    andwf   LATE,1,0 ;make port E only 3210, saved to port E
    call    LED_generate ;new input for port E, expect W to be xxxx0000
    xorwf   LATE,1,0 ; xor W to port E, saved in port E
    return
       
LED_generate ; generate new pattern on top of LED array
    tblrd*+
    movlw	0x03
    andwf	TABLAT, 0
    movwf	obt
    clrf	zero
    clrf	upd
    ;0x00
    call	Set0
    ;0x01
    movf	obt, W
    sublw	0x01 ; 0
    cpfslt	zero ; compare, skip if 0<W
    call	Set1
    ;0x02
    movf	obt, W
    sublw	0x02 ; 0
    cpfslt	zero ; compare, skip if 0<W
    call	Set2
    ;0x03
    movf	obt, W
    sublw	0x03 ; 0
    cpfslt	zero ; compare, skip if 0<W
    call	Set3
    ;put result into W
    movf	upd, W
    return 
    
Set0
	movlw 0x80
	movwf upd
	return
	
Set1
	movlw 0x40
	movwf upd
	return
	
Set2
	movlw 0x20
	movwf upd
	return
	
Set3
	movlw 0x10
	movwf upd
	return
    
LED_array_test
	call	LED_array_setup
	movlw	0x82
	movwf	PORTE
	movlw	0x24
	movwf	PORTH
test_loop
	call	LED_array_update
	movlw	0xff		;256ms delay
	call	delay_ms
	call	delay_ms
	bra	test_loop
	

    END

