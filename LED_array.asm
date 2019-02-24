#include p18f87k22.inc
    
    global	LED_array_setup, LED_array_update

LED_Array    code

LED_array_setup
    clrf    TRISE ;port E, upper one, follow 7654 3210
    clrf    TRISF ;port F, lower one, follow 3210 7654
    clrf    LATE
    clrf    LATF
    return
    
    
LED_array_update
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
       
LED_generate ; generate new pattern on top of LED array
    ; TODO: implementation
    

    END

