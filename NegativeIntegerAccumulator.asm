TITLE Negative Integer Accumulator		(NegativeIntegerAccumulator.asm)

; Program Filename: NegativeIntegerAccumulator.asm
; Author: Sara Hashem
; Date : 11 / 01 / 2015
; Description: This program will introduce the programmer, get a series of negative
; numbers from the user, calculate the sum and average of those values, and display
; the results. This program also displays line numbers during user input.

INCLUDE Irvine32.inc

; Constant definitions for integer range
lowerLimit = -100
upperLimit = -1

.data
userNum		DWORD	?						; integer value to be entered by user
nums		DWORD	0						; initialize number of values to 0
sum			DWORD	0						; initialize sum to 0
avg			DWORD	0						; initialize average to 0
line		DWORD	1						; initialize line number to 1
quot		DWORD	?
remain		DWORD	?
heading		BYTE	"	Negative Integer Accumulator	by Sara Hashem", 0
userName	BYTE	33 DUP(0)				; string to be entered by user
prompt1		BYTE	". What's your name? ", 0		; include dot and space for line number formatting
greeting	BYTE	"Hello, ", 0			; greeting with user name
period		BYTE	".", 0					; include punctuation
intro1		BYTE	"Please enter numbers between -100 and -1 and I'll calculate and display the sum", 0
intro2		BYTE	"and average of those values. Enter a non-negative number to see the results.", 0
prompt2		BYTE	". Enter a number: ", 0			; include dot and space for line number formatting
error		BYTE	"Too low. Please enter a number between -100 and -1.", 0
noNegs		BYTE	"No valid numbers were entered!", 0
result1		BYTE	"You entered ", 0
result2		BYTE	" valid numbers.", 0
result3		BYTE	"The sum of your valid numbers is ", 0
result4		BYTE	"And the rounded average is ", 0
goodbye		BYTE	"Thanks for playing! Goodbye, ", 0

.code
main PROC
; Display heading
	MOV		EDX, OFFSET heading				; display program title and name
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; Get user name
	MOV		EAX, line						; print line number
	CALL	WriteDec
	MOV		EDX, OFFSET prompt1
	CALL	WriteString
	MOV		EDX, OFFSET userName
	MOV		ECX, 32
	CALL	ReadString
	INC		line							; increment line number

; Greet user by name
	MOV		EDX, OFFSET greeting
	CALL	WriteString
	MOV		EDX, OFFSET userName
	CALL	WriteString
	MOV		EDX, OFFSET period
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; Display program introduction and instructions
	MOV		EDX, OFFSET intro1				; display first line of introduction
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET intro2				; display second line of introduction
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; Prompt user for number
getNum:										; post-test loop for getting user data
	MOV		EAX, line						; print line number
	CALL	WriteDec
	MOV		EDX, OFFSET prompt2
	CALL	WriteString
	CALL	ReadInt
	MOV		userNum, EAX					; store input in userNum variable

	CMP		EAX, lowerLimit					; validate input
	JL		tooLow							; jump if less than -100
	CMP		EAX, upperLimit
	JG		checkValid						; jump if greater than -1

	INC		nums							; otherwise, increment number of values
	ADD		sum, EAX						; accumulate sum
	INC		line							; increment line number
	JMP		getNum							; continue looping

checkValid:									; post-test loop false block 1
	MOV		EAX, nums						; check if no valid numbers were entered
	CMP		EAX, 0
	JE		noValid							; jump if number of valid numbers is equal to 0
	JG		printResults					; jump if at least one valid number was entered

tooLow:										; post-test loop false block 2
	MOV		EDX, OFFSET error
	CALL	WriteString
	CALL	CrLf
	JMP		getNum							; jump back to prompt loop

noValid:									; conditional false block
	CALL	CrLf
	MOV		EDX, OFFSET noNegs
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf
	JMP		closing							; jump past printing results

; Calculate and display sum and average
printResults:								; post-test loop false block 3
	MOV		EAX, sum						; calculate average
	CDQ
	MOV		EBX, nums
	IDIV	EBX
	MOV		quot, EAX						; store quotient in quot variable
	MOV		remain, EDX						; store remainded in remain variable
	JMP		round

	round:
		MOV		EAX, quot					; divide quotient by 2
		CDQ
		MOV		EBX, 2
		IDIV	EBX
		CMP		EAX, remain					; compare remainder to halved quotient
		JGE		up							; jump to round up
		JL		down						; jump to round down

		up:
			MOV		EAX, quot
			DEC		EAX						; decrement quotient to account for rounding
			MOV		avg, EAX				; store rounded average in avg variable

		down:
			MOV		EAX, quot
			MOV		avg, EAX				; store rounded average in avg variable

	CALL	CrLf
	MOV		EDX, OFFSET result1				; print number of values
	CALL	WriteString
	MOV		EAX, nums
	CALL	WriteDec
	MOV		EDX, OFFSET	result2
	CALL	WriteString
	CALL	CrLf

	MOV		EDX, OFFSET result3				; print sum
	CALL	WriteString
	MOV		EAX, sum
	CALL	WriteInt
	MOV		EDX, OFFSET period
	CALL	WriteString
	CALL	CrLf

	MOV		EDX, OFFSET result4				; print rounded average
	CALL	WriteString
	MOV		EAX, avg
	CALL	WriteInt
	MOV		EDX, OFFSET period
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; Display closing
closing:
	MOV		EDX, OFFSET goodbye
	CALL	WriteString
	MOV		EDX, OFFSET userName
	CALL	WriteString
	MOV		EDX, OFFSET period
	CALL	WriteString
	CALL	CrLf

	exit									; exit to operating system
main ENDP

END main