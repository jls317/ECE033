;Jeffrey Stewart
;ECE 033
;Section 112
;Program 2
;10/24/2014
;
;
bdos    EQU 5H
boot    EQU 0H
print   EQU 9H
cprint  EQU 2H
keyin   EQU 1H
;
;				;letter=each letter that
				;user inputs in sentence
				;ABC are letters that user
				;wants to be capitalized
            org 100h
            lxi sp,sp0
            mvi c,print
            lxi d,startmess	;welcome message
            call bdos
Start:      mvi c,print
            lxi d,mess1		;prompt for letter	
            call bdos
	    lxi H,store		;initializes H-L to memory address
				;start of memory where letters will go
Input:      mvi c,keyin
            call bdos
            cpi 0DH		;compares letter to CR
	    mov M,A		;moves letter to memory
            jz upperABC		;if CR moves to ABC input 
            cpi 2EH		;compares letter to '.'
            jz upperABC		;if '.' moves to ABC input
            call convert	;this subroutine converts capital
				;letters to lowercase
   	    mov M,A		;moves converted letters to memory
   	    inx H		;increments HL for next letter to be added
            jmp Input		;repeat (will stop on CR or '.'	
upperABC:   mvi c,print
            lxi d,mess2		;prompt for ABC
            call bdos
Input2:     lxi H,store		;resets HL memory address
	    mvi c,keyin		;takes ABC
            call bdos
	    cpi 0DH		;checks for CR
	    jz finish		;if CR finishes taking inputs
            call convert	;converts any capital letters to lowercase
	    mov B,A		;moves ABC to B reg.
again:	    mov A,M		;takes first letter from memory
	    cpi 0DH		;compares letter to CR
	    jz Input2		;if CR gets next input ABC
	    cpi 2EH		;compares letter to '.'
	    jz Input2		;if '.' gets next input ABC
	    cmp B		;compares letter to ABC
	    jnz notSame		;zero flag not set = ABC isn't the same as letter
	    sui 32		;convert to cap ('a'-'A' =32)
notSame:    mov M,A		;move new letter back to memory
	    inx H		;increment HL for next letter
	    jmp again		;repeats for next letter
finish:	    lxi H,store		;resets HL to initial memory location
	    mvi c,print
	    lxi d,mess3		;Declares the output:
	    call bdos
printnext:  mov A,M		;gets first letter from memory 		
	    cpi 2EH		;compares to '.'
	    mvi c,cprint	;prints letter
	    mov E,A		
	    call bdos
	    jz final		;if '.' go to final
	    cpi 0DH		;compares letter to CR
	    jz final		;if CR go to final
	    inx H		;increment HL for next letter
	    jmp printnext	;gets next letter to print
final:	    mvi c,print
	    lxi d,finalmess	;Goodbye message
	    call bdos
	    jmp boot
;
;--------------------------------------------------------------
;   Subroutines:
;       convert:
;           input: ASCII code in A register
;           action: If ASCII is a capital letter, it will convert it 
;			to a lowercase letter
;	    output:ASCII code in A register
;           registers destroyed: flags
;           subroutines used: none
;
convert:    cpi 'A'	    	;compares char. to capital A
            jc return	    	;if carry it is outside of range
            cpi 5BH         	;compares char. to ASCII Z+1
            jnc return		;if no carry it is outside of range
            adi 32         	;32 = 'a'-'A' (makes ASCII in A reg. lowercase)
return:     ret			
;
;
startmess:  db  'Capitalize your favorite letters!',0AH,0DH,'$'
mess1:      db  'Enter a sentence (End with period or CR): $'
mess2:	    db  0AH,0DH,'Enter letters to be capitalized (max. 5): $'
mess3: 	    db  0AH,0DH,'Capitalized Sentence: $'
finalmess:  db  0AH,0DH,'I hope you enjoyed this display of my capabilities!'0AH,0DH,'$'
	    ds 5
store       equ $
            ds 80
sp0         equ $
            end
;
