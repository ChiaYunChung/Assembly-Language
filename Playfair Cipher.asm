; IDIV Examples             (Idiv.asm)

; This program shows examples of various IDIV formats.

INCLUDE Irvine32.inc

BUFMAX = 128
.data
val			BYTE 5
val2		WORD ?
val3		WORD ?
val5		WORD ?
val6		WORD ?
val4		WORD -1
addre		DWORD ?
Welc		BYTE "Please input the plaintext:",0
Modi		BYTE "Modified plaintext:",0
Cipher		BYTE "The ciphertext is:",0
Plaintext	BYTE 128 DUP(?)
Ciphertext	BYTE 128 DUP(?)
Ciphertext2	BYTE 128 DUP(?)
Modif		BYTE 128 DUP(?)
PlayfairKey BYTE 'M','O','N','A','R'
Rowsize	= ($ - PlayfairKey)
		BYTE 'C','H','Y','B','D'
		BYTE 'E','F','G','I','K'
		BYTE 'L','P','Q','S','T'
		BYTE 'U','V','W','X','Z'
bufSize		DWORD  ?

.code
main PROC
    mov		edx,OFFSET Welc  
	call	WriteString
	call	Crlf

	mov		ecx,BUFMAX
	mov		edx,OFFSET Plaintext
	call	ReadString
	;call	WriteString
	push	OFFSET PlayfairKey
	push	OFFSET Ciphertext
	push	OFFSET Plaintext
	call	Playfair

	exit
main ENDP
;---------------------------------------------------------
Playfair PROC
	push	ebp
	mov		ebp,esp
	mov		esi,[ebp+8]		;Plaintext
	mov		edi,[ebp+12]	;Ciphertext
	call	lowertoCap
	call	Modified
	mov		edx,edi
	call	WriteString
	call	Crlf
	mov		edi,OFFSET Ciphertext2
	mov		addre,edi
	mov		edi,[ebp+16]
	call	ToCipher
	mov		edi,OFFSET Ciphertext2
	mov		edx, edi
	call	WriteString
	pop		ebp
ret
Playfair ENDP

;---------------------------------------------------------
lowertoCap PROC
	mov		ecx,eax
	push	edi
L1: 
    mov     bl, [esi]  
    cmp     bl, 'a'   
    jb      checkU  
    cmp     bl, 'z'       
    ja      checkU    
    sub     bl, 32  
checkU:
	cmp		bl,'J'
	je		toI
	jmp		con
toI:
	mov		bl,'I'
con:
	cmp     bl, 'A'   
    jb      notUL  
    cmp     bl, 'Z'       
    ja      notUL 
	mov     [edi], bl
	inc     edi
notUL:
    inc     esi        
    loop    L1   
	pop		edi
ret
lowertoCap ENDP

;---------------------------------------------------------
Modified PROC
	mov		esi,edi
	mov		edi,OFFSET Modif
	push	edi
L3:
	mov		al,[esi]
	cmp		al,0
	je		goout
	mov		bl,[esi+1]
	cmp		al,bl
	je		addX
	jmp		two
	
addX:
	mov		[edi],al
	mov		BYTE PTR [edi+1],'X'
	mov		BYTE PTR [edi+2],' '
	add		esi,1
	add		edi,3
	jmp		L3
two:
	mov		[edi],al
	mov		[edi+1],bl
	mov		BYTE PTR [edi+2],' '
	add		esi,2
	add		edi,3
	jmp		L3
goout:
	sub		edi,3
	cmp		bl,0
	jne		goout2
	mov		BYTE PTR [edi+1],'X'
goout2:
	pop		edi
ret
Modified ENDP

;---------------------------------------------------------
ToCipher PROC
	
	mov		esi,OFFSET Modif
	mov		eax,edi

	push	edi
	push	eax
L4:
	mov		ecx,LENGTHOF Modif
	mov		al,[esi]
	cmp		al,0
	je		goout3
	cld
	repne	scasb
	pop		eax
	push	eax
	dec		edi
	sub		eax,edi
	mul		val4
	div		val
	;mov		edi,addre
	mov		BYTE PTR val2,al
	mov		BYTE PTR val3,ah

	pop		eax
	pop		edi
	push	edi
	push	eax
	
	mov		al,[esi+1]
	cld
	repne	scasb	
	
	pop		eax
	push	esi
	dec		edi
	push	eax
	sub		eax,edi
	mul		val4
	div		val
	mov		BYTE PTR val5,al
	mov		BYTE PTR val6,ah

	mov		ax,val2
	mov		bx,val5
	cmp		ax,bx
	je		samer
	mov		ax,val3
	mov		bx,val6
	cmp		ax,bx
	je		samec
	jmp		dif
samer:
	mov		ebx,OFFSET PlayfairKey
	;mov		edi,addre
	mov		eax,Rowsize
	Imul	ax,WORD PTR val2
	add		ebx,eax
	movzx	esi,val3
	add		esi,1
	cmp		esi,5
	jne		neq
	sub		esi,5
neq:
	mov		al,[ebx+esi]
	;mov		edi,OFFSET Ciphertext2
	mov		edi,addre
	mov		[edi],al
	movzx	esi,val6
	add		esi,1
	cmp		esi,5
	jne		neq2
	sub		esi,5
neq2:
	mov		al,[ebx+esi]
	mov		[edi+1],al
	jmp		L5

samec:
	;mov		edi,addre
	mov		ebx,OFFSET PlayfairKey
	mov		eax,Rowsize
	movzx	esi,val2
	add		esi,1
	cmp		esi,5
	jne		neq3
	sub		esi,5
neq3:
	mov		WORD PTR val2,si
	Imul	ax,WORD PTR val2
	add		ebx,eax
	movzx	esi,val3
	mov		al,[ebx+esi]
	;mov		edi,OFFSET Ciphertext2
	mov		edi,addre
	mov		[edi],al
	mov		ebx,OFFSET PlayfairKey
	mov		eax,Rowsize
	movzx	esi,val5
	add		esi,1
	cmp		esi,5
	jne		neq4
	sub		esi,5
neq4:
	mov		WORD PTR val5,si
	Imul	ax,WORD PTR val5
	add		ebx,eax
	movzx	esi,val3
	mov		al,[ebx+esi]
	;mov		edi,OFFSET Ciphertext2
	mov		[edi+1],al

	jmp		L5
dif:
	mov		ebx,OFFSET PlayfairKey
	mov		eax,Rowsize
	Imul	ax,WORD PTR val2
	add		ebx,eax
	movzx	esi,val6
	mov		al,[ebx+esi]
	
	;mov		edi,OFFSET Ciphertext2
	mov		edi,addre
	mov		[edi],al
	mov		ebx,OFFSET PlayfairKey
	mov		eax,Rowsize
	Imul	ax,WORD PTR val5
	add		ebx,eax
	movzx	esi,val3
	mov		al,[ebx+esi]
	mov		[edi+1],al

L5:
	
	mov		BYTE PTR [edi+2],' '
	add		edi,3
	mov		addre,edi
	pop		edi
	
	pop		esi
	pop		eax
	add		esi,3
	push	eax
	push	eax
	
	jmp		L4
goout3:
	pop		eax
	pop		eax
	;pop		eax
ret
ToCipher ENDP

END main