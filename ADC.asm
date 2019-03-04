#include p18f87k22.inc

    global  ADC_Setup, ADC_Read
    global  Test_Mul_8_16
    global  Test_Mul_16_16
    global  Test_Mul_8_24
    global  Convert_hex_dec, Test_convert
    
    extern  LCD_Write_Hex

ADC    code
    
ADC_Setup
    bsf	    TRISA,RA0	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL0   ; set A0 to analog
    movlw   0x01	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    movlw   0x30	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    return

ADC_Read
    bsf	    ADCON0,GO	    ; Start conversion
adc_loop
    btfsc   ADCON0,GO	    ; check to see if finished
    bra	    adc_loop
    return

Mul_8_16
    movf    0x42, W ; move 0x42 to W LSB
    mulwf   0x40 ; multiply them, store at PRODH:PRODL
    movff   PRODH, 0x44
    movff   PRODL, 0x45
    movf    0x41, W ; move 0x42 to W MSB
    mulwf   0x40 ; multiply them
    movf    PRODL, W
    addwf   0x44, 1
    movf    PRODH, W
    clrf    0x43
    addwfc  0x43, 1
    return

Test_Mul_8_16
    movlw   0xff
    movwf   0x40
    movlw   0xff
    movwf   0x41
    movlw   0xff
    movwf   0x42
    call    Mul_8_16
    movf    0x43, W
    call    LCD_Write_Hex
    movf    0x44, W
    call    LCD_Write_Hex
    movf    0x45, W
    call    LCD_Write_Hex
    goto    $

Mul_16_16
    call    Mul_8_16
    movff   0x45, 0x46
    movff   0x43, 0x47
    movff   0x44, 0x48
    movff   0x3f, 0x40
    call    Mul_8_16
    movf    0x48, W
    addwf   0x45, 1
    movf    0x47, W
    addwfc  0x44, 1
    movlw   0x0
    addwfc  0x43, 1
    return
 
Test_Mul_16_16
    ; Initiallise 0x40d2*0x418a
    movlw   0x41
    movwf   0x3f
    movlw   0x8a
    movwf   0x40
    movlw   0x04
    movwf   0x41
    movlw   0xd2
    movwf   0x42
    ; Multiply them
    call    Mul_16_16
    ; Display them on the screen
    movf    0x43, W
    call    LCD_Write_Hex
    movf    0x44, W
    call    LCD_Write_Hex
    movf    0x45, W
    call    LCD_Write_Hex
    movf    0x46, W
    call    LCD_Write_Hex
    goto    $
  
Mul_8_24
    movff   0x40, 0x47
    movff   0x3f, 0x40
    call    Mul_8_16
    movff   0x45, 0x46
    movff   0x44, 0x45
    movff   0x43, 0x44
    movf    0x47, W
    mulwf   0x40
    movf    PRODL, W
    addwf   0x44, 1
    clrf    0x43
    movf    PRODH, W
    addwfc  0x43, 1
    return
 
Test_Mul_8_24
    ; Initialise 0x0a*0x3beb34
    movlw   0x0a
    movwf   0x3f
    movlw   0x3b
    movwf   0x40
    movlw   0xeb
    movwf   0x41
    movlw   0x34
    movwf   0x42
    ; Multiply them
    call    Mul_8_24
    ; Display result
    movf    0x43, W
    call    LCD_Write_Hex
    movf    0x44, W
    call    LCD_Write_Hex
    movf    0x45, W
    call    LCD_Write_Hex
    movf    0x46, W
    call    LCD_Write_Hex
 
Convert_hex_dec
    ;initialise object*0x418a
    movlw   0x41
    movwf   0x41
    movlw   0x8a
    movwf   0x42
    call    Mul_16_16 ; multiply them
    swapf   0x43 ; swap MSD
    movff   0x43, 0x49 ; move result to 0x49
    ; move remainder for next multiplication
    movff   0x44, 0x40
    movff   0x45, 0x41
    movff   0x46, 0x42
    ; set multiplier 0x0a
    movlw   0x0a
    movwf   0x3f
    call    Mul_8_24 ; multiply them
    ; add the MSD result to 0x49
    movf    0x43, W
    addwf   0x49, 1
    ; move remainder for next multiplication
    movff   0x44, 0x40
    movff   0x45, 0x41
    movff   0x46, 0x42
    call    Mul_8_24 ; multiply them
    swapf   0x43 ; swap MSD
    movff   0x43, 0x4a ; move result to 0x4a
    ; move remainder for next multiplication
    movff   0x44, 0x40
    movff   0x45, 0x41
    movff   0x46, 0x42
    call    Mul_8_24 ; multiply them
    movf    0x43, W
    addwf   0x4a, 1
    return

Test_convert
    ; initialise 0x04d2=1234
    movlw   0x0d
    movwf   0x3f
    movlw   0x80
    movwf   0x40
    call    Convert_hex_dec
    ; display them
    movf    0x49, W
    call    LCD_Write_Hex
    movf    0x4a, W
    call    LCD_Write_Hex
    return
    
    end