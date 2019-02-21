SPI_MasterInit ; Set Clock edge to negative
    bcf SSP1STAT, CKP
    ; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
    movlw (1<<SSPEN)|(1<<CKE)|(0x02)
    movwf SSP1CON1
    ; SDO2 output; SCK2 output
    bcf TRISC, SDO1
    bcf TRISC, SCK1
    return
SPI_MasterTransmit ; Start transmission of data (held in W)
    movwf SSP1BUF
Wait_Transmit ; Wait for transmission to complete
    btfss PIR1, SSP1IF
    bra Wait_Transmit
    bcf PIR1, SSP1IF ; clear interrupt flag
    return


