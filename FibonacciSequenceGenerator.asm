TITLE Fibonacci Numbers		(FibonacciSequenceGenerator.asm)

; Program Filename: FibonacciSequenceGenerator.asm
; Author: Sara Hashem
; Date: 10 / 18 / 2015
; Description: This program will introduce the programmer, get a number from the user,
;	validate the user's input, calculate the Fibonacci numbers up to and including the
;	user's input, and display the results.

INCLUDE Irvine32.inc

upperLimit = 46
columns = 5

.data
fibTerms	DWORD	?					; number of Fibonacci terms to be entered by user
prev		DWORD	0					; 0th Fibonacci term, initialized to 0
curr		DWORD	1					; first Fibonacci term, initialized to 1
next		DWORD	1					; second Fibonacci term, initialized to 1
numCol		DWORD	2; number of columns per line, initialized to 2 for first two columns
heading		BYTE	"	Fibonacci Numbers	by Sara Hashem", 0
userName	BYTE	33 DUP(0); string to be entered by user
prompt1		BYTE	"What's your name? ", 0
greeting	BYTE	"Hello, ", 0		; greeting with user name
intro1		BYTE	"Please enter the number of Fibonacci terms you would like displayed and I'll", 0
intro2		BYTE	"calculate and display them. Please choose a number between 1 and 46 (inclusive).", 0
prompt2		BYTE	"Enter a number: ", 0
period		BYTE	".", 0				; include punctuation
error		BYTE	"Out of range. The number must be between 1 and 46 (inclusive).", 0
spacing		BYTE	"     ", 0			; spacing between terms
goodbye1	BYTE	"Results certified by Sara Hashem.", 0
goodbye2	BYTE	"Goodbye, ", 0		; closing with user name

.code
main PROC
; Display heading
	MOV		EDX, OFFSET heading			; display program title and name
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf						; add line for formatting purposes

; Get user name
	MOV		EDX, OFFSET prompt1
	CALL	WriteString
	MOV		EDX, OFFSET userName
	MOV		ECX, 32
	CALL	ReadString

; Greet user by name
	MOV		EDX, OFFSET greeting
	CALL	WriteString
	MOV		EDX, OFFSET userName
	CALL	WriteString
	MOV		EDX, OFFSET period
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf						; add line for formatting purposes

; Introduction of program
	MOV		EDX, OFFSET intro1			; display first line of introduction
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET intro2			; display second line of introduction
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf						; add line for formatting purposes

; Get user number and validate input
getFibs:								; post-test loop for implementing input validation
	MOV		EDX, OFFSET prompt2
	CALL	WriteString
	CALL	ReadInt
	MOV		fibTerms, EAX				; store input in fibTerms variable

	MOV		EAX, fibTerms				; validate input
	CMP		EAX, upperLimit				; compare fibTerms to upper limit
	JG		outOfRange					; jump if greater than 46
	CMP		EAX, 1						; compare fibTerms to lower limit
	JE		oneTerm						; special case - jump if number of terms is equal to 1
	JL		outOfRange					; jump if less than 1

; Calculate and display Fibonacci numbers
; Post-test loop true code block
	MOV		EAX, fibTerms
	INC		EAX							; increment number of terms to avoid 0th term
	MOV		fibTerms, EAX

	;------------------------------------------------------------------------------------------
	; Code modified from Robust Programmer (2014) [Computer program]
	; Retrieved from http://robustprogramming.com/fibonacci-series-assembly/
	; Retrieved October 5, 2015
	;------------------------------------------------------------------------------------------
	MOV		EAX, curr					; print current term
	CALL	WriteDec
	MOV		EDX, OFFSET spacing			; add spacing between terms
	CALL	WriteString

	MOV		ECX, fibTerms				; initialize ECX to number of Fibonacci term
	SUB		ECX, 2						; subtract first two terms from count
fibCalc:								; counted loop for implementing Fibonacci calculations
	MOV		EAX, prev					; calculate and display next term
	ADD		EAX, curr
	MOV		next, EAX
	MOV		EAX, next
	CALL	WriteDec
	MOV		EDX, OFFSET spacing			; add spacing between terms
	CALL	WriteString

	MOV		EAX, curr					; calculate and store current, previous, and next terms
	MOV		prev, EAX
	MOV		EAX, next
	MOV		curr, EAX

	MOV		EAX, numCol					; update number of columns
	CMP		EAX, columns
	JE		newLine						; jump if 5 columns have been printed
	JNE		incCol						; jump if number of columns needs to be incremented

	newLine:							; print new line and reset number of columns
		CALL	CrLf
		MOV		EAX, 0
		MOV		numCol, EAX

	incCol:								; increment number of columns
		MOV		EAX, numCol
		ADD		EAX, 1
		MOV		numCol, EAX

	LOOP	fibCalc						; continue looping if ECX is greater than 0
	JMP		goodbye						; jump out of loop when ECX equals 0

oneTerm:								; special case - 1 term input by user
	MOV		EAX, curr					; only display the first term
	CALL	WriteDec
	CALL	CrLf
	JMP		goodbye						; display closing

; Post-test loop false code block
outOfRange:
	MOV		EDX, OFFSET error
	CALL	WriteString
	CALL	CrLf
	JMP		getFibs						; reprompt for input

; Display closing
goodbye:
	CALL	CrLf						; add line for formatting purposes
	CALL	CrLf
	MOV		EDX, OFFSET goodbye1
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET goodbye2
	CALL	WriteString
	MOV		EDX, OFFSET userName
	CALL	WriteString
	MOV		EDX, OFFSET period
	CALL	WriteString
	CALL	CrLf

	exit								; exit to operating system
main ENDP

END main