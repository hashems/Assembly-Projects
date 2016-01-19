TITLE Composite Numbers		(CompositeSequenceGenerator.asm)

; Program Filename: CompositeSequenceGenerator.asm
; Author: Sara Hashem
; Date: 11 / 08 / 2015
; Description: This program will introduce the programmer, get a number from the user,
;	validate the user's input, calculate composite numbers up to and including the
;	the user's input, and display the results.

INCLUDE Irvine32.inc

; Constant definition for integer range
upperLimit = 400

.data
terms		DWORD	?						; number of composite terms to be entered by user
composite	DWORD	3						; initialize current composite term to 3
columns		DWORD	1						; initialize number of columns to 1 to account for first column
heading		BYTE	"	Composite Numbers	by Sara Hashem", 0
intro1		BYTE	"Please enter the number of composite terms you would like displayed and I'll", 0
intro2		BYTE	"calculate and display them. Please choose a number between 1 and 400.", 0
prompt		BYTE	"Enter a number: ", 0
error		BYTE	"Out of range. The number must be between 1 and 400 (inclusive).", 0
spacing		BYTE	"   ", 0				; spacing between terms
leading1	BYTE	" ", 0					; leading space for triple digit terms
leading2	BYTE	"  ", 0					; leading space for double digit terms
leading3	BYTE	"   ", 0				; leading space for single digit terms
goodbye		BYTE	"Results certified by Sara Hashem. Goodbye now!", 0	; closing with programmer name

.code
main PROC

	CALL	introduction
	CALL	getUserData
	CALL	showComposites
	CALL	farewell

	exit									; exit to operating system
main ENDP

; Procedure to introduce program
; Receives: none
; Returns: none
; Preconditions: none
; Registers changed: EDX
introduction	PROC
; Display heading
	MOV		EDX, OFFSET heading
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; Display introduction lines
	MOV		EDX, OFFSET intro1
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET intro2
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	RET
introduction	ENDP


; Procedure to get user input
; Receives: none
; Returns: user input values for global variable terms
; Preconditions: none
; Registers changed: EAX, EDX
getUserData		PROC
; Display prompt
	MOV		EDX, OFFSET prompt
	CALL	WriteString
	CALL	ReadInt
	CALL	CrLf
	MOV		terms, EAX

; Validate input
	CALL	validate

	RET
getUserData		ENDP


; Procedure to validate input
; Receives: terms as a global variable
; Returns: none
; Preconditions: terms contains a value
; Registers changed: EAX, EDX
validate	PROC
; Validate input with conditional
	MOV		EAX, terms
	CMP		EAX, 1							; compare terms to lower limit
	JL		outOfRange						; jump if out of range
	CMP		EAX, upperLimit					; compare terms to upper limit
	JG		outOfRange						; jump if out of range
	JMP		validInput						; jump to return if input is valid

	outOfRange:
		CALL	CrLf
		MOV		EDX, OFFSET error			; display error message
		CALL	WriteString
		CALL	CrLf
		CALL	getUserData					; reprompt user for input

validInput:
	RET
validate	ENDP


; Procedure to display composite terms
; Receives: composite and terms as global variables
; Returns: current composite term
; Preconditions: none
; Registers changed: EAX, EBX, ECX
showComposites	PROC
; Display composite terms using nested for loop
	MOV		ECX, terms						; initialize loop counter with number of terms input by user
showComps:
	MOV		EAX, composite					; increment current term to begin with 4, first term in series
	INC		EAX
	MOV		composite, EAX
	
	CALL	isComposite						; determine if current term is composite

	CALL	formatting						; format and display output

	LOOP	showComps						; continue looping until ECX is equal to 0

	RET
showComposites	ENDP


; Procedure to display composite terms
; Receives: composite as a global variable
; Returns: none
; Preconditions: composite contains a value
; Registers changed : EAX, EDX
formatting		PROC
; Display composite term
	MOV		EAX, composite
	CMP		EAX, 9
	JLE		singleDigit
	CMP		EAX, 99
	JLE		doubleDigit
	CMP		EAX, 999
	JLE		tripleDigit

	singleDigit:							; print single digit composite terms
		MOV		EDX, OFFSET leading3		; add leading spaces
		CALL	WriteString
		MOV		EAX, composite
		CALL	WriteDec
		MOV		EDX, OFFSET spacing			; add spacing between terms
		CALL	WriteString
		JMP		newLineCheck
		
	doubleDigit:							; print double digit composite terms
		MOV		EDX, OFFSET leading2		; add leading spaces
		CALL	WriteString
		MOV		EAX, composite
		CALL	WriteDec
		MOV		EDX, OFFSET spacing			; add spacing between terms
		CALL	WriteString
		JMP		newLineCheck

	tripleDigit:							; print triple digit composite terms
		MOV		EDX, OFFSET leading1		; add leading space
		CALL	WriteString
		MOV		EAX, composite
		CALL	WriteDec
		MOV		EDX, OFFSET spacing			; add spacing between terms
		CALL	WriteString
		JMP		newLineCheck

	newLineCheck:							; determine if new row is needed
		MOV		EBX, columns
		CMP		EBX, 10						; compare column counter to maximum number of columns
		JE		newLine						; jump to print new line
		JNE		incrementColumns			; jump to increment column counter

		newLine:
			CALL	CrLf					; print new line
			MOV		EBX, 0
			MOV		columns, EBX			; reset column counter
	
		incrementColumns:					; increment column counter
			MOV		EBX, columns
			INC		EBX
			MOV		columns, EBX

	RET
formatting		ENDP


; Procedure to determine composite terms
; Receives: composite as a global variable
; Returns: composite as a global variable
; Preconditions: terms and composite contain values
; Registers changed: EAX, EBX, EDX
isComposite		PROC
; Calculate composite numbers by dividing current term by the first 4 additive primes: 2, 3, 5, and 7
compCalc:
	MOV		EAX, composite					; base case: check if current term is prime
	CMP		EAX, 5
	JE		increment						; jump to increment if current term is equal to 5
	CMP		EAX, 7
	JE		increment						; jump to increment if current term is equal to 7

	MOV		EAX, composite					; check if current term is a multiple of 2
	MOV		EBX, 2
	CDQ
	DIV		EBX
	CMP		EDX, 0							; if remainder is equal to 0,
	JE		isComp							; jump to print current term

	MOV		EAX, composite					; check if current term is a multiple of 3
	MOV		EBX, 3
	CDQ
	DIV		EBX
	CMP		EDX, 0							; if remainder is equal to 0,
	JE		isComp							; jump to print current term

	MOV		EAX, composite					; check if current term is a multiple of 5
	MOV		EBX, 5
	CDQ
	DIV		EBX
	CMP		EDX, 0							; if remainder is equal to 0,
	JE		isComp							; jump to print current term

	MOV		EAX, composite					; check if current term is a multiple of 7
	MOV		EBX, 7
	CDQ
	DIV		EBX
	CMP		EDX, 0							; if remainder is equal to 0,
	JE		isComp							; jump to print current term
	
	increment:
		MOV		EAX, composite				; if remainder is not equal to 0,
		INC		EAX							; increment to get next term
		MOV		composite, EAX
		JMP		compCalc					; continue looping until next composite term is found

	isComp:	
		RET									; return to print next composite term
isComposite		ENDP


; Procedure to close program
; Receives: none
; Returns: none
; Preconditions: none
; Registers changed: EDX
farewell	PROC
; Display closing
	CALL	CrLf
	CALL	CrLf
	MOV		EDX, OFFSET goodbye
	CALL	WriteString
	CALL	CrLf

	RET
farewell	ENDP


END main