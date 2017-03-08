;*******************************************************************************
;Hockey Shift Bell
;June 1st, 2015
;status:  tested and working.
;Mark J. Jensen
;*******************************************************************************
    
    list    p=16f84a
    #include <p16f84a.inc>
    
; CONFIG
; __config 0xFFF0
 __CONFIG _FOSC_LP & _WDTE_OFF & _PWRTE_ON & _CP_OFF
    
    ;external osc. speed 32.768 kHz
    
    ;RA1	    gate pulse 1    ;o
    ;RA2	    gate pulse 2    ;o
    ;RA3-5	    unused	    ;o
    ;RB0	    interrupt	    ;i
    ;RB1	    test LED	    ;o
    ;RB2	    ringer pulse    ;o
    ;RB3	    DIP power	    ;o
    ;RB4-RB7	    DIP status	    ;i
    
    ;register assignment
    
dip	    equ	    20
n2	    equ	    21	    
time	    equ	    22
Ytmr	    equ	    30
Ztmr	    equ	    31
Rtmr	    equ	    32
Rseq	    equ	    33
Stmr	    equ	    34
	
    
    org 0000
    goto intport
    
    org 0004
    goto ISR
    
    org 0010
intport
    bsf status,5
    movlw B'00000000'
    movwf trisa
    movlw B'11110001'
    movwf trisb
    bcf status,5
    
    bcf option_reg,intedg
    bcf status,rp0
    movlw B'10010000'
    movwf intcon
    
    call test
    
    call ring
    
    call ZZZ	    ;settle
    
    clrf portb
    clrf porta
    clrf dip
    clrf n2
    clrf time
    clrf Ytmr
    clrf Ztmr
    
cycle			;counting starts here  
    
    call readdip
    
block
    movlw 0x62		;Ytmr = 2 sec
    movwf Ytmr    
    bsf portb,1
    call YYY
    decf time,f
    btfsc status,z
    goto out
    
    movlw 0x62		;Ytmr = 2 sec
    movwf Ytmr 
    bcf portb,1
    call YYY
    decf time,f
    btfss status,z
    goto block

    
out    
    call ring
    
    call ZZZ		;settle
    
    goto cycle
    
;all subroutines
    
ring
    movlw 0x28		;loop 40x (2 sec)
    movwf Rseq
    
R1  bsf porta,0
    call RRR
    bcf porta,0
    call SSS
    bsf porta,1
    call RRR
    bcf porta,1
    call SSS
    decfsz Rseq
    goto R1
    clrf porta
    return

    
ISR call readdip
    call ring
    call ZZZ		    ;settle
    bcf intcon,intf
    retfie
    
readdip
    clrf dip
    clrw
    clrc
    clrf portb
    clrf time
    movlw 0x08
    movwf portb		    ;DIP power on
    nop
    nop
    btfsc portb,7
    bsf dip,0
    rlf dip,f
    btfsc portb,6
    bsf dip,0
    rlf dip,f
    btfsc portb,5
    bsf dip,0
    rlf dip,f
    btfsc portb,4
    bsf dip,0
    bcf portb,3		    ;DIP power off
    
math
    movlw 0x0F
    movwf n2
    clrw
    clrc
    btfsc n2,0
    addwf dip,w
    rlf dip,f
    btfsc n2,1
    addwf dip,w
    rlf dip,f
    btfsc n2,2
    addwf dip,w
    rlf dip,f
    btfsc n2,3
    addwf dip,w
    movwf time
    rrf time,f		    ;divide by 2
    movlw 0x1E		    ;load 30
    addwf time,f	    ;add 30 to time and store in "time"
    return
    
    ;2 sec delay
    
YYY decf Ytmr,f
    btfsc status,z
    return
    call ZZZ
    goto YYY
    
ZZZ movlw 0x35		    ;makes Ztmr 20ms
    movwf Ztmr
ZZ  decfsz Ztmr,f
    goto ZZ
    return
    
RRR movlw 0x3D		    ;R tmr = 23 ms
    movwf Rtmr
RR  decfsz Rtmr,f
    goto RR
    return
    
SSS movlw 0x04		    ;S tmr = 2ms
    movwf Stmr
SS  decfsz Stmr,f
    goto SS
    return
    
test
    bsf portb,1
    movlw 0x40
    movwf Ytmr
    call YYY
    bcf portb,1
    movlw 0x40
    movwf Ytmr
    call YYY
    bsf portb,1
    movlw 0x40
    movwf Ytmr
    call YYY
    bcf portb,1
    return
    
    
spit			;special diagnostic tool
    bcf portb,1		;word start signal
    bsf portb,1
    bcf portb,1
    bsf portb,1
    
    bcf portb,1		;clear LED
    btfsc time,7	;test bit 7
    bsf portb,1		;LED high
    call ZZZ
    bcf portb,1		;clear LED
    btfsc time,6	;test bit 6
    bsf portb,1		;LED high
    call ZZZ
    bcf portb,1		;clear LED
    btfsc time,5	;test bit 5
    bsf portb,1		;LED high
    call ZZZ
    bcf portb,1		;clear LED
    btfsc time,4	;test bit 4
    bsf portb,1		;LED high
    call ZZZ
    bcf portb,1		;clear LED
    btfsc time,3	;test bit 3
    bsf portb,1		;LED high
    call ZZZ
    bcf portb,1		;clear LED
    btfsc time,2	;test bit 2
    bsf portb,1		;LED high
    call ZZZ
    bcf portb,1		;clear LED
    btfsc time,1	;test bit 1
    bsf portb,1		;LED high
    call ZZZ
    bcf portb,1		;clear LED
    btfsc time,0	;test bit 0
    bsf portb,1		;LED high
    call ZZZ
    bcf portb,1
    return
    
    end
    
    
    
    
    
    


