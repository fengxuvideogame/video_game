#include p18f87k22.inc
    
    global	KBD_Ch_Setup, Read_Columns, Read_Rows, Convert_Ascii
    extern	LCD_delay_x4us
   
acs0	udata_acs
temp_byte   res	1
zero_byte   res	1
result_byte res	1 ; byte for storing ascii result

LED_Array    code

LED_Array_Setup
    clrf    TRISE ;port E, upper one, follow 7654 3210
    clrf    TRISF ;port F, lower one, follow 3210 7654
    clrf    LATE
    clrf    LATF
    return
    
    
LED_Array_update
    ;read 7654 from TRISE
    swapf   PORTF,1,0 ;swap for port F, saved in port F
    movlw   0xf0 ;set W for AND operation
    andwf   PORTF,1,0 ;make port F only 7654, saved to port F
    movlw   0x0f; set W for AND operation
    andwf   PORTE,0,0 ;save in W, only 3210 of Port E
    xorwf   PORTF,1,0 ; xor W to port F, saved in port F
    swapf   PORTE,1,0 ; swap for port E, saved in port E
    movlw   0x0f ;set W for AND operation
    andwf   PORTE,1,0 ;make port E only 3210, saved to port E
    call    LED_generate ;new input for port E, expect W to be xxxx0000
    xorwf   PORTE,1,0 ; xor W to port E, saved in port E
    return
    
    
    
    

    END

