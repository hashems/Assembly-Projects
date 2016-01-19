TITLE Low - Level I / O Procedures(InputOutputProcedures.asm)

; Program Filename: InputOutputProcedures.asm
; Author: Sara Hashem
; Date: 12 / 06 / 2015
; Description: This program will introduce the program, get 10 unsigned decimal integers
;	from the user character string, converts those string to their representative numeric
;	value, validates the user's input, displays the list of integers, calculates and displays
;	the sum and average of those values. This program passes some parameters on the system
;	stack and utilizes macros.

INCLUDE Irvine32.inc

; Macro definitions

; Macro to print strings
; Receives: address of string
; Returns: string printed to console
; Preconditions: string is initialized
; Registers changed: EAX, EDX
; Avoid: EAX and EDX as arguments
displayString	MACRO	string
; Save used register
	PUSH	EDX
	
	MOV		EDX, string						; store string in EDX
	CALL	WriteString						; invoke Irvine library macro

; Restore used register
	POP		EDX
ENDM


; Macro to read strings
; Receives: addresses of buffer and string
; Returns: string printed to console and keyboard input store in buffer
; Preconditions: string is initialized
; Registers changed: EAX, ECX, EDX
; Avoid: EAX, ECX, and EDX as arguments
getString	MACRO	buffer, string
; Save used registers
	PUSH	ECX
	PUSH	EDX

; Invoke displayString macro passing string as arugment
	displayString	string

	MOV		EDX, buffer						; store buffer in EDX
	MOV		ECX, 100						; store buffer length
	CALL	ReadString						; invoke Irvine library macro

; Restore used registers
	POP		EDX
	POP		ECX
ENDM



.data
intro		BYTE	"Low-Level I/O Procedures		Programmed by Sara Hashem", 0ah, 0dh, 0ah, 0dh
			BYTE	"**EC 1: Lines numbered during user input.", 0ah, 0dh, 0ah, 0dh
			BYTE	"Please enter 10 unsigned decimal integers and I'll display them and calculate", 0ah, 0dh
			BYTE	"and display the sum and average of those values.", 0ah, 0dh
			BYTE	"Each number must be small enough to fit within a 32 bit register.", 0
prompt		BYTE	"Enter a number: ", 0
error		BYTE	"That won't do! Try again.", 0
listStr		BYTE	"You entered the following numbers:", 0
sumStr		BYTE	"The sum of the values is: ", 0
avgStr		BYTE	"And the rounded average is: ", 0
closing		BYTE	"Well, this has been fun.", 0ah, 0dh
			BYTE	"Goodbye, Assembly Language & Architecture!", 0
spacing		BYTE	"   ", 0
strArr		BYTE	100 DUP(?)				; empty character array to store user input
conArr		BYTE	33 DUP(?)				; array to store convert decimal-to-ASCII values
strLen		DWORD	?						; variable to store actual string length
decimal		DWORD	?						; variable to store converted decimal value
numArr		DWORD	10 DUP(?)				; empty number array to store character bytes
num			DWORD	?						; dword variable to store converted user input
sum			DWORD	?						; variable to store calculated sum
average		DWORD	?						; variable to store calculated average



.code
main PROC
	PUSH	OFFSET intro					; pass intro by reference
	CALL	introduction					; introduce the program

	PUSH	strLen							; pass strLen by value
	PUSH	OFFSET error					; pass error by reference
	PUSH	OFFSET prompt					; pass prompt by reference
	PUSH	OFFSET numArr					; pass numArr by reference		
	PUSH	OFFSET strArr					; pass strArr by reference
	CALL	readVal							; get user input


	PUSH	OFFSET spacing					; pass @spacing by reference
	PUSH	OFFSET listStr					; pass @listStr by reference
	PUSH	OFFSET conArr					; pass @conArr by reference
	PUSH	OFFSET numArr					; pass @numArr by reference
	CALL	writeVal						; display results


	PUSH	OFFSET avgStr					; pass @avgStr
	PUSH	average							; pass average by value
	PUSH	OFFSET sumStr					; pass @sumStr by reference
	PUSH	sum								; pass sum by value
	PUSH	OFFSET numArr					; pass @numArr by reference
	CALL	getResults						; calculate and display sum and average
	

	PUSH	OFFSET closing					; pass @closing by reference
	CALL	goodbye							; close the program

	exit									; exit to operating system
main ENDP


; Procedure to introduce program
; Receives: address of intro on system stack
; Returns: none
; Preconditions: none
; Registers changed: EDI
introduction	PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP
	
	displayString	[EBP+8]					; print introduction
	CALL	CrLf

	POP		EBP
	RET		4
introduction	ENDP


; Procedure to get and validate user input
; Receives: addresses of prompt, strArr, numArr and strLen and numCount values on system stack
; Returns: initialized numArr array with valid user input converted to decimal
; Preconditions: 1 <= strLen <= 10
; Registers changed: EAX, EBX, ECX, EDI, ESI
readVal		PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP

; Save used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	MOV		EDI, [EBP+12]					; store @numArr in EDI

; Get user input
	MOV		ECX, 10							; store number count of 10 in ECX as outer loop counter
getNum:
	getString	[EBP+8], [EBP+16]			; prompt user for input
	MOV			[EBP+24], EAX				; store string length in strLen

	PUSH	ECX								; otherwise, save getNum loop counter
	MOV		ECX, [EBP+24]					; initialize loop counter with value of strLen
	MOV		ESI, [EBP+8]					; store @strArr in ESI
	MOV		EAX, 0							; initialize EAX for loading string bytes
	MOV		EBX, 0							; initialize EBX as digit accumulator
	CLD										; clear direction flag to move forward through string

	load:
		LODSB								; load string byte in EAX
		
	; Validate user input
		CMP		EAX, 48						; determine if character is within range
		JL		invalid						; if less than 48
		CMP		EAX, 57						; or greater than 57,
		JG		invalid						; jump to invalid

		SUB		EAX, 48						; otherwise, convert to decimal
		PUSH	EAX							; save converted value

		MOV		EAX, EBX					; store accumulator value in EAX for multiplication
		MOV		EBX, 10
		MUL		EBX							; multiply accumulator by 10
		JC		invalid2					; check for overflow and pop EAX
		MOV		EBX, EAX					; store product in EBX

		POP		EAX							; restore converted value
		ADD		EBX, EAX					; add significant digits
		JC		invalid						; check for overflow and don't pop EAX

		MOV		EAX, EBX
		MOV		EAX, 0						; reset EAX for next loaded byte

		LOOP	load						; continuing loading string bytes and converting

	MOV		EAX, EBX						; store accumulator in EAX
	STOSD									; store DWORD bytes in numArr
	
	ADD		ESI, 4							; get next element
	POP		ECX								; restore getNum loop counter
	LOOP	getNum
	JMP		finish

invalid2:
	POP				EAX
	POP				ECX
	displayString	[EBP+20]				; print error string
	CALL			CrLf
	CLC										; clear Carry flag
	JMP				getNum					; reprompt user for input

invalid:
	POP				ECX						; restore getNum loop counter
	displayString	[EBP+20]				; print error string
	CALL			CrLf
	CLC										; clear Carry flag
	JMP				getNum					; reprompt user for input

finish:
; Restore used registers
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX

	POP		EBP
	RET		20
readVal		ENDP


; Procedure to calculate and display sum and average
; Receives: addresses of numArr, sumStr, and avgStr and sum and average values on system stack
; Returns: sum and average of numArr values
; Preconditions: numArr initialized with valid values
; Registers changed: EAX, EBX, ECX, ESI
getResults		PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP

; Save used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	ESI

	MOV		ESI, [EBP+8]					; store @numArr in ESI

; Calculate sum
	MOV		EAX, 0							; initialize sum accumulator to 0
	MOV		ECX, 10
getSum:
	MOV		EBX, [ESI]						; get element
	ADD		EAX, EBX						; add element to accumulator
	ADD		ESI, 4							; get next element
	LOOP	getSum							; continue adding elements to accumulator

	MOV		[EBP+12], EAX					; store accumulated sum in sum variable

; Print sum
	displayString	[EBP+16]				; print sum string
	MOV				EAX, [EBP+12]			; store sum value in EAX	
	CALL			WriteDec				; print sum value
	CALL			CrLf

; Calculate average
	MOV		EAX, [EBP+12]					; store sum in EAX
	CDQ
	MOV		EBX, 10							; by 10
	DIV		EBX

	MOV		[EBP+20], EAX					; store average in EAX

; Print average
	displayString	[EBP+24]				; print average string
	MOV				EAX, [EBP+20]			; store average value in EAX	
	CALL			WriteDec				; print average value
	CALL			CrLf

; Restore used registers
	POP		ESI
	POP		ECX
	POP		EBX
	POP		EAX

	POP		EBP
	RET		20
getResults		ENDP


; Procedure to display user input
; Receives: addresses of numArr, conArr, and listStr on system stack
; Returns: ASCII representations of numArr values
; Preconditions: numArr initialized with valid values
; Registers changed: EAX, EBX, ECX, EDX, EDI, ESI
writeVal	PROC
; Set up system stack
	PUSH	EBP
	MOV		EBP, ESP

; Save used registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	MOV		ESI, [EBP+8]					; store @numArr in ESI
	MOV		EDI, [EBP+12]					; store @conArr in EDI

	CALL			CrLf
	displayString	[EBP+16]				; display list string label
	CALL			CrLf

	CLD										; clear direction flag to move forward through string
	MOV			ECX, 10

; Convert decimal values to ASCII string
convert:
	convertDigits:
		MOV		EBX, 10
		CDQ
		DIV		EBX							; divide integer by 10
		ADD		EDX, 48						; add 48 to remainder
		PUSH	EAX							; save quotient
		MOV		EAX, EDX					; store remainder in EAX to print

		STOSB								; store string bytes in conArr

		POP		EAX							; restore quotient
		CMP		EAX, 0						; determine if digits remain
		JNE		convertDigits				; if EAX is not equal to 0, continue converting to ASCII

		LODSD								; otherwise, load string bytes in EAX
		CALL			WriteDec			; print converted value
		displayString	[EBP+20]			; print spacing

	LOOP	convert							; continue converting decimal values to ASCII

	CALL	CrLf
	CALL	CrLf

; Restore used registers
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX

	POP		EBP
	RET		16
writeVal	ENDP


; Procedure to close program
; Receives: address of closing on system stack
; Returns: none
; Preconditions: none
; Registers changed: none
goodbye		PROC
; Set up stack frame
	PUSH	EBP
	MOV		EBP, ESP
	
	CALL	CrLf
	displayString	[EBP+8]					; print closing
	CALL	CrLf
	CALL	CrLf

	POP		EBP
	RET		4
goodbye		ENDP

END main