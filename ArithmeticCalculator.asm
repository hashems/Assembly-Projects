TITLE Elementary Arithmetic		(ArithmeticCalculator.asm)

; Program Filename: ArithmeticCalculator.asm
; Author: Sara Hashem
; Date: 10 / 11 / 2015
; Description: This program will introduce the programmer, get two numbers from the user,
;	calculate the sum, difference, product, quotient, and remainder of those values, and
;	display the results.This program also repeats until the user chooses to quit and
;	verifies that the second number is less than the first.If the second number is
;	greater than the first, the values are swapped.

INCLUDE Irvine32.inc

.data
heading		BYTE	"	Elementary Arithmetic	by Sara Hashem", 0
num1		DWORD ? ; first number to be entered by user
num2		DWORD ? ; second number to be entered by user
sum			DWORD ?
diff		DWORD ?
prod		DWORD ?
quot		DWORD ?
remain		DWORD ?
choice		DWORD ? ; quit or continue choice to be entered by user
intro1		BYTE	"Please enter 2 numbers and I'll calculate and display the sum, difference,", 0
intro2		BYTE	"product, quotient, and remainder of those values.", 0
prompt1		BYTE	"First number:  ", 0
prompt2		BYTE	"Second number: ", 0
again		BYTE	"Enter '0' to quit or '1' to repeat the program: ", 0; prompt user to quit or repeat
swap		BYTE	"The second number must be less than the first. Swapping values...", 0
result1		BYTE	" + ", 0
result2		BYTE	" - ", 0
result3		BYTE	" x ", 0
result4		BYTE	" / ", 0
result5		BYTE	" remainder ", 0
result6		BYTE	" = ", 0
goodBye		BYTE	"Not bad for my first assembly language program, huh? Goodbye!", 0

.code
main PROC
; Display heading
	MOV		EDX, OFFSET heading			; display program title and name
	CALL	WriteString
	CALL	CrLf

; Introduce programmer
	MOV		EDX, OFFSET intro1			; display first line of introduction
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET intro2			; display second line of introduction
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf						; add line for formatting purposes

repeatLoop:								; repeat until user chooses to quit
; Get user numbers
	MOV		EDX, OFFSET prompt1			; get first number from user
	CALL	WriteString
	CALL	ReadInt
	MOV		num1, EAX					; store first number in num1 variable

	MOV		EDX, OFFSET prompt2			; get second number from user
	CALL	WriteString
	CALL	ReadInt
	MOV		num2, EAX					; store second number in num2 variable

; Validate input
	MOV		EAX, num2					; get first number
	CMP		num1, EAX					; compare second number to first
	JGE		validInput					; if first number is greater than second, jump to validInput label

; If num1 < num2, swap values
	CALL	CrLf						; add line for formatting purposes
	MOV		EDX, OFFSET swap
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf						; add line for formatting purposes
	MOV		EBX, num1
	MOV		num1, EAX					; otherwise, swap values
	MOV		num2, EBX

validInput:								; if input is valid, calculate results
; Calculate sum
	MOV		EAX, num1
	ADD		EAX, num2					; add second number to first
	MOV		sum, EAX					; store result in sum variable

; Calculate difference
	MOV		EAX, num1
	SUB		EAX, num2					; subtract second number from first
	MOV		diff, EAX					; store result in diff variable

; Calculate product
	MOV		EAX, num1
	MOV		EBX, num2
	MUL		EBX							; multiply second number by first
	MOV		prod, EAX					; store result in prod variable

; Calculate quotient
	MOV		EAX, num1
	CDQ
	MOV		EBX, num2
	DIV		EBX							; divide first number by second
	MOV		quot, EAX					; store quotient in quot variable
	MOV		remain, EDX					; store remainder in remain variable

; Display sum
	MOV		EAX, num1
	CALL	WriteDec
	MOV		EDX, OFFSET result1
	CALL	WriteString
	MOV		EAX, num2
	CALL	WriteDec
	MOV		EDX, OFFSET result6
	CALL	WriteString
	MOV		EAX, sum
	CALL	WriteDec
	CALL	CrLf

; Display difference
	MOV		EAX, num1
	CALL	WriteDec
	MOV		EDX, OFFSET result2
	CALL	WriteString
	MOV		EAX, num2
	CALL	WriteDec
	MOV		EDX, OFFSET result6
	CALL	WriteString
	MOV		EAX, diff
	CALL	WriteDec
	CALL	CrLf

; Display product
	MOV		EAX, num1
	CALL	WriteDec
	MOV		EDX, OFFSET result3
	CALL	WriteString
	MOV		EAX, num2
	CALL	WriteDec
	MOV		EDX, OFFSET result6
	CALL	WriteString
	MOV		EAX, prod
	CALL	WriteDec
	CALL	CrLf

; Display quotient and remainder
	MOV		EAX, num1
	CALL	WriteDec
	MOV		EDX, OFFSET result4
	CALL	WriteString
	MOV		EAX, num2
	CALL	WriteDec
	MOV		EDX, OFFSET result6
	CALL	WriteString
	MOV		EAX, quot
	CALL	WriteDec
	MOV		EDX, OFFSET result5
	CALL	WriteString
	MOV		EAX, remain
	CALL	WriteDec
	CALL	CrLf
	CALL	CrLf						; add line for formatting purposes

; Get user choice to quit or repeat
	MOV		EDX, OFFSET again
	CALL	WriteString
	CALL	ReadInt
	MOV		choice, EAX					; store input in choice variable
	CALL	CrLf
	MOV		EBX, choice
	CMP		EBX, 1						; if user chooses to repeat, jump to beginning of loop
	JE		repeatLoop

endLoop:								; otherwise, display closing
; Display closing
	MOV		EDX, OFFSET goodBye
	CALL	WriteString
	CALL	CrLf

	exit								; exit to operating system
main ENDP

END main