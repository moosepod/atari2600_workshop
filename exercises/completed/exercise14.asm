;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Exercise 14
; Use second sound channel and change colors 
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
	include "xmacro.h"

;;;;;;;;;;;;;;;;;; VARIABLE SEGMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;

	seg.u Variables
    	org $80

    	;;; INSERT YOUR VARIABLES BELOW THIS 
PlayerYPos  .byte
PlayerXPos  .byte
PlayerXPosOld  .byte
    	;;; AND ABOVE THIS

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

    ;;; INITIALIZE YOUR VARIABLES BELOW THIS 
    lda #80
    sta PlayerYPos
    lda #71
    sta PlayerXPos
    ;;; AND ABOVE THIS


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
        
        ;;; REPLACE BETWEEN CODE HERE
        TIMER_SETUP 37
        ;;; AND HERE
        lda PlayerXPos
        ldx #0
        jsr SetHorizPos
        sta WSYNC
        sta HMOVE
        
        ; we will use our final two vblank line to setup
        ; any drawing                
        lda #$ff
        sta PF0
        sta PF1
        sta PF2
        sta WSYNC
        
        ;;; INSERT BODE BELOW CODE HERE
        TIMER_WAIT
        ;;; AND ABOVE HERE
        
        ;;; now turn beam back on and draw 192 lines
        lda #0
        sta VBLANK

        ;;; Draw 10 lines
        ldx #10
ScanLoopTop
	sta WSYNC
        dex
        bne ScanLoopTop
        
        ;; Setup to draw the sidebar playfield (reflected)
        lda #$01
        sta CTRLPF
	lda #$30
	sta PF0
        lda #0
        sta PF1
        sta PF2
        
        ;; Skip until player top
        ldx PlayerYPos
ScanLoopMiddleTop
	sta WSYNC
        dex
        bne ScanLoopMiddleTop
        
        lda #$32
        sta COLUP0

        ;;; Draw 8 lines
        ldx #8
ScanLoopDrawSprite
	sta WSYNC
        lda ButtonsFrame0,x
        sta GRP0
        lda ButtonsColorFrame0,x
        sta COLUP0
        dex
        bne ScanLoopDrawSprite
        
        sta WSYNC
        
        lda #0
        sta GRP0
        
        ;;; Calculate and draw remaining lines
        lda #192
        sbc #10  ; top 
        sbc #10  ; bottom 
        sbc #8   ; sprite
        sbc PlayerYPos
        tax
ScanLoopMiddleBottom
	sta WSYNC
        dex
        bne ScanLoopMiddleBottom
        
        ;; Now draw PF for the last 10 lines
        lda #$ff
        sta PF0
        sta PF1
        sta PF2
        
        ;;; Draw another 10 lines
        ldx #10
ScanLoopBottom
	sta WSYNC
        dex
        bne ScanLoopBottom        
        
        ; now draw 25 lines of overscan after
        ; turning beam off again
        lda #2
	sta VBLANK 
        ldx #25
OverscanLoop 
	sta WSYNC
        dex
        bne OverscanLoop

        ; Use a vblank line to check for bounds 
        ;;; Up/down 
        lda PlayerYPos
        cmp #2
        bcs .TopBoundsCheck
        ldx #2
        jmp .SkipMoveUp
.TopBoundsCheck  
        lda PlayerYPos
	cmp #162
        bcc .JoystickCheck
        ldx #161
        jmp .SkipMoveUp
        ;;; AND ABOVE HERE
.JoystickCheck
	ldx PlayerYPos
        lda #$10
        bit SWCHA
        bne .SkipMoveDown
        dex
.SkipMoveDown
        lda #$20
	bit SWCHA
        bne .SkipMoveUp
        inx
.SkipMoveUp
	stx PlayerYPos
	sta WSYNC
        clc
        
        ;;; Left/right
        ;;; Colision detection
        
        ;;; INSERT HERE
        lda PlayerXPos
        bit CXP0FB
        bpl .NoCollision
	ldx PlayerXPosOld
        jmp .SkipMoveRight
.NoCollision
        ;;; ABOVE HERE
        ldx PlayerXPos
        stx PlayerXPosOld
        lda #$80
        bit SWCHA
        bne .SkipMoveLeft
        inx
.SkipMoveLeft
	lda #$40
        bit SWCHA
        bne .SkipMoveRight
        dex
.SkipMoveRight
	stx PlayerXPos
	sta WSYNC
        sta CXCLR
        clc
        
	sta WSYNC
        
        ;;; Sound check
	bit INPT4
        bmi .ButtonNotPressed
        ; channel 0
        lda #5
        sta AUDV0
        lda #13
        sta AUDC0
        lda PlayerYPos
        lsr 
        lsr 
        lsr 
        sta AUDF0
        ; channel 1
        lda #3
        sta AUDV1
        lda #1
        sta AUDC1
        lda PlayerXPos
        lsr 
        lsr 
        lsr 
        sta AUDF1
        ; playfield
        lda PlayerXPos
        sta COLUPF
        ; background
        lda #44
        sta COLUBK
        jmp .ButtonPressedDone
.ButtonNotPressed
	lda #0
        sta AUDV0
        sta AUDV1
        sta COLUBK
        lda #$80
        sta COLUPF
.ButtonPressedDone
    ;;; INSERT CODE ABOVE HERE
        
        sta WSYNC

        ;;; Now we've drawn our
        ;;; 3 VSYNC lines
        ;;; 37 VBLANK lines
        ;;; 192 scan lines
        ;;; 30 overscan lines

	jmp NextFrame 
        
;; Fine horizontal positioning
;; From Making Games for the Atari 2600
;; Note it will call WSYNC to start
;; A should have desired X coord
;; X is (0) player 0 (1) player 1 (2) missile 0
;; (3) missile 1 (4) ball
SetHorizPos subroutine
	sta WSYNC
        sec
.DivideLoop
	sbc #15
        bcs .DivideLoop ; loop until we go <0
        eor #7
        asl
        asl
        asl
        asl
        sta HMP0,x ; set fine offset
        sta RESP0,x ; set coarse
        rts
        
;---Graphics Data from PlayerPal 2600---

ButtonsFrame0
        .byte #%00000000;$30
        .byte #%00011000;$30
        .byte #%00011000;$30
        .byte #%00000000;$74
        .byte #%01100110;$74
        .byte #%01100110;$74
        .byte #%00000000;$74
        .byte #%00011000;$B4
        .byte #%00011000;$B4
;---End Graphics Data---


;---Color Data from PlayerPal 2600---

ButtonsColorFrame0
	.byte #0
        .byte #$30;
        .byte #$30; 
        .byte #$74;
        .byte #$74;
        .byte #$74;
        .byte #$74;
        .byte #$B4;
        .byte #$B4;
;---End Color Data---



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; Footer
;;;; Needed at bottom of all your source files  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	
    org $fffc
	.word Start
	.word Start
 