;Jeffrey Stewart
;ECE 033
;Section 112
;Program 4
;11/23/2014
;
;
;Purpose: Add or subtract to 16bit numbers using 2s complement
;         based on the input of the user. 
;
BDOS        EQU     5H		
BOOT        EQU     0H
SPRINT      EQU     9H
CPRINT      EQU     2H
KEYIN       EQU     1H 
CR          EQU     0DH
NEWLINE     EQU     0AH
BKSPCE      EQU     08H
EQUALS      EQU     3DH
MINUS       EQU     2DH
PLUS        EQU     2BH
SPACE	    EQU	    20H
;
;initialization/welcome message
            ORG     100H
            LXI     SP,SP0
            MVI     C,SPRINT
            LXI     D,welcomeMessage	
            CALL    BDOS

;print welcome message and initialize counters
NEXTCALC:   MVI     C,SPRINT
            LXI     D,NEXTCALCMESS	
            CALL    BDOS
	    MVI     D,0			
	    MVI     E,0
            MVI     H,0
            MVI     L,0

INPUT1:     MVI     C,KEYIN
            CALL    BDOS	 ;set to receive input
            CPI     CR
            JZ      TERMINATE	 ;if CR terminate program
	    CPI     PLUS	 
	    JZ      ADDITION 	 ;if + jump to addition
            CPI     MINUS
            JZ      SUBTRACTION  ;if - jump to subtraction
            CALL    ISNUM	 ;checks for numbers deletes and
					;disregards other symbols
	    JC      INPUT1	
	    CALL    MULT10	 ;multiply by 10 to set up for next value
	    ADD     L		 ;add L to next value
            MOV     L,A		 ;move new number back to L
            JMP     INPUT1	 ;jump back to receive next input

ADDITION:   MOV     B,A		 ;move A (+) to B for later
            MOV     E,L		 ;move L to E
	    MOV     D,H		 ;move H to D
            MVI     H,0		 ;reset H and L
            MVI     L,0
	    JMP     INPUT2	 ;receive next number 

SUBTRACTION: MOV     B,A	 ;move A (-) to B for later
	     MOV     E,L
	     MOV     D,H
             MVI     H,0
             MVI     L,0
             JMP     INPUT2	 ;same as "Addition:"	    
	    
INPUT2:     MVI     C,KEYIN	 
            CALL    BDOS         ;take next input
            CPI     CR 
            JZ      TERMINATE    ;look for CR and terminate
	    CPI     EQUALS
	    JZ      COMPUTE	 ;when (=) given jump to compute
            CALL    ISNUM	 ;check for number and disregard
					;other symbols
	    JC      INPUT2	 
	    CALL    MULT10	 ;multiply by 10 to set up for next value
	    ADD     L		 ;add L to next value
	    MOV     L,A	         ;move new number back to L
            JMP     INPUT2	 ;receive next number

COMPUTE:    PUSH    D		 ;push D (first number to stack)
	    MOV     D,H		 ;move H and L to D and E respectively
            MOV     E,L
            POP     H		 ;pop (first number) to HL
	    MOV     A,B		 ;moves stored operator to A
	    CPI     PLUS	 ;determines add/subtract based on +/-
	    JZ      ADD1
            CPI     MINUS
	    JZ      SUBTRACT1
ADD1:	    DAD     D		 ;add both 16bit numbers 
	    CALL    PRINT	 ;call subroutine print to print 16bit answer

SUBTRACT1:  MOV     A,L		 ;moves lower bit (L) to A
            SUB     E		 ;subtract E from A
            MOV     L,A		 ;move lower bit answer back to L
 	    MOV     A,H		 ;repeat for upper bit H
            SBB     D		 ;subtract with carry
            MOV     H,A		 ;move upper bit answer back to H
	    CALL    PRINT	 ;call subroutine print to print 16bit answer
	    JMP     NEXTCALC	 ;jump back to beginning for next calculation


OVERFLOW:   LXI     D, OVERFLOWMESS
	    MVI     C, SPRINT
            CALL    BDOS
            JMP     NEXTCALC

TERMINATE:  LXI	    D, FINALMESS
	    MVI     C, SPRINT
            CALL    BDOS	
            JMP     BOOT

;
;   Subroutines:
;--------------------------------------------------------------
;       ISNUM:
;           input: ASCII code in A register
;           action: Will check if ASCII in A reg. is a number. If it is a number it will
;               subtract 30H to convert ASCII to a number. If it is not a number or '+','-',
;               or '=' then then it will erase the ASCII from the screen. If it is not a number
;               the carry flag will be set.
;	        output: Same ASCII in A register or equivalent number (from ASCII to hex),
;               if used carry flag will be 0
;           registers destroyed: A register is changed, flags
;           subroutines used: None
;                   
ISNUM:      CPI     '0'	    	;give no carry if higher
            JC      BACKSPACE	    	
            CPI     '9' + 1     ;give carry if lower
            JNC     BACKSPACE
            SUI     30H
            STC
            CMC
            RET
BACKSPACE:  CPI     PLUS
            RZ
            CPI     MINUS
            RZ 
            CPI     EQUALS
            RZ
            PUSH    B
            PUSH    D
            MVI     C, CPRINT	;character print
            MVI     E, BKSPCE	;backspace (moves pointer back 1 space)
            CALL    BDOS	
	    MVI	    E,SPACE	;space (clears character)
	    CALL    BDOS
	    MVI     E,BKSPCE	;backspace(moves pointer back 1 space)
	    CALL    BDOS
            STC
            POP     D
            POP     B
            RET
;--------------------------------------------------------------------------
;       MULT10:
;           input: 16bit number in HL pair
;           action: Will multiply the number in HL pair by 10 (to next place value)
;	    output: Multiplied number will be in HL pair
;           registers destroyed: None
;           subroutines used: None
;           
MULT10:     PUSH    D	;push D E pair to stack
	    DAD     H	;doubles H (Hx2)
	    PUSH    H	;push Hx2
            DAD     H	;doubles H (Hx4)
	    DAD     H   ;doubles H (Hx8)
	    POP     D	;pop Hx2
            DAD     D	;adds Hx2 to Hx8 (Hx10)
            POP     D	;pops D E pair back to D
            RET
;--------------------------------------------------------------------------
;	PRINT:
;	    input: 16bit number in HL pair
;  	    purpose: Prints out 16bit number in HL pair
;
PRINT:	    LXI	    D,TENTHOUSAND	;load 10000 in D E pair
	    MVI     B,0			;initialize counter
AGAIN4:	    MOV	    A,L			;moves lower bit L to A
	    SUB     E			;subtracts lower bit E
	    MOV     L,A			;moves answer back to L
            MOV     A,H			;does same for upper bit
            SBB     D			;sub with carry
	    MOV     H,A			;move answer back to H
            INR     B			;increment B (counter)
	    JNC	    AGAIN4		;if no carry repeat
NEXT3:	    MVI     C, CPRINT		;print out counter
	    MOV     A,B			;move counter to a
	    DCR     A			;decrease counter by 1

	  ;my attempt at extra credit
	  ;  CPI     4			;checks for overflow
	  ;  JNC     OVERFLOW		;print overflow


	    CPI     0			;if 0
            JZ      INITIAL3		;don't print and go to next
	    ADI     30H			;add 30 to get ASCII
            PUSH    D			;push DE pair on stack
            MOV     E,A			;move A to E to print
            CALL    BDOS	
            POP     D			;move DE pair back to DE
INITIAL3:   DAD     D			;add D back since it went negative
            LXI     D,ONETHOUSAND	;repeat for 1000
	    MVI     B,0		
AGAIN3:     MOV	    A,L
	    SUB     E
	    MOV     L,A
            MOV     A,H
            SBB     D
	    MOV     H,A
            INR     B
	    JNC	    AGAIN3
NEXT2:      MVI     C, CPRINT
	    MOV     A,B
	    DCR     A
	    CPI     0
            JZ      INITIAL2
	    ADI     30H
            PUSH    D
            MOV     E,A
            CALL    BDOS
            POP     D
INITIAL2:   DAD     D
	    LXI     D,ONEHUNDO		;repeat for 100
	    MVI     B,0
AGAIN2:     MOV	    A,L
	    SUB     E
	    MOV     L,A
            MOV     A,H
            SBB     D
	    MOV     H,A
            INR     B
	    JNC	    AGAIN2
NEXT1:      MVI     C, CPRINT
	    MOV     A,B
	    DCR     A
	    CPI     0
            JZ      INITIAL1
	    ADI     30H
            PUSH    D
            MOV     E,A
            CALL    BDOS
            POP     D
INITIAL1:   DAD     D
	    LXI     D,TEN		;repeat for 10
	    MVI     B,0
AGAIN1:     MOV	    A,L
	    SUB     E
	    MOV     L,A
            MOV     A,H
            SBB     D
	    MOV     H,A
            INR     B
	    JNC	    AGAIN1
NEXT:       MOV     E,L			;uses last digits as 1s
	    ADI     30H			;adds 30 for ASCII
	    MVI     C, CPRINT		;print
            CALL    BDOS
	    RET
;-------------------------------------------------------------






welcomeMessage:     DB  'Type an addition or subtraction problem! Hit <CR> to end!$'
NEXTCALCMESS:	    DB	0AH,0DH,'>>>$'
FINALMESS:	    DB	0AH,0DH,'Thank you for using my wonderfully broken calculator!$'
OVERFLOWMESS:       DB  '**Overflow**$'
TENTHOUSAND:	    DW  2710H	
ONETHOUSAND:	    DW  3E8H
ONEHUNDO:	    DW  64H
TEN:                DW  0AH
	            DS  2
OP 		    EQU $
		    DS  40
SP0                 EQU $
                    END