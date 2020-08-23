TITLE Program6     (Project6.asm)

; Author: Dyllan Vangemert
; Last Modified: 03/14/2020
; OSU email address: vangemed@oregonestate.edu
; Course number/section: CS 271 - 400
; Project Number: 6                Due Date: 03/15/2020
; Description: Implements homemade readVal and and writeVal procedures for signed integers.
; Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input
; from the user, and WriteString to display output. Program asks user to input a numeric value that
; can fit inside a 32 bit register. Uses macro to get input as a string. String value is then converted,
; if valid, into numeric value and stored in an array. User must enter 10 values to be placed in array.
; A running sum is kept and displayed throughout the program. The array is then displayed, the total sum
; is displayed, and the average of input values is displayed (rounded down to nearest integer). Each time
; a number is displayed (after having been converted from string to numeric form), the numeric value is
; converted into a string (in reverse). The reversed string is then reversed/aligned to be displayed as
; a string, by calling a macro to display it, reflecting the proper numeric value. Conversions are made
; by converting ascii values to decimal, and then back to ascii.

INCLUDE Irvine32.inc

ARRAYSIZE = 10

getString MACRO @string, stringLength, instruction
; MACRO: Calls ReadString to get user input.
; Receives: LENGTHOF string1, OFFSET of: string1, instruct
; Returns: Changed variable: string1
; Preconditions: None.
; Post-conditions: None.
; Registers changed: ECX, EDX

	pushad
	displayString	instruction

	mov		ecx, stringLength
	sub		ecx, 1
	mov		edx, @string
	call	ReadString
	popad

ENDM


displayString MACRO buffer
; MACRO: Moves string address to edx and calls WriteString
; Receives: One string to be printed.
; Returns: None.
; Preconditions: None.
; Post-conditions: None.
; Registers changed: EDX

	push	edx
	mov		edx, buffer
	call	WriteString
	pop		edx

ENDM


.data	
string1		BYTE	13 DUP(?), 0
string2		BYTE	13 DUP(?), 0
num			DWORD	?
count		DWORD	?
sum			DWORD	?
average		DWORD	?
array		DWORD	ARRAYSIZE		 DUP(?)
intro_1		BYTE	"Hello, my name is Dyllan. This is program assignment #6.", 0
prompt_1	BYTE	"Please provide 10 signed decimal integers.", 0
prompt_2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
prompt_3	BYTE	"After you have finished inputting the raw numbers I will display a list ", 0
prompt_4	BYTE	"of the integers, their sum, and their average value.", 0
instruct	BYTE	"Please enter an signed number: ", 0
ex_cred		BYTE	"EC1: Displays a running subtotal of the user’s numbers.", 0
error		BYTE	"ERROR: You did not enter a signed number or your number was too big.", 0
display1	BYTE	"You entered the following numbers:", 0
displaySum	BYTE	"The sum of these numbers is: ", 0
displayAvg	Byte	"The rounded average is: ", 0
goodbye		BYTE	"You can't win. If you strike me down, I shall become more powerful than you can possibly imagine.", 0



.code
main PROC
	
	push	OFFSET ex_cred
	push	OFFSET prompt_4
	push	OFFSET prompt_3
	push	OFFSET prompt_2
	push	OFFSET prompt_1
	push	OFFSET intro_1
	call	intro

	push	OFFSET displaySum
	push	OFFSET count
	push	OFFSET string2
	push	OFFSET sum
	push	ARRAYSIZE
	push	OFFSET array
	push	OFFSET num
	push	OFFSET error
	push	OFFSET instruct
	push	LENGTHOF string1
	push	OFFSET string1
	call	getInput


	push	OFFSET count
	push	OFFSET string2
	push	OFFSET num
	push	OFFSET string1
	push	OFFSET array
	push	ARRAYSIZE
	push	OFFSET display1
	call	displayList

	push	OFFSET displaySum
	push	OFFSET count
	push	OFFSET string2
	push	OFFSET string1
	push	OFFSET sum
	call	totalSum

	push	OFFSET average
	push	OFFSET displayAvg
	push	OFFSET count
	push	OFFSET string2
	push	OFFSET string1
	push	ARRAYSIZE
	push	OFFSET sum
	call	findAverage

	push	OFFSET goodbye
	call	farewell

	exit	; exit to operating system

main ENDP


intro		PROC
; Procedure: Displays introduction and instructions
; Receives: OFFSETS of: intro_1, prompts 1-4
; Returns: 24 bytes off stack. No variables changed.
; Preconditions: None.
; Post-conditions: None.
; Registers changed: None.

	push	ebp
	mov		ebp, esp
	pushad

; Display intro and user prompts/instructions
	displayString	[ebp+8]			; display intro
	call	CrLf
	call	CrLf
	displayString	[ebp+28]		; display extra credit option
	call	CrLf
	call	CrLf
	displayString	[ebp+12]		; display prompt (Part 1 of 4)
	call	CrLf
	displayString	[ebp+16]		; display prompt (Part 2 of 4)
	call	CrLf
	displayString	[ebp+20]		; display prompt (Part 3 of 4)
	call	CrLf
	displayString	[ebp+24]		; display prompt (Part 4 of 4)
	call	CrLf
	call	CrLf

	popad
	pop		ebp
	ret		24

intro		ENDP



getInput	PROC
; Procedure: Instructs user and gets 10 user input numeric strings, places each value in array, 
; calculates/displays running sum of each input
; Receives: ARRAYSIZE, LENGTHOF string1 and OFFSETS of: instruct, displaySum, error, array, string1, string2, num, count, sum
; Returns: 44 bytes off stack. Changed variables: array, string1, string2, num, sum, count
; Preconditions: None.
; Post-conditions: User must enter 10 valid numeric strings to fit in 32-bit register
; Registers changed: EAX, EBX, ECX, EDX, EDI

	push	ebp
	mov		ebp, esp
	pushad

	mov		edi, [ebp+28]		; edi = array address
	mov		edx, [ebp+36]		; edx = sum address
	mov		ecx, [ebp+32]		; ecx = ARRAYSIZE

populateArray:	
	push	[ebp+24]			; Push num address
	push	[ebp+20]			; Push error string address
	push	[ebp+16]			; Push instruct string address
	push	[ebp+12]			; Push LENGTHOF string1
	push	[ebp+8]				; Push string1 address
	call	readVal

	mov		ebx, [ebp+24]		; ebx = num address
	mov		eax, [ebx]			; eax = num value
	mov		[edi], eax			; place num value in array
	add		edi, 4				; move index pointer to next space in array

	mov		ebx, [edx]			; ebx = sum value
	add		ebx, eax			; add user input (num value) to sum
	mov		[edx], ebx			; change value of sum variable
	
	
	displayString	[ebp+48]	; OFFSET displaySum
	push	[ebp+44]			; OFFSET count
	push	[ebp+40]			; OFFSET string2
	push	[ebp+36]			; OFFSET sum
	push	[ebp+8]				; OFFSET string1
	call	writeVal			; display sum in string form
	call	CrLf
	call	CrLf

	loop	populateArray

	popad
	pop		ebp
	ret		44

getInput	ENDP



readVal		PROC
; Procedure: Displays instruction, gets string from user, varifies string is numeric value
; that can fit inside 32-bit register. Displays error message if not valid number.
; Receives: LENGTHOF string1, OFFSETS of: instruct, string1, num, error
; Returns: 20 bytes off stack. Changed variables: string1, num
; Preconditions: None.
; Post-conditions: Valid numeric input must be made. Must be numeric value small enough to fit in 32-bit register
; Registers changed: EAX, EBX, ECX, EDX, ESI, EDI

	push	ebp
	mov		ebp, esp
	pushad

retryInput:	
	getString [ebp+8], [ebp+12], [ebp+16]		; OFFSET string1, LENGTHOF string1, OFFSET instruct
	call	CrLf
	mov		esi, [ebp+8]		; esi = OFFSET string1
	mov		eax, [ebp+24]		; eax = OFFSET num
	mov		ebx, 0				; starting value of num
	mov		[eax], ebx			; set value of num to 0 each iteration/each invalid input
	mov		ecx, 1				; ecx = flag for checking first character
	mov		edi, 0				; edi = flag for whether or not first charecter is '-'

; Iterate through input string
nextChar:
	mov		edx, 10				; Factor to multiply current 'number' by
	lodsb	
	cmp		ecx, 1
	jne		firstChecked
	cmp		al, 43				; Check if first character is '+'
	je		signedInt			
	cmp		al, 45				; Check if first character is '-'
	jne		firstChecked
	mov		edi, 1				; edi = flag to make num negative
signedInt:
	dec		ecx					; 'unflag' ecx/first character flag
	jmp		nextChar			; if + or -, load next byte
firstChecked:
	mov		ecx, [ebp+24]		; ecx = num address
	cmp		al, 0				; 0 byte marks end of user input
	je		finish
	cmp		al, 48				; ascii value for 0 decimal
	jl		errorMsg
	cmp		al, 57				; ascii value for 9 decimal
	jg		errorMsg			; must be between decimal 0-9
	
	sub		al, 48				; ascii value - 48 = numeric value, in al reg
	mov		bl, al				; bl = string byte numeric value
	mov		eax, [ecx]			; eax = value of num
	mul		edx					; eax = num * 10

; Make sure number size fits in 32 bit register	
	jo		errorMsg			; If overflow flag or sign flag set, number is too large
	js		errorMsg
	add		eax, ebx			; eax = num * 10 + current numeric value of string byte 
	jo		errorMsg
	
	mov		[ecx], eax			; change num to new value
	jmp		nextChar			; Continue until 0 byte or number too large

errorMsg:
	displayString	[ebp+20]	; Error message, num too large or not signed integer
	call	CrLf
	jmp		retryInput

finish:
	mov		eax, [ecx]			; eax = value of num entered
	cmp		edi, 1				; check negative flag
	jne		notNegative
	neg		eax					; negate/find 2's complement if negative
	mov		[ecx], eax			; change num to -num
notNegative:
	
	popad
	pop		ebp
	ret		20

readVal		ENDP



displayList	PROC
; Procedure: Displays an array of integers, in string form.
; Receives: ARRAYSIZE and OFFSETS of: display1, array, string1, string2, num, count
; Returns: 28 bytes off stack. Changed variables: string1, string2, num, count
; Preconditions: None.
; Post-conditions: All elements of array must be printed.
; Registers changed: EAX, EBX, ECX, EDX, ESI, EDI

	push	ebp
	mov		ebp, esp
	pushad

	displayString	[ebp+8]		; String for type of list displayed
	call	CrLf
	mov		esi, [ebp+16]		; esi = Address of array to be displayed
	mov		ecx, [ebp+12]		; ecx = ARRAYSIZE
	mov		edx, 1				; line counter
displayNext:	
	mov		eax, [esi]			; eax = array value at 'current' index

	mov		ebx, [ebp+24]		; ebx = OFFSET num
	mov		[ebx], eax

; Convert numeric value to string equivalent
	push	[ebp+32]			; OFFSET count
	push	[ebp+28]			; OFFSET string2
	push	[ebp+24]			; OFFSET num
	push	[ebp+20]			; OFFSET string1
	call	writeVal
	
	cmp		ecx, 1				; No need to diaplay comma/space after last value
	je		lastVal
	mov		al, ','
	call	WriteChar			; two spaces between each number
	mov		al, ' '
	call	WriteChar
	add		esi, 4				; esi = index for next array value

lastVal:
; Clear both strings
	push	[ebp+32]			; OFFSET count	
	push	[ebp+20]			; OFFSET string1
	call	clearString

	push	[ebp+32]			; OFFSET count
	push	[ebp+28]			; OFFSET string2
	call	clearString

	loop	displayNext
	call	CrLf
	call	CrLf

	popad
	pop		ebp
	ret		28

displayList	ENDP



writeVal	PROC
; Procedure: Converts an integer to it's string form (in reverse), reverses it to correct string, displays string
; Receives: OFFSETS of: string1, string2, count (length of string1), and OFFSET of numeric value to be converted
; Returns: 16 bytes off stack. Changed variables: count, string1.
; Preconditions: None.
; Post-conditions: Entire number must be converted to string.
; Registers changed: EAX, EBX, ECX, EDX, ESI, EDI

	push	ebp
	mov		ebp, esp
	pushad

	mov		edi, [ebp+8]		; address of string1
	mov		ecx, [ebp+12]		; address of num
	mov		eax, [ecx]			; eax = num value
	cmp		eax, 0				; If num is negative, negate value, flag esi
	jge		notNegative
	neg		eax					; 2's complement of num
	mov		esi, 1				; flag num as negative
notNegative:
	mov		ebx, 10				; Factor to divide num by
	mov		ecx, 0				; counter to count number of digits, to reverse/print string
	
nextChar:	
	cld
	mov		edx, 0				; clear edx
	div		ebx					; eax = num/10
	add		edx, 48				; Convert remainder to ascii
	push	eax					; store remaining num
	mov		eax, edx			; eax = remainder in ascii
	stosb						; store ascii value in string1. **stored in string in reverse order**
	inc		ecx					; increment count
	pop		eax					; restore remaining num (num/10, without remainder)
	cmp		eax, 0				; If full value not divided out, repeat for next character
	jne		nextChar
	cmp		esi, 1				; Check whether negative
	jne		notNeg
	mov		al, 45
	stosb						; store '-' at end of string
	inc		ecx					; increment count of string for '-'
notNeg:
	mov		ebx, [ebp+20]		; count/LENGTH OF string
	mov		[ebx], ecx			; update count

; Reverse string to show aligned numeric value
	push	[ebp+20]			; OFFSET count
	push	[ebp+16]			; OFFSET string2
	push	[ebp+8]				; OFFSET string1
	call	reverseString

	popad
	pop		ebp
	ret		16

writeVal	ENDP



reverseString	PROC
; Procedure: Reverses a string and displays it.
; Receives: OFFSET of: display1, array, string1, string2, num, count
; Returns: 12 bytes off stack. Changed variable: string2 (reversed string of string1)
; Preconditions: None.
; Post-conditions: All elements of array must be printed.
; Registers changed: EAX, EBX, ECX, EDX, ESI, EDI

	push	ebp
	mov		ebp, esp
	pushad

	mov		ebx, [ebp+16]		; ebx = OFFSET count
	mov		ecx, [ebx]			; ecx = value count
	mov		esi, [ebp+8]		; esi = OFFSET string1
	add		esi, ecx			; esi + length of string1
	dec		esi					; last byte of string1
	mov		edi, [ebp+12]		; edi = OFFSET string2
reverse:
	std							; reverse direction flag
	lodsb						; load last letter in string1
	cld							; clear direction flag
	stosb						; store last letter in string2
	loop	reverse				; repeat for entire string1
	
	displayString	[ebp+12]	; display string2 (aligned numeric string)
	
; Clear both strings for next use
	push	[ebp+16]			; OFFSET count
	push	[ebp+8]				; OFFSET string1
	call	clearString

	push	[ebp+16]			; OFFSET count	
	push	[ebp+12]			; OFFSET string2
	call	clearString

	popad
	pop		ebp
	ret		12

reverseString	ENDP



clearString	PROC
; Procedure: Empties/clears a string variable.
; Receives: OFFSET of string, OFFSET of count (length of string)
; Returns: 8 bytes off stack. Clears string variable.
; Preconditions: None.
; Post-conditions: Entire string must be cleared
; Registers changed: EAX, EBX, ECX, EDI
	push	ebp
	mov		ebp, esp
	pushad

	mov		eax, 0				; eax = 0 byte
	mov		edi, [ebp+8]		; edi = address of string to be cleared
	mov		ebx, [ebp+12]		; ebx = address of count
	mov		ecx, [ebx]			; ecx = count value (length of string)
	cld
	rep		stosb               ; store 0 byte in string, repeat for length of string

	popad
	pop		ebp
	ret		8

clearString	ENDP



totalSum	PROC
; Procedure: Displays displaySum and then displays sum as a string.
; Receives: OFFSET of: string1, string2, sum, count
; Returns: 20 bytes off stack. A printed array of numeric strings, each separated by a comma and space
; Preconditions: None.
; Post-conditions: None.
; Registers changed: None.

	push	ebp
	mov		ebp, esp
	pushad

	displayString	[ebp+24]

	push	[ebp+20]			; OFFSET count
	push	[ebp+16]			; OFFSET string2
	push	[ebp+8]				; OFFSET sum
	push	[ebp+12]			; OFFSET string1
	call	writeVal
	call	CrLf
	call	CrLf

	popad
	pop		ebp
	ret		20

totalSum	ENDP



findAverage	PROC
; Procedure: Finds the average of all input numbers and displays displayAvg and the average as a string
; Receives: ARRAYSIZE and OFFSETS of: displayAvg, string1, string2, num, sum, count
; Returns: 24 bytes off stack. num
; Preconditions: None.
; Post-conditions: None.
; Registers changed: EAX, EBX, ECX

	push	ebp
	mov		ebp, esp
	pushad

	mov		ebx, [ebp+8]		; OFFSET sum
	mov		eax, [ebx]			; value of sum
	mov		ecx, [ebp+12]		; ARRAYSIZE
	cdq
	idiv	ecx
	mov		ebx, [ebp+32]		; ebx = OFFSET average
	mov		[ebx], eax			; average value = sum/ARRAYsize (average, rounded down)

	displayString	[ebp+28]

	push	[ebp+24]			; OFFSET count
	push	[ebp+20]			; OFFSET string2
	push	[ebp+32]			; OFFSET average
	push	[ebp+16]			; OFFSET string1
	call	writeVal
	call	CrLf
	call	CrLf

	popad
	pop		ebp
	ret		24

findAverage	ENDP



farewell	PROC
; Procedure: Displays a farewell message.
; Receives: OFFSET goodbye
; Returns: 4 bytes off stack. No variables changed.
; Preconditions: None.
; Post-conditions: None.
; Registers changed: None.

	push	ebp
	mov		ebp, esp
	pushad

	displayString	[ebp+8]
	call	CrLf

	popad
	pop		ebp
	ret		4

farewell	ENDP


END main
