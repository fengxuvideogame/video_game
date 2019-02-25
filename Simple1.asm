	#include p18f87k22.inc

	extern	kpd_ch_setup
	extern	LED_array_setup
	extern	high_int_setup
	extern	LCD_setup, wlcm_display
	

rst	code	0    ; reset vector
	goto	setup
	
main	code
	; *******  Programme FLASH read Setup Code ***********************
setup	
	call	LCD_setup
	call	wlcm_display
	call	kpd_ch_setup
	call	LED_array_setup
	call	high_int_setup
	goto	$
	
	end
