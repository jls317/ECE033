;Jeffrey Stewart
;ECE 033
;10/15/2014
;
;Character Type Counter
;Counts number of letters, numbers, and symbols that 
;   are typed.
;
bdos    EQU 5H
boot    EQU 0H
print   EQU 9H
cprint  EQU 2H
keyin   EQU 1H
        
        org 100h               ;starting address for program   
        lxi sp,stkpt           ;stack pointer start at address, stkpt
        mvi c,print            ;print function number in register c
        lxi d,startmess        ;initial message address in d
        call bdos              ;call system for printfunction
Start:  call newline	       ;call newline subroutine
	mvi c,print            ;print function number in register c
        lxi d,mess1            ;load starting message in register d
        call bdos              ;call system for print function
	mvi H,30H	       ;set H, B, and L registers to 30H
	mvi B,30H		;or ASCII '0'
	mvi L,30H
In:     mvi c,keyin            ;char input function number in reg. c
	call bdos	       ;call system to read input
        cpi 2EH                ;compares register A (input) with ASCII of .
        jz period              ;jump on zero
        cpi 0DH                ;compares register A (input) with 0DH (ASCII of CR)
        jz CR		       ;if zero flag is set jump CR
        call compareabc        ;call compareabc subroutine    
        jc abc   	       ;if there is a carry jump to increment H (letter)
        call comparenum	       ;call comparenum subroutine              
        jc num		       ;if there is a carry jump to increment B (number)
        jmp sym		       ;jump to increment L (symbol)
abc:    inr H                  ;Increment register H by 1
        jmp In                 ;jump In: looks for next char
num:    inr B                  ;Increment register B by 1
        jmp In		       ;jump In: looks for next char
sym:    inr L                  ;Increment register L by 1
        jmp In		       ;jump In: looks for next char
period: inr L
	call out               ;call out subroutine (print out statement) 
        jmp Start              ;restart program
CR:     call out               ;call out subroutine
        jmp boot               ;end program
;
;
;Subroutines:
;---------------------------------------------------------------
;       compareabc:
;           input   : ASCII code in register A
;           action  : compares A register to range of ASCII      
;   			codes(corresponding to letters)
;                     if A is letter        : carry flag is set
;                     if A is not a letter  : carry flag is not set
;           registers destroyed: flags
;           subroutines used: none
;
compareabc: cpi 41H           ;compares input ASCII to lower limit 41H
            jc notabc         ;jump if there is a carry to notabc (not a letter)
            cpi 7BH           ;compares input ASCII to upper limit 7B
            jnc notabc        ;jump if no carry to notabc (not a letter)
            cpi 5BH           ;compares A with 5BH (lower end of mid range) 
            jc carry          ;if there is a carry, jump to carry
            jnc nocarry       ;if no carry, jump to nocarry
carry:      cpi 60H           ;compare A with 6AH (upper end of mid range)
            jnc notabc        ;jump if no carry to notabc    
            jc abc1           ;jump if carry to abc
nocarry:    cpi 60H           ;compare A with 6AH (upper end of mid range)
            jnc abc1          ;jump no carry to abc
            jc notabc         ;jump carry to notabc
notabc:     stc               ;sets carry flag to 1
            cmc               ;complement carry flag (0)
            jmp abcpopret     ;return to main program
abc1:        stc              ;sets carry flag to 1
            jmp abcpopret     ;return to main program
abcpopret:  ret
;---------------------------------------------------------------
;       comparenum:
;           input   : ASCII code in register A
;           action  : compares A register to range of ASCII codes(corresponding to numbers)
;                     if A is number    : carry flag is set
;                     if A is not number: carry flag is not set
;           registers destroyed: flags
;           subroutines used: none
;
comparenum: cpi 30H           ;compares H to A
            jc notnum         ;jump carry to notnum (not a number)
            cpi 3AH           ;compares L to A
            jnc notnum        ;jump if no carry to notnum
            jmp num           ;jump to num (is a number)
notnum:     stc               ;sets carry to 1   
            cmc               ;complement carry flag
            jmp numpopret     ;return to main program
num:        stc               ;sets carry to 1
            jmp numpopret     ;return to main program
numpopret:  ret
;---------------------------------------------------------------
;       out:
;           input   : Registers B, H, L (counters)
;           action  : Displays number of letters (H), numbers 
;			(B), and symbols(L)
;           registers destroyed: none
;           subroutines used: newline
;
out:        push PSW	      ;pushes contents of A and Flags to Stack
            mov A,B           ;moves contents of B to A
	    push B            ;pushes content of B-C to stack
	    call newline      ;call subroutine newline
            mvi c,print       ;function number for printing a string in C register
            lxi d,messabc     ;puts location of messageabc in reg. d
            call bdos         ;call system
            mvi c,cprint      ;function number for printing a character in reg. c
            mov E,H           ;moves contents of H to E to be printed
            call bdos         ;call system
            call newline      ;call subroutine newline
            mvi c,print       ;number for printing string
            lxi d,messnum     ;load location of messnum in reg. d
            call bdos         ;call system
            mvi c,cprint      ;function number for printing a char. in reg. c
            mov E,B           ;moves contents of B to E to be printed
            call bdos         ;call system
            call newline      ;call subroutine newline
            mvi c,print       ;number for printing string in reg. c
            lxi d,messsym     ;loads loction of messsym to reg. d
            call bdos         ;call system
            mvi c,cprint      ;function number for printing a char. in reg. c
            mov E,L           ;moves contents of L to E to be printed
            call bdos         ;call system
	    call newline      ;call newline subroutine
            pop B             ;pop stack into B-C
	    pop PSW	      ;pop stack into A and Flags
            ret               ;returns to program
;---------------------------------------------------------------
;       newline:
;           input   : none
;           action  : Prints new line to screen
;           registers destroyed: none
;           subroutines used: none
;
newline:    push B            ;pushes content of B-C to stack
	    push D	      ;pushes contents of D-E to stack
            mvi c,cprint      ;function number for printing a char. in reg. c
            mvi e,0AH         ;integer 0A H to reg. e (new line ASCII)
            call bdos         ;call system
            mvi e,0DH         ;integer 0D H to reg. e (Carriage Return ASCII)
            call bdos         ;call system
	    pop D	      ;pop stack into D-E
            pop B             ;pop stack into B-C
            ret               ;return to program
;---------------------------------------------------------------
startmess:  db   'Type a sentence to parse (end with a period or a <CR>)$'
mess1:      db   'Go ahead, try me (type <CR> to end):$'
messabc:    db   'Number of letters you typed: $'
messnum:    db   'Number of digits you typed : $'
messsym:    db   'Other characters you typed : $'
            ds   75
stkpt       equ  $
            end