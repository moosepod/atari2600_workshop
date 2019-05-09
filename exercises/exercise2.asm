;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Exercise 2
; In this exercise you will cycle the background color per line
; and learn about WSYNC
;
; Written for use with 8bitworkshop.com. 
; Code included there and "Making Games For The Atari 2600"
; by Steven Hugg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; Header
;;;; Needed at top of all your source files  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

	processor 6502
	include "vcs.h"
	org  $f000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; GENERAL INIT
;;;; This code is necessary for initialization 
;;;; but you can ignore it until you get curious
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

Start	sei
	    cld
        ldx #$ff 
        txs 
        lda #0 ; 
        ldx #$ff
ZeroZP	sta $0,X
	    dex
        bne ZeroZP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NextFrame

        ;;; INSERT YOUR CODE BELOW THIS 
        stx COLUBK
        dex
        ;;; AND ABOVE THIS

	jmp NextFrame
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; Footer
;;;; Needed at bottom of all your source files  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	
    org $fffc
	.word Start
	.word Start
