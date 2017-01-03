;Jeffrey Stewart
;ECE 033
;Section 112
;Program 3
;11/08/2014
;
;Digital Histogram
;Purpose: Counts the number of each digit found in a number given by user.
;
bdos        EQU     5H		
boot        EQU     0H
sprint      EQU     9H	;function 9 to print strings
cprint      EQU     2H	;function 2 to print characters
keyin       EQU     1H 	;function 1 to accept input
cr          EQU     0DH	;0DH is Carriage Return ASCII
newLine     EQU     0AH	;0AH is New Line ASCII
bkspce      EQU     08H	;08H is Backspace ASCII
space	    EQU	    20H	;20H is Space ASCII
;
;initialization/welcome
            ORG     100H		;Initialize Program
	    MVI	    A,0			;Moves 0 into A reg.
	    STA	    mem0		;initializes all counters to 0
	    STA     mem1
            STA	    mem2
	    STA     mem3
	    STA     mem4
	    STA	    mem5
	    STA	    mem6
	    STA	    mem7
	    STA	    mem8
	    STA	    mem9
            LXI     SP,SP0		;initialize Stack Pointer
            MVI     C,sprint		
            LXI     D,welcomeMessage	
            CALL    bdos		;Print welcomeMessage to user
;new line
            MVI     C,cprint                
            MVI     E,newLine                  
            CALL    bdos                
            MVI     E,cr
            CALL    bdos		;prints new line
;prompt message
            MVI     C,sprint
            LXI     D,promptMess
            CALL    bdos		;prompts user for input
;
;Take Character and Check if Number
nextInput:  MVI     C,keyin
            CALL    bdos
            CPI     cr			;compare input with CR
            JZ      endData		;if 0 (if CR) jump to endData
            CALL    checkNum		;calls subroutine checkNum
            JNC     nextInput		;jumps to nextInput if it wasn't a number
;					;if it was a number increment continue
;Check which number was given and increment corresponding counter
is0:        CPI     '0'			;compares number to 0>1>2>..>8>9
            JNZ     is1			;if nonzero jump to next number
            LDA	    mem0		;if it is 0, load mem0 into A
            INR     A			;increment A
            STA     mem0		;store incremented value back in mem0
            JMP     nextInput		;jump to nextInput
is1:        CPI     '1'			;repeat same steps as in is0
            JNZ     is2
            LDA	    mem1
            INR     A
            STA     mem1
            JMP     nextInput
is2:        CPI     '2'
            JNZ     is3
            LDA     mem2
            INR     A
            STA     mem2
            JMP     nextInput
is3:        CPI     '3'  
            JNZ     is4
            LDA     mem3
            INR     A
            STA     mem3
            JMP     nextInput            
is4:        CPI     '4'
            JNZ     is5
            LDA     mem4
            INR     A
            STA     mem4
            JMP     nextInput            
is5:        CPI     '5'
            JNZ     is6
            LDA     mem5
            INR     A
            STA     mem5
            JMP     nextInput            
is6:        CPI     '6'
            JNZ     is7
            LDA     mem6
            INR     A
            STA     mem6
            JMP     nextInput            
is7:        CPI     '7'
            JNZ     is8
            LDA     mem7
            INR     A
            STA     mem7
            JMP     nextInput            
is8:        CPI     '8'
            JNZ     is9
            LDA     mem8
            INR     A
            STA     mem8
            JMP     nextInput            
is9:        LDA     mem9
            INR     A
            STA     mem9
            JMP     nextInput
;
;Printing the histogram
endData:  
;new line            
            MVI     C,cprint                
            MVI     E,newLine                  
            CALL    bdos                
            MVI     E,cr
            CALL    bdos
;
;print0
            MVI     C,sprint		
            LXI     D,print0
            CALL    bdos		;print 0:
            LDA     mem0
            CALL    printX		;call printX subroutine
;
;print1     
            MVI     C,sprint		;repeat same steps as print2
            LXI     D,print1
            CALL    bdos
            LDA     mem1
            CALL    printX
;
;print2     
            MVI     C,sprint
            LXI     D,print2
            CALL    bdos
            LDA     mem2
            CALL    printX
;
;print3
            MVI     C,sprint
            LXI     D,print3
            CALL    bdos
            LDA     mem3
            CALL    printX
;
;print4
            MVI     C,sprint
            LXI     D,print4
            CALL    bdos
            LDA     mem4
            CALL    printX
;
;print5     
            MVI     C,sprint
            LXI     D,print5
            CALL    bdos
            LDA     mem5
            CALL    printX
;
;print6     
            MVI     C,sprint
            LXI     D,print6
            CALL    bdos
            LDA     mem6
            CALL    printX
;
;print7
            MVI     C,sprint
            LXI     D,print7
            CALL    bdos
            LDA     mem7
            CALL    printX
;
;print8     
            MVI     C,sprint
            LXI     D,print8
            CALL    bdos
            LDA     mem8
            CALL    printX
;
;print9 
            MVI     C,sprint
            LXI     D,print9
            CALL    bdos
            LDA     mem9
            CALL    printX
;
;ENDING
            MVI     C,sprint		;final message
            LXI     D,finish
            CALL    bdos
            JMP     boot		
;
;   Subroutines:
;--------------------------------------------------------------
;       checkNum:
;           input: ASCII code in A register, data memory addresses (mem1, mem2
;               mem3, mem4, mem5, mem6, mem7, mem8, mem9)
;           action: Will check if ASCII in A reg. is a number. If it is not then
;               then it will erase the ASCII from the screen. If it is, it will
;               leave it in A register.
;	        output: Same ASCII in A register, Set Carry flag if ASCII was a number
;           registers destroyed: Flags
;           subroutines used: None
;                   
checkNum:   CPI     '0'	    	;give no carry if higher
            JC      backspace	    	
            CPI     '9' + 1     ;give carry if lower
            RC			;if carry character is a number: return
backspace:  MVI     C,cprint	;character print
            MVI     E,bkspce	;backspace (moves pointer back 1 space)
            CALL    bdos	
	    MVI	    E,space	;space (clears character)
	    CALL    bdos
	    MVI     E,bkspce	;backspace(moves pointer back 1 space)
	    CALL    bdos
            RET			;return (with no carry)	
;
;--------------------------------------------------------------
;       printX:
;           input:  Number in A register
;           action: Will print number of X's equal to the number in A register
;           output: None
;           registers destroyed: A register
;           subroutines used: None
printX:     PUSH    D		;push registers that will be used
            PUSH    B
	    MVI     C,cprint 
	    MVI     E,'X'	;move X to E   
another:    CPI     0		;compare register A to 0 (counts number of X's)
            JZ      returnX	;if zero finish subroutine, and return to program
	    CALL    bdos	;print an X
            DCR     A		;decrease counter
            JMP     another	
returnX:    MVI     E,newLine   ;print new line               
            CALL    bdos                
            MVI     E,cr
            CALL    bdos
            POP     B		;return registers saved in stack
            POP     D
            RET			;return to main program
;
;
;            
welcomeMessage: DB  'The Digital Histogram',0AH,0DH,'$'
promptMess: DB      'Type about 40 digits: $'
;            
print0:     DB      0AH,0DH,'0: $'
print1:     DB      '1: $'
print2:     DB      '2: $'
print3:     DB      '3: $'
print4:     DB      '4: $'
print5:     DB      '5: $'
print6:     DB      '6: $'
print7:     DB      '7: $'
print8:     DB      '8: $'
print9:     DB      '9: $'
;
finish:     DB      0AH,0DH,'Thank you for using the Digital Histogram!$'
;            
;            
;            
;
mem0        EQU     $
	    DS	    1
mem1        EQU     $
	    DS 	    1
mem2        EQU     $
	    DS 	    1
mem3        EQU     $
	    DS 	    1
mem4        EQU     $
	    DS 	    1
mem5        EQU     $
	    DS 	    1
mem6        EQU     $
	    DS 	    1
mem7        EQU     $
	    DS 	    1
mem8        EQU     $
	    DS 	    1
mem9        EQU     $
	    DS 	    1
            DS      20
sp0         EQU     $
            END
;