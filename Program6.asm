

; Author: ShengTso Andrew Wu
; OSU email address: wusheng@oregonstate.edu
; Course number/section: CS271-400


INCLUDE Irvine32.inc

; Constant Definitions
ARRAYSIZE = 10

;Macros
; ---------------------------------------------------------
; DisplayString Macro displays string at memory location  
; Receives: offset of string 
; Returns: none
; Pre-conditions: none
; Registers changed: edx
; ---------------------------------------------------------

displayString  MACRO     inputString
	push 	edx
	mov 	edx, inputString
	call 	writestring
	pop 	edx                                                 
ENDM

; ---------------------------------------------------------
; GetString Macro that displays prompt and gets the user's keyboard 
; input into a memory location 
; Receives: OFFSETs of prompt to display, storage for string, 
;			storage length, buffer
; Returns: none
; Pre-conditions: none
; Registers changed: edx, ecx, edi
; ---------------------------------------------------------

getString	MACRO	promptString, numBuffer, stringSize, bufferSize
		
	push	edx
	push	ecx
	push	edi

	mov		edx, promptString										; Set up WriteString
	call	WriteString
	mov		edx, numBuffer											; Set up ReadString
	mov		ecx, bufferSize
	call	ReadString
	mov		edi, stringSize											; Store length of string
	mov		[edi], eax

	pop		edi
	pop		ecx
	pop		edx		
	
ENDM

.data

; variable definitions

intro1			BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",0
intro2			BYTE		"Written by: Andrew Wu",0
instruct1		BYTE		"Please provide 10 signed decimal integers.",0
instruct2		BYTE		"Each number needs to be small enough to fit inside a 32 bit register.",0
instruct3		BYTE		"After you have finished inputting the raw numbers I will display a list ",0
instruct4		BYTE		"of the integers, their sum, and their average value.",0
displaymsg		BYTE		"You entered the following numbers:",0
userMsg			BYTE		"Please enter an signed number: ",0
sumMsg			BYTE		"The sum of these numbers is: ",0
avgMsg			BYTE		"The rounded average is: ",0
goodBye			BYTE		"Thanks for playing!",0
comma			BYTE		", ",0
errorMsg		BYTE		"ERROR: You did not enter a signed number or your number was too big.", 0
repeatMsg		BYTE		"Please try again: ", 0
list			SDWORD		ARRAYSIZE DUP (?)
upperbound		SDWORD		 +2147483647
lowerbound		SDWORD		-2147483648
bufferSize		DWORD		13

buffer		BYTE	ARRAYSIZE+1 DUP (0)
bufferOut	BYTE	ARRAYSIZE+1 DUP (?)
byteCount	SDWORD	?
loopCount	SDWORD	?
sum			SDWORD	0
avg			SDWORD	0


.code
main PROC

;to display introduction. 
push		OFFSET intro1
push		OFFSET intro2
call		introduction

;tdisplay instructions. 
push		OFFSET instruct1
push		OFFSET instruct2
push		OFFSET instruct3
push		OFFSET instruct4
call		instruction

;to read in user values
push		bufferSize
push		OFFSET	userMsg											
push		OFFSET	errorMsg										
push		OFFSET	repeatMsg											
push		OFFSET	list											
push		OFFSET	buffer											
push		OFFSET	byteCount										
push		ARRAYSIZE												
push		upperbound												
push		lowerbound													
push		OFFSET loopCount										
call		readVal

; to calculate values to be displayed
push		OFFSET list											
push		ARRAYSIZE												
push		OFFSET sum											
push		OFFSET avg											
call		calculations

;to display calculations
push		OFFSET displaymsg				;52									
push		OFFSET comma					;48										
push		OFFSET sumMsg					;44										
push		OFFSET avgMsg					;40						
push		OFFSET list						;36					
push		sum								;32						
push		avg								;28					
push		ARRAYSIZE						;24						
push		OFFSET bufferOut				;20						
call		displayResults

;to display goodbye message. 
push		OFFSET goodbye
call		farewell

	exit	; exit to operating system
main ENDP

; ---------------------------------------------------------
; Procedure to display program title and  programmer's name.
; receives: Parameters on the system stack. 
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------

introduction	PROC
	pushad
	mov				ebp, esp
	displayString	[ebp + 40]								;"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures"
	call			CrLF
	displayString	[ebp + 36]								;"Written by: Andrew Wu"
	call			CrLf
	call			CrLf
	popad
	ret		8
introduction	ENDP


; ---------------------------------------------------------
; calculate sum and average.
; receives: Parameters on the system stack. 
; Returns: None
; Pre-conditions: filled array of 10 ints
; Registers changed: ebp, esp, eax, ebx, edx, esi, edi
; ---------------------------------------------------------
calculations	PROC	
	push	eax
	push	ebx
	push	edx
	push	esi
	push	edi
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp + 40]											; @list
	mov		ecx, [ebp + 36]											; ARRAYSIZE	
	mov		edx, 0													; edx to hold sum while in calcVal
	mov		edi, [ebp + 32]											; sum
	cld

more:
	lodsd
	add		edx, eax												; calculate sum 
	loop	more

	mov		[edi], edx												; store sum in sum 

; average
	mov		eax, [edi]												;sum
	cdq
	mov		ebx, [ebp + 36]											;ArraySize / 10
	idiv	ebx
	cmp		edx, 5
	jl		skip
	inc		eax
skip:
	mov		edi, [ebp + 28]											;store average in avg
	mov		[edi], eax

	pop		edi
	pop		esi
	pop		edx
	pop		ebx
	pop		eax
	pop		ebp
	ret		16
calculations	ENDP

; ---------------------------------------------------------
; Procedure to display program instructions
; receives: Parameters on the system stack. 
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------

instruction		PROC
	pushad
	mov				ebp, esp

	displayString	[ebp + 48]								;"Please provide 10 signed decimal integers."	
	call			CrLf
	displayString	[ebp + 44]									
	call			CrLf
	displayString	[ebp + 40]								
	call			CrLf
	displayString	[ebp + 36]									
	call			CrLf
	call			CrLf
	popad
	ret				12

instruction		ENDP


; ---------------------------------------------------------
; Call gettString macro to get input. Convert to int and validate.
; receives: Parameters on the system stack. 
; Returns: None
; Pre-conditions: introduction and instructions
; Registers changed: ebp, esp, ecx, esi, eax, edx, ebx
; ---------------------------------------------------------
readVal	PROC

	push	ebp
	push	ecx
	push	esi
	push	eax
	push	edx
	push	ebx
	mov		ebp, esp

; outer loop control
	mov		ecx, [ebp + 40]											; ARRAYSIZE

; receiving list
	mov		edi, [ebp + 52]

;to get user input via getstring
outerL:
	getString	[ebp + 64], [ebp + 48], [ebp + 44], [ebp + 68]		; getString(prompt, buffer, count, buffersize)
	mov		ebx, [ebp + 28]											; Save outerLoop counter to loopCount
	mov		[ebx], ecx
	jmp		checkStr

; Get numbers with different prompt script (if previous input had error)
outerLInvalid:
	getString	[ebp + 56], [ebp + 48], [ebp + 44], [ebp + 68]
	mov		ebx, [ebp + 28]											; Save outerLoop counter to loopCount
	mov		[ebx], ecx
	jmp		checkStr

rtnToOuter:
	loop	outerL

; Go through string and validate if it is a signed number.
checkStr:
	mov		esi, [ebp + 44]											; Get length of string and put into ecx
	mov		ecx, [esi]												
	cmp		ecx, 11													; Invalid string if length is more than 11 chars
	jg		invalid
	mov		esi, [ebp + 48]											; Set source to buffer index
	mov		edx, 0													; Edx will store converted number string
	mov		eax, 0													; Eax will store each digit
	mov		ebx, 1													; Ebx = 1 if pos num, Ebx = -1 if neg num
	cld

; See if first character is a sign or a number
	mov		al, [esi]												; Don't use lodsb to not inc esi
	cmp		al, '-'
	je		negNum
	cmp		al, '+'
	je		posNum
	jmp		noSign

; If negative number, reduce length counter and store -1 to ebx to convert whole number later.
negNum:
	dec		ecx
	cmp		ecx, 0													; Number is only a sign so invalid
	je		invalid
	mov		ebx, -1
	inc		esi														; Move to next char
	jmp		innerLoop

; If positive number, reduce length counter and store 1 to ebx to convert whole number later.
posNum:
	dec		ecx
	cmp		ecx, 0
	je		invalid
	mov		ebx, 1
	inc		esi														; Move to next char
	jmp		innerLoop

; If number has no sign, it is a positive, store 1 to ebx but don't touch length counter
noSign:
	mov		ebx, 1
	jmp		innerLoop

; Check rest of numbers in number string if invalid. If valid, convert ASCII to num and add digits.
innerLoop:
	imul	edx, 10													; Multiply by 10 to be able to add more digits
	jo		invalid
	lodsb
	cmp		al, 57													; Check if greater than 9
	ja		invalid
	cmp		al, 48													; Check if less than 0
	jb		invalid
	sub		al, 48													; Convert ASCII to number
	add		edx, eax												; Add digit to previous number
	loop	innerLoop												; Valid digit so go to next digit		
	jmp		convertSigned											; Valid number so convert per sign

; Number is not a signed number or number is too big
invalid:
	displayString	[ebp + 60]
	call	CrLf
	mov		ebx, [ebp + 28]											; Get back outer loopCount
	mov		ecx, [ebx]
	jmp		outerLInvalid											; Not loop. Don't want to touch ecx.

; Convert whole number to positive or negative number
convertSigned:
	imul	edx, ebx
	cmp		ebx, -1
	je		checkNegRange
	jmp		checkPosRange

; Check if positive num is within range
checkPosRange:
	mov		eax, edx
	cmp		[ebp + 36], edx											; Check if higher than upper range
	jo		invalid
	jmp		storeNum

; Check if negative num is within range
checkNegRange:
	mov		eax, edx
	cmp		[ebp + 32], edx											; Check if lower than lower range
	jo		invalid
	jmp		storeNum

; Valid number so store number into array
storeNum:
	mov		eax, edx
	stosd
	jmp		returnOuter

; innerLoop finished so go back to outerLoop for next number in array
returnOuter:
	mov		ebx, [ebp + 28]											; Get back outer loopCount
	mov		ecx, [ebx]
	cmp		ecx, 1													; If at last number, finish proc.
	je		procDone
	jmp		rtnToOuter

; Pop used registers
procDone:
	call	CrLf
	pop		ebx
	pop		edx
	pop		eax
	pop		esi
	pop		ecx
	pop		ebp

	ret		44

readVal	ENDP

; ---------------------------------------------------------
; Convert a numeric value to a string of digits and use
; displayString macro.
; receives: Parameters on the system stack. 
; Returns: None
; Pre-conditions: OFFSET of bufferOut and number to be displayed pushed into stack.
; Registers changed: ebp, esp, esi, edi, ecx, eax, ebx, edx
; ---------------------------------------------------------
writeVal	PROC

	push	ebp
	push	esi
	push	edi
	push	ecx
	push	eax
	push	ebx
	push	edx

	mov		ebp, esp

; Set up source, destination, and initialize digits counter to 0.
	mov		esi, [ebp+36]											; Number in stack
	mov		edi, [ebp+32]											; bufferOut
	mov		ecx, 0													; digits counter
	cld

; Count how many digits in number
	mov		eax, esi
	mov		ebx, 10
countDig:
	cdq
	idiv	ebx
	inc		ecx
	cmp		eax, 0													; If no more digits, go to checkSign
	je		checkSign
	jmp		countDig

; Check if value is positive or negative
checkSign:
	test	esi, esi
	js		negNum
	jmp		posNum

; If negative number, add '-' character and turn number into positive.
negNum:
	mov		al, '-'
	mov		[edi], al												
	mov		ebx, -1
	imul	esi, ebx
	jmp		preDigLoop

; If positive, don't add a character and decrease edi pointer.
posNum:
	dec		edi
	jmp		preDigLoop

; Go through digits and store as characters in bufferOut
preDigLoop:
	mov		eax, esi												; Set up iDiv
	mov		ebx, 10
	add		edi, ecx												; Move forward in bufferOut depending on how many digits in number
;  Add 0 to end of string
	inc		edi														; Go forward a byte to add 0
	mov		edx, 0
	mov		[edi], edx
	dec		edi														; Go back to where digits should go
	std																; Reverse flag

; Loop through digits in reverse with idiv and store ascii equivalent of remainder to bufferOut.
digLoop:
	cdq
	idiv	ebx
	mov		ebx, eax												; Store quotient at ebx
	add		dl, 48													; Get ascii for digit at remainder
	mov		al, dl													; Put rem into eax for stosd
	stosb
	mov		eax, ebx												; Store back quotient to eax
	mov		ebx, 10
	mov		edx, 0
	loop	digLoop	

; Invoke displayString to produce output
	displayString	[ebp+32]

	pop		edx
	pop		ebx
	pop		eax
	pop		ecx
	pop		edi
	pop		esi
	pop		ebp

	ret		8

writeVal	ENDP

; ---------------------------------------------------------
; Display list, sum, and avg
; receives: Parameters on the system stack. 
; Returns: None
; Pre-conditions: valid list, sum, avg
; Registers changed: ebp, esp, edx, eax, esi
; ---------------------------------------------------------
displayResults	PROC

	push	ebp
	push	eax
	push	edx	
	push	esi
	mov		ebp, esp

	displayString	[ebp + 52]										; "You entered the following numbers:"
	call	CrLf
									
	mov		esi, [ebp + 36]											; @list
	mov		ecx, [ebp + 24] 										; ARRAYSIZE	/ 10 - loop control
	cld

display:															; iterate through list and call writeVal.													
	lodsd
	push			eax												; Push to stack to writeVal
	push			[ebp + 20]
	call			writeVal
	cmp				ecx, 1											; if last element, dont display comma
	je				displaySum
	displayString	[ebp + 48]										;", "
	loop			display		

displaySum:															; Display sum by calling writeVal.
	call			CrLf	
	displayString	[ebp + 44]										; "The sum of these numbers is: "
	push			[ebp + 32]										; Set up WriteVal
	push			[ebp + 20]
	call			writeVal	
	call			CrLf		

	displayString	[ebp + 40]										; "The rounded average is: "
	push			[ebp + 28]										; push average
	push			[ebp + 20]										; push out
	call			writeVal	
	call			CrLf
	call			CrLf

	pop				esi	
	pop				edx
	pop				eax
	pop				ebp
	ret				32

displayResults	ENDP

; ---------------------------------------------------------
; Procedure to display program farewell.
; receives: Parameters on the system stack. 
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------

farewell	PROC
	pushad
	mov		ebp, esp

	displayString [ebp + 36]								;"Thanks for playing"
	call	CrLf
	call	CrLf
	popad
	ret		
farewell	ENDP


END main
