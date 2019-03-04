#include p18f87k22.inc
    
    global	play_music
    
    extern	Mp3file
    extern	delay_x4us, delay_ms

acs0	udata_acs
counter	res 1
efb	res 1 ; endFillByte
efb_c1	res 1 ; efb counter 1
efb_c2	res 1 ; efb counter 2
testB	res 1 ; test byte



game_mp3    code

play_music
    call    SPI_init		; master mode SdO1, SCK1
    call    send_music
    call    read_efb		; read endFillByte from VS1053
    call    send_efb_2052	; send 2080 copies of efb
    call    set_sm_cancel	; set sm_cancel in sci_mode to 1
efb_loop
    call    send_efb_32		; send another 32 byte
    call    read_sm_cancel	; read sm_cancel in sci_mode, store in W
    tstfsz  testB		; skip if SM_CANCEL in SCI_MODE reset
    bra	    efb_loop
    return

SPI_init ; Set Clock edge to negative
    bcf	    SSP1STAT, CKP
    ; MSSP enable; CKE=1; SPI master, clock=Fosc/64 (1MHz)
    movlw   (1<<SSPEN)|(1<<CKE)|(0x02)
    movwf   SSP1CON1
    ; SDO1 output; SCK1 output
    bcf	    TRISC, SCK1 ; RC3, opt
    bsf	    TRISC, SDI1 ; RC4, ipt
    bcf	    TRISC, SDO1 ; RC5, opt
    bsf	    TRISA, 2	; RA2 / DREQ, ipt
    bcf	    TRISB, 2	; RB2 / XDCS, ipt
    bcf	    TRISE, 2	; RE2 / XCS, ipt
    bsf	    LATE, 2
    return
 
table_setup
    movlw	upper(Mp3file)	; address of data in PM
    movwf	TBLPTRU		; load upper bits to TBLPTRU
    movlw	high(Mp3file)	; address of data in PM
    movwf	TBLPTRH		; load high byte to TBLPTRH
    movlw	low(Mp3file)	; address of data in PM
    movwf	TBLPTRL		; load low byte to TBLPTRL    
    movlw	0xff		; bytes to read ; TODO: read more bytes
    movwf 	counter		; our counter register
    return


send_music
    call    table_setup
transmit_loop ; Start transmission of data
    tblrd*+
    movff   TABLAT,SSP1BUF
    call    wait_transmit
    decfsz  counter
    bra	    transmit_loop
    return

read_efb ; read endFillByte @ 0x1e06
    bcf	    PORTE, 2
    movlw   0x01		; delay 4us
    call    delay_x4us
    movlw   0x03		; 'read' command
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x1e		; send address of endFillByte
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x06
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x0			; send clock pulse to receive data
    movwf   SSP1BUF
    call    wait_transmit
    movff   SSP1BUF, efb
    bsf	    PORTE, 2
    return

send_efb_2052 ; send 2080 efb
    movlw   0x41 ; 65.
    movwf   efb_c1
c1_loop
    call    send_efb_32
    decfsz  efb_c1
    bra	    c1_loop
    return
    
send_efb_32 ; send 32 bytes of efb
    movlw   0x20
    movwf   efb_c2
send_efb
    movff   efb, SSP1BUF
    call    wait_transmit
    decfsz  efb_c2
    bra	    send_efb
    return

set_sm_cancel ; set sm_cancel in sci_mode to 1 / set sci_mode to 0x4808
    bcf	    PORTE, 2
    movlw   0x01		; delay 4us
    call    delay_x4us
    movlw   0x02		;'write' command
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x0			; SCI_mode address
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x48
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x08
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x05		; delay 5 ms
    call    delay_ms
    bsf	    PORTE, 2
    return

read_sm_cancel ; read sm_cancel in sci_mode, store in W
    bcf	    PORTE, 2
    movlw   0x01		; delay 4us
    call    delay_x4us
    movlw   0x03		; 'read' command
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x0			; send address of sci_mode
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x0
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x0
    movwf   SSP1BUF
    call    wait_transmit
    movlw   0x8			; select only bit 3
    andwf   SSP1BUF, 0		; and, store in W
    movwf   testB
    bsf	    PORTE, 2
    return
    
wait_transmit ; Wait for transmission to complete
    btfss PIR1, SSP1IF
    bra wait_transmit
    bcf PIR1, SSP1IF ; clear interrupt flag
    return
    


    end