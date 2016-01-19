TITLE Random Array Sort		(NegativeIntegerAccumulator.asm)

; Program Filename: NegativeIntegerAccumulator.asm
; Author: Sara Hashem
; Date: 11 / 22 / 2015
; Description: This program will introduce the program, get a number from the user,
;	generate a that many random integers, store them in an array, display the unsorted
;	integers, calculate and display the median value of those integers, and display the
;	same integers again in sorted order. This program passes some parameters on the
;	system stack.

INCLUDE Irvine32.inc

; Constant definitions for integer user request
min = 10
MAX = 200

; Constant definitions for integer range
lo = 100
hi = 999

.data
heading		BYTE	"Sorting Random Integers			Programmed by Sara Hashem", 0
intro1		BYTE	"This program generates random numbers between 100 and 999, displays the", 0
intro2		BYTE	"original list, calculates the median value of the list, and displays the list", 0
intro3		BYTE	"once again in sorted order.", 0
prompt		BYTE	"Please enter the number of random values you'd like generated [10 - 200]: ", 0
error		BYTE	"Out of range. The number must be between 10 and 200 (inclusive).", 0
unsorted	BYTE	"Unsorted List:", 0		; unsorted array title
sorted		BYTE	"Sorted List:", 0		; sorted array title
median		BYTE	"The median is ", 0
period		BYTE	".", 0
spacing		BYTE	"   ", 0				; spacing between terms
request		DWORD	?						; number of random values to generate to be entered by user
list		DWORD	MAX	DUP(?)				; empty array of size MAX
columns		DWORD	1						; initialize number of columns to 1 to account for first column


.code
main PROC
	CALL	Randomize

	CALL	introduction					; introduce the program

	PUSH	OFFSET request					; pass request by reference
	CALL	getData							; get value for request

	PUSH	OFFSET list						; pass list by reference
	PUSH	request							; pass request by value
	CALL	fillArray						; fill array with request number of random integers

	PUSH	OFFSET unsorted					; pass title of unsorted list by reference
	PUSH	OFFSET list						; pass list by reference
	PUSH	request							; pass request by value
	PUSH	columns							; pass columns by value
	CALL	displayList						; print unsorted array

	PUSH	OFFSET list						; pass list by reference
	PUSH	request							; pass request by value
	CALL	sortList						; sort array

	PUSH	OFFSET list						; pass list by reference
	PUSH	request							; pass request by value
	CALL	displayMedian					; print median of array

	PUSH	OFFSET sorted					; pass title of sorted list by reference
	PUSH	OFFSET list						; pass list by reference
	PUSH	request							; pass request by value
	PUSH	columns							; pass columns by value
	CALL	displayList						; print sorted array

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
	MOV		EDX, OFFSET intro3
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	RET
introduction	ENDP


; Procedure to get and validate user input
; Receives: address of request on system stack
; Returns: user input value for request
; Preconditions: none
; Registers changed: EAX, EBX, EDX

getData		PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP

reprompt:
; Get integer for request
	MOV		EBX, [EBP+8]					; store @request in EBX
	MOV		EDX, OFFSET prompt				; display prompt
	CALL	WriteString
	CALL	ReadInt							; user input in EAX

; Validate input with conditional
	CMP		EAX, min						; compare user input to min
	JL		outOfRange						; jump if out of range
	CMP		EAX, max						; compare user input to upper limit
	JG		outOfRange						; jump if out of range
	JMP		validInput						; jump to return if input is valid

	validInput:
		MOV		[EBX], EAX					; store user input @EBX
		POP		EBP
		RET		4

	outOfRange:
		CALL	CrLf
		MOV		EDX, OFFSET error			; display error message
		CALL	WriteString
		CALL	CrLf
		LOOP	reprompt					; reprompt user for input

getData		ENDP


; Procedure to fill array
; Receives: address of list and request value on system stack and max as global constant
; Returns: first request elements of list contain random integers
; Preconditions: request is initialized, 10 <= request <= 200
; Registers changed: EAX, ECX, EDI

fillArray	PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDI, [EBP+12]					; store @list in EDI
	MOV		ECX, [EBP+8]					; store request in ECX as loop counter

random:
	MOV		EAX, [EDI]						; get current element
	
	MOV		EAX, hi							; set range
	SUB		EAX, lo
	INC		EAX
	CALL	RandomRange
	ADD		EAX, lo

	MOV		[EDI], EAX						; store EAX @EDI
	ADD		EDI, 4							; get next element
	LOOP	random

	POP		EBP
	RET		8

fillArray	ENDP


; Procedure to display array
; Receives: address of un/sorted, list, and request and columns values on system stack
; Returns: printed title and first request elements of list
; Preconditions: request is initialized, 10 <= request <= 200 and first request
;				 elements of array initialized, columns is initialized
; Registers changed: EAX, EBX, ECX, EDX, EDI

displayList		PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDX, [EBP+20]					; store @un/sorted in EDX
	MOV		EDI, [EBP+16]					; store @list in EDI
	MOV		ECX, [EBP+12]					; store request in ECX as loop counter
	MOV		EBX, [EBP+8]					; store columns in EBX as column counter

	CALL	CrLf							; print list title
	CALL	WriteString
	CALL	CrLf

print:
	MOV		EAX, [EDI]						; start at first element
	CALL	WriteDec
	MOV		EDX, OFFSET	spacing				; add spacing between elements
	CALL	WriteString
	ADD		EDI, 4							; get next element

	MOV		EBX, [EBP+8]					; store columns in EBX as column counter
	CMP		EBX, 10							; compare number of columns to 10
	JE		newLine							; jump to print new line
	JNE		incrementColumn					; jump to increment columns

	newLine:								; print new line
		CALL	CrLf
		MOV		EBX, 0						; reset column counter
		MOV		[EBP+8], EBX				; store columns in memory

	incrementColumn:						; increment column counter
		MOV		EBX, [EBP+8]
		INC		EBX
		MOV		[EBP+8], EBX				; store columns in memory

	LOOP	print							; continue looping if there are still elements to print

	CALL	CrLf

	POP		EBP
	RET		16

displayList		ENDP


; Procedure to sort array in descending order
; Receives: address of list and request value on system stack
; Returns: first request elements of list in sorted order
; Preconditions: request is initialized, 10 <= request <= 200 and first request
;				 elements of array initialized
; Registers changed: EAX, ECX, EDI

sortList	PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDI, [EBP+12]					; store @list in EDI
	MOV		ECX, [EBP+8]					; store request in ECX as loop counter

	;------------------------------------------------------------------------------------------
	; Code modified from Assembly Language (2015) [BubbleSort procedure]
	; Retrieved November 15, 2015 from pages 374 and 375
	;------------------------------------------------------------------------------------------
	DEC		ECX								; k < request-1

outer:
	PUSH	ECX								; save outer loop counter
	MOV		EDI, [EBP+12]					; start with last element

	inner1:
		MOV		EAX, [EDI]					; point to current element
		CMP		[EDI+4], EAX
		JL		inner2						; jump if list[i] < list[i+1]
		XCHG	EAX, [EDI+4]				; exchange elements
		MOV		[EDI], EAX

		inner2:
			ADD		EDI, 4					; move array pointer back
			LOOP	inner1

			POP		ECX						; restore outer loop counter
			LOOP	outer
			
	POP		EBP
	RET		8

sortList	ENDP


; Procedure to calculate and print median
; Receives: address of list and request value on system stack
; Returns: median value of array
; Preconditions: request is initialized, 10 <= request <= 200 and first request
;				 elements of array initialized, array is sorted
; Registers changed: EAX, EBX, ECX, EDX, EDI

displayMedian	PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDI, [EBP+12]					; store @list in EDI
	MOV		EAX, [EBP+8]					; store request in EAX as loop counter

; Determine if request is even or odd
	MOV		EBX, 2
	CDQ
	DIV		EBX
	CMP		EDX, 0
	JE		evenNum							; if even (EDX = 0), get middle two elements
	JNE		oddNum							; if odd (EDX != 0), get middle element

	evenNum:
		MOV		EBX, [EDI+4*EAX]			; get middle two elements
		DEC		EAX
		MOV		ECX, [EDI+4*EAX]
		MOV		EAX, ECX
		ADD		EAX, EBX					; sum of middle elements in ECX
		MOV		EBX, 2
		CDQ
		DIV		EBX

		CALL	CrLf						; print median
		MOV		EDX, OFFSET median
		CALL	WriteString
		CALL	WriteDec
		CALL	CrLf
		JMP		finish						; jump to return

	oddNum:
		MOV		EBX, [EDI+EAX*4]
		MOV		EAX, EBX

		CALL	CrLf						; print median
		MOV		EDX, OFFSET median
		CALL	WriteString
		CALL	WriteDec
		MOV		EDX, OFFSET period
		CALL	WriteString
		CALL	CrLf
		JMP		finish						; jump to return

finish:
	POP		EBP
	RET		8
displayMedian	ENDP

END main