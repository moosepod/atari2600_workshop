;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Exercise 6
; In this exercise you will draw side borders using 
; playfield graphics
;
; Written for use with 8bitworkshop.com. 
; Code included there and "Making Games For The Atari 2600"
; by Steven Hugg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; Header
;;;; Needed at top of all your source files  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    processor 6502
    include "vcs.h"

;;;;;;;;;;;;;;;;;; VARIABLE SEGMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg.u Variables
        org $80

;;;;;;;;;;;;;;;;;; CODE SEGMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg Code
    org $f000

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
    ; next two lines turn off beam
    lda #2
        sta VBLANK 
        ; now three lines of vsync per spec
        sta VSYNC  
        sta WSYNC
        sta WSYNC
        sta WSYNC
        
        ; turn off vsync
        lda #0
        sta VSYNC 
        
        ; now loop through 36 vertical blank lines
        ldx #36
VBlankLoop
    sta WSYNC
        dex
        bne VBlankLoop
        
        ; we will use our final vblank line to setup
        ; any drawing                
        lda #$ff
        sta PF0
        sta PF1
        sta PF2
        lda #$80
        sta COLUPF
        sta WSYNC
    
        ;;; now turn beam back on and draw 192 lines
        lda #0
        sta VBLANK

        ;;; Draw 10 lines
        ldx #10
ScanLoopTop
    sta WSYNC
        dex
        bne ScanLoopTop
        
        ;;; REPLACE CODE IN HERE 
        lda $01
        sta CTRLPF
	lda $10
	sta PF0
        lda #0
        sta PF1
        sta PF2
        ;;; AND ABOVE THIS

        ;;; Draw 172 lines
        ldx #172
ScanLoopMiddle
    sta WSYNC
        dex
        bne ScanLoopMiddle
        
        ;; Now draw PF for the last 10 lines
        lda #$ff
        sta PF0
        sta PF1
        sta PF2
        lda #$80
        sta COLUPF
        
        ;;; Draw another 10 lines
        ldx #10
ScanLoopBottom
    sta WSYNC
        dex
        bne ScanLoopBottom        
        
        ;;; Add up the above and we're at 192
        
        ; now draw 30 lines of overscan after
        ; turning beam off again
        lda #2
        sta VBLANK 
        ldx #30
OverscanLoop
    sta WSYNC
        dex 
        bne OverscanLoop
                
        ;;; Now we've drawn our
        ;;; 3 VSYNC lines
        ;;; 37 VBLANK lines
        ;;; 192 scan lines
        ;;; 30 overscan lines

    jmp NextFrame
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; Footer
;;;; Needed at bottom of all your source files  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	
    org $fffc
    .word Start
    .word Start
