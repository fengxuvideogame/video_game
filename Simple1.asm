	#include p18f87k22.inc

	extern	LED_array_setup
	extern	high_int_setup
	

rst	code	0    ; reset vector
	goto	setup
	
main	code
	; *******  Programme FLASH read Setup Code ***********************
setup	
	call	LED_array_setup
	call	high_int_setup
	goto	$
	
	end
