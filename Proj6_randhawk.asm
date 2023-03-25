TITLE Designing Low-Level I/O Procedures     (Proj6_randhawk.asm)

; Author: Karnbir Randhawa
; Last Modified: 03/12/2023
; OSU email address: ONID@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6               Due Date: 03/19/2023
; Description: This program designs, implements, and calls low-level I/O procedures, and implements and uses macros

INCLUDE Irvine32.inc

; -------------------------------------------------
; mGetString macro: display prompt, get user input in the form of a string of digits. includes parameters for the 
; length of the string 

; preconditions: none
;
; postconditions: a pre-defined maximum string of digits entered by user are saved/stored 
;
; registers changed: none
; -------------------------------------------------
mGetString		MACRO  promptUserAddr, userInput, maxUserInp, lenUserInp
		push	ecx
		push	edx
		push	eax
		mov		edx, promptUserAddr
		call	WriteString	
		mov		edx, userInput
		mov		ecx, maxUserInp
		call	ReadString
		mov		lenUserInp, eax
		pop		eax
		pop		edx
		pop		ecx
ENDM

; -------------------------------------------------
; mDisplayString macro: print the string which is stored in a specified memory location
;
; preconditions: string address is terminated with null byte
;
; postconditions: string digits data stored is printed/displayed 
;
; registers changed: none
; -------------------------------------------------
mDisplayString	MACRO  stringAddr
		push	edx
		mov		edx, stringAddr
		call	WriteString	
		pop		edx
ENDM

; constants for ASCII and negative flag 
ZERO = 48
NINE = 57
NEGATIVE = 45
POSITIVE = 43
TRUE = 1
FALSE = 0

.data
;variables incl. strings and arrays 
progTitle1		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures.", 13,10,0
progTitle2		BYTE	"Written by Karnbir Randhawa.", 13,10,13,10,0
instruct1		BYTE	"Please provide 10 signed decimal integers.", 13,10,0
instruct2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 13,10,0
instruct3		BYTE	"After you have finished inputting the raw numbers I will display a list ", 13,10,0
instruct4		BYTE	"of the integers, their sum, and their average value.", 13,10,0
promptUser		BYTE	"Please enter a signed number: ", 0
errorMsg		BYTE	"You did not enter a signed number or your number was too big. Try again!", 13,10,0
displayMsg		BYTE	"You entered the following numbers:", 13,10,0
sumMsg			BYTE	"The sum of these numbers is: ", 0
avgMsg			BYTE	"The truncated average is: ", 0
goodbye			BYTE	"Thanks for playing!", 0
outputStr		BYTE	11 DUP(?)
sumStr			BYTE	50 DUP(?)
avgStr			BYTE	50 DUP(?)
numArray		SDWORD	10 DUP(?)
userInp			SDWORD	11 DUP(?) 
negativeFlag	DWORD	0
commaSpace		BYTE	", ", 0
sum				DWORD	?
avg				DWORD	?


.code

main PROC
; introduction --> display project information and instructions
		push	OFFSET		progTitle1
		push	OFFSET		progTitle2
		push	OFFSET		instruct1
		push	OFFSET		instruct2
		push	OFFSET		instruct3
		push	OFFSET		instruct4
		call	introduction
		call	Crlf

;readVal --> get input
		push	LENGTHOF	outputStr			; 32
		push	OFFSET		negativeFlag		; 28
		push	OFFSET		numArray			; 24
		push	OFFSET		userInp				; 20
		push	LENGTHOF	userInp				; 16
		push	OFFSET		promptUser			; 12
		push	OFFSET		errorMsg			; 8
		call	readVal

;displayArray --> display to user their valid input
		push	OFFSET		displayMsg			; 24
		push	OFFSET		commaSpace			; 20
		push	OFFSET		outputStr			; 16
		push	LENGTHOF	numArray			; 12
		push	OFFSET		numArray			; 8
		call	Crlf
		call	displayArray
		call	Crlf

;calculateSum 
		push	LENGTHOF	numArray			; 16
		push	OFFSET		sum					; 12
		push	OFFSET		numArray			; 8
		call	calculateSum

;displaySum
		mDisplayString	OFFSET	sumMsg
		push	OFFSET		sumStr
		push	sum
		call	writeVal

;calculateAvg
		push	LENGTHOF	numArray			; 16
		push	OFFSET		avg					; 12
		push	sum								; 8
		call	calculateAvg

;displayAvg
		call	Crlf
		mDisplayString	OFFSET	avgMsg
		push	OFFSET		avgStr
		push	avg
		call	writeVal

;sayGoodbye
		call	Crlf
		call	Crlf
		mDisplayString	OFFSET	goodbye
		call	Crlf

	exit
main ENDP

; -------------------------------------------------
; introduction proc: displays the program title information and instructions by invoking the mDisplayString macro and
; base + offset
;
; preconditions: none
;
; postconditions: none 
; -------------------------------------------------
introduction PROC
		push	ebp													; set up stack frame 
		mov		ebp, esp

		mDisplayString	[ebp+28]
		mDisplayString	[ebp+24]
		mDisplayString	[ebp+20]
		mDisplayString	[ebp+16]
		mDisplayString	[ebp+12]
		mDisplayString	[ebp+8]

		pop		ebp
		ret		24													; release 6*4 + return

introduction ENDP

; -------------------------------------------------
; readVal proc: reads inputs as string and convert to integers, while validating inputs; invokes both mGerString and 
; mDisplayString macros 
;
; preconditions: none
;
; postconditions: the valid string input is stored within the numArray, and the negative flag is changed 
; -------------------------------------------------
readVal PROC		
		push		ebp
		mov			ebp, esp										; set up stack frame

		pushad														; preserve registers 

		mov			edi, [ebp+24]									; set pointer to numArray
		mov			ecx, 10											; set up loop for valid entries 

		; validation not fully working - it will validate up to the max signed input, but does not throw an error 
		; (had issues with implementing the jo condition) 
		; it may also break if excessively large values are entered consecutively

			_prompt:
				mov			ebx, FALSE								; using ebx as negative flag, initialized for positive 
				mov			[ebp+28], ebx

				push		ecx
				mGetString	[ebp+12], [ebp+20], [ebp+32], [ebp+16]	; call mGetString macro
				mov			eax, [ebp+16]							; setting ecx to user input max
				mov			ecx, eax
				mov			esi, [ebp+20]
		
				_checkPlusOrMinus:	
					lodsb
					cmp		al, NEGATIVE							; check first byte for positive or negative sign
					je		_setNegativeFlag						; if entry starts with negative sign, set flag	
					cmp		al, POSITIVE
					je		_checkPlus								
					jmp		_checkValid								; if starts with positive sign, move on to checks

				_setNegativeFlag:
					mov		ebx, TRUE
					mov		[ebp + 28], ebx							; set negative flag 
					dec		ecx
					cld
					lodsb
					jmp		_checkValid

				_checkPlus:
					dec		ecx
					lodsb
					jmp		_checkValid

				_clearAndLoad:
					cld
					lodsb
					jmp		_checkValid

				_checkValid:
					cmp		al, ZERO
					jl		_giveError
					cmp		al, NINE
					jg		_giveError								; check for a valid input within the ASCII range 
					jmp		_conversion					

				_giveError:
					mDisplayString	[ebp+8]
					pop		ecx
					mov		ebx, 0									; restore register to account for error and reset
					mov		[edi], ebx			
					jmp		_prompt									
							
				_conversion:
					mov		ebx, [edi]

					push	eax
					push	ebx
						
							mov		eax, ebx						; move existing number and *10 for conversion
							mov		ebx, 10
							mul		ebx
							mov		[edi], eax

					pop		ebx
					pop		eax

					push	eax
					sub		al, ZERO								; converting to number 
					add		[edi], al
					jo		_giveError
					pop		eax

					dec		ecx
					cmp		ecx, 0
					jg		_clearAndLoad

						push	eax
						mov		eax, [ebp+28]
						cmp		eax, TRUE							; if flag is true, we negate it in _negative and put in array
						je		_negative
						jmp		_contLoop							; otherwise we pop and continue on checking entries 
						
					_negative:
						mov		eax, [edi]
						neg		eax
						mov		[edi], eax

					_contLoop:
						pop		eax
						jmp		_L1


				_L1:
					mov		eax, [edi]
					add		edi, 4								
					pop		ecx
					dec		ecx
					cmp		ecx, 0
					jg		_prompt

		popad														; restore registers and release arguments 

		pop		ebp
		ret		44

readVal	ENDP

; -------------------------------------------------
; writeVal proc: converts integer values to a string of digits; invokes the mDisplayString macro so that we can later 
; display the string of digits 
;
; preconditions: signed 32-bit integer is entered by user 
;
; postconditions: the outputStr is changed and negative values are negated 
; -------------------------------------------------
writeVal PROC
		push	ebp													; set up stack frame 
		mov		ebp, esp

		pushad														; preserve registers 

		mov			edi, [ebp+12]
		cld
		mov			eax, [ebp+8]									; eax gets the numArray							
			
		_checkNeg:
			cmp		eax, 0											; compare with 0 and set neg. if less
			jl		_negative
			jmp		_null											; go straight to pushing null byte 

		; correctly considers the value as negative but was unable to prepend it with '-' 

		_negative:	
			neg		eax

		_null:
			push	0												; pushing a null byte for terminator  

		_convert:
			mov		ebx, 10											; sign extending for idiv  
			cdq
			idiv	ebx
			add		edx, ZERO										; converting to ASCII 
			push	edx
			cmp		eax, 0											; compare quotient to zero to see if we're done
			je		_displayString
			jmp		_convert		
	
			_displayString:
				pop		eax
				stosb
				mDisplayString	[ebp+12]
				dec		edi				

				cmp		eax, 0
				je		_exit
				jmp		_displayString

			_exit:
				
		popad														; restore registers and release arguments 

		pop ebp
		ret 12

writeVal ENDP

; -------------------------------------------------
; displayArray proc: displays the list of 10 integers for the user 
;
; preconditions: the list array must be filled with the 10 integers to display 
;
; postconditions: none
; -------------------------------------------------
displayArray PROC

		push	ebp
		mov		ebp, esp

		pushad

		mDisplayString	[ebp+24]

		mov		edi, [ebp+8]											; edi to array 
		mov		ecx, [ebp+12]

		_displayArr:
			push	edi
			mov		eax, [edi]

			push	[ebp+16]
			push	eax
			call	writeVal											; use writeVal proc to write the value

			cmp		ecx, 1					
			je		_continueLoop
			mDisplayString	[ebp+20]
	
			_continueLoop:	
				add		edi, 4											; get next element
				loop	_displayArr
	
		popad															; restore registers and release arguments

		pop		ebp
		ret		20

displayArray ENDP

; -------------------------------------------------
; calculateSum proc: calculates the sum of all of the array values
;
; preconditions: needs the array filled with valid values
;
; postconditions: the sum is stored for display in the main proc 
;
; registers changed: none
; -------------------------------------------------
calculateSum PROC

		push	ebp
		mov		ebp, esp

		pushad

		mov		eax, 0
		mov		esi, [ebp+8]
		mov		ebx, [ebp+12]
		mov		ecx, [ebp+16]
			
			_sumLoop:
				add		eax, [esi]
				add		esi, 4												; get next value 
				loop	_sumLoop

				mov		[ebx], eax											; store the sum value 

		popad

		pop		ebp
		ret		12

calculateSum ENDP

; -------------------------------------------------
; calculateAvg proc: calculates the average of the valid integers in the array 
;
; preconditions: the sum needs to be stored, and list size initialized 
;
; postconditions: the average is stored for display in the main proc 
;
; registers changed: none
; -------------------------------------------------
calculateAvg PROC
		push	ebp
		mov		ebp, esp

		pushad

			mov		eax, [ebp+8]
			mov		ebx, [ebp+16]
			cdq
			idiv	ebx													; calculated average 

			mov		ebx, [ebp+12]
			mov		[ebx], eax											; store the average


		popad

		pop		ebp
		ret		12


calculateAvg ENDP

END main
