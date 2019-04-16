;Villabrille, Aleimar
;2015-11395

;CMSC131 Final Project

JMP START
;User prompts messages
MSG0	DB 'INPUT INFIX STRING AND PRESS [ENTER] WHEN DONE $'
MSG1 	DB 0AH, 0AH, 'Enter INFIX String: $'
MSG2	DB 'Equivalent POSTFIX String: $'
MSG3	DB 0AH, 0DH, 'Evaluated answer: $'
;STRINGS
STRING2 DB 50 DUP('$')	;the postfix string
STRING DB 50 DUP('$')	;infix string
STRING3 DB 10 DUP('$')	;string for evaluated answer
COUNT DB 0


START:
;Clrscr() for convenience/aesthetics
MOV AX, 03H
INT 10H

;Instruction for the program
MOV AH, 09H
LEA DX, MSG0
INT 21H


MOV AH, 09H
LEA DX, MSG1
INT 21H			;scan the infix expression

CLD
LEA DI, STRING	;save to the infix expression string
MOV CX, 50

;scan each infix character
INPUTLOOP:
	MOV AH,1
	INT 21H
	CMP AL, 0DH	;if char is operand
	JE DONE
	STOSB
LOOP INPUTLOOP
JMP DONE

DONE:
MOV AL, 29H
STOSB

MOV BL, 28H
PUSH BX

MOV AH, 09H
LEA DX, MSG2
INT 21H

CLD
;postfix string
LEA DI, STRING2
;infix string
LEA SI, STRING


MOV BL, 50
SUB BL, CL
MOV CL, BL
MOV BL, 0
INC CX
MOV COUNT, CL

MOV AX, 0

OUTDISP:

	MOV AH, 0
	LODSB
;is '('
	CMP AL, 28H
	JE PUSH_CHAR

;is ')'
	CMP AL, 29H
	JE FLUSH

;is operator
	CALL IS_OPP

;is operand
	STOSB
	JMP OUTL

OUTL:
LOOP OUTDISP

;Displays postfix string
MOV AH, 09H
LEA DX, STRING2
INT 21H


MOV AH, 09H
LEA DX, MSG3
INT 21H

;Calls Evaluation Function
CALL EVALUATION

;Displays Evaluated Answer
MOV AH, 09H
LEA DX, STRING3
INT 21H

INT 20H		;end

;push if '('
PUSH_CHAR:
DEC COUNT
MOV BH, 00H
MOV BL, AL
PUSH BX
JMP OUTL

;if character is an operator
IS_OPP:
CMP AL, 2BH
JE PLUS
CMP AL, 2DH
JE MINUS
CMP AL, 2AH
JE TIMES
CMP AL, 2FH
JE DIVIDE
RET

;check if current character is '+'
PLUS:
MOV AH, 02H
JMP CAL

;check if current character is '-'
MINUS:
MOV AH, 01H
JMP CAL

;check if current character is '*'
TIMES:
MOV AH, 04H
JMP CAL

;check if current character is '/'
DIVIDE:
MOV AH, 03H
JMP CAL

CAL:
POP BX
POP BX
JMP COMP
OPP:
XCHG BX, AX
CMP AL, 28H
JE AFTER2
CMP AL, 29H
JE AFTER2
STOSB
JMP AFTER2
AFTER2:
MOV AX, BX
POP BX
JMP COMP

COMP:
CMP BH, AH
JGE OPP
PUSH BX
MOV BX, AX
PUSH BX
JMP OUTL

;finding the matching opening parenthesis
FLUSH:
DEC COUNT
POP BX
JMP COMP2


OPP2:
MOV AX, BX
CMP AL, 28H
JE AFTER
CMP AL, 29H
JE OUTL
STOSB
JMP AFTER
AFTER:
POP BX
JMP COMP2

;checking if the top of the stack is currently '('
COMP2:
CMP BL, 28H
JNE OPP2
MOV BX, 0000H 
JMP OUTL

;process for evaluation
EVALUATION:
CLD
LEA SI, STRING2		
MOV CL, COUNT
EVAL:
	LODSB			;scanning the current character of postfix expression
	CMP AL, 30H		;check if character is an operator
	JL IS_OPERATION
	CMP AL, '$'		;check if this end of string of postfix operation
	JE AFTEREVE
	MOV AH, 0
	SUB AL, '0'
	PUSH AX	
	JMP CONT

	CONT:
LOOP EVAL
JMP AFTEREVE


AFTEREVE:
POP AX
LEA SI, STRING3		
CALL HEX2DEC	;convert the answer to hex
RET

;character is an operator
IS_OPERATION:
MOV DL, AL
POP AX
MOV BL, AL
POP AX

CMP DL, 2BH		;character is '+'
JE ADDITION
CMP DL, 2DH		;character is '-'
JE SUBTRACTION
CMP DL, 2AH		;character is '*'
JE MULTIPLICATION
CMP DL, 2FH		;character is '/'
JE DIVISION
JMP CONT

;for getting the sum
ADDITION:
ADD AL, BL
PUSH AX
JMP CONT

;for getting the difference
SUBTRACTION:
SUB AL, BL
PUSH AX
JMP CONT

;for getting the product
MULTIPLICATION:
MUL BX
PUSH AX
JMP CONT

;for getting the quotient
DIVISION:
DIV BL
PUSH AX
JMP CONT

;converting the evaluated value to decimal
HEX2DEC:
MOV CX, 0
MOV BX, 10
JMP LOOP1

LOOP1:
MOV DX,0
DIV BX
ADD DL, 30H
PUSH DX
INC CXs
CMP AX, 9
JG LOOP1

OR AL, 30H
MOV [SI], AL

;shows the evaluated answer;
LOOP2:
POP AX
INC SI
MOV [SI],AL
LOOP LOOP2
RET
