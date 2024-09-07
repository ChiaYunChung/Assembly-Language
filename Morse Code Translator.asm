; IDIV Examples             (Idiv.asm)

; This program shows examples of various IDIV formats.

INCLUDE Irvine32.inc

BUFMAX = 128
.data

Welc	BYTE "This is a Morse Code Translator! ",0
Input	BYTE "Please enter your string:",0
Output	BYTE "Morse Code:",0
Again	BYTE "Would you like to proceed another translation (y/n)?",0
prompt	DWORD 128 DUP(?)
upper	DWORD 128 DUP(?)
morse	DWORD 128 DUP(?)
bufSize DWORD  ?

;Alphabet
Alphabet	BYTE "._",0,0,0,0,0,0
            BYTE "_...",0,0,0,0
            BYTE "_._.",0,0,0,0
            BYTE "_..",0,0,0,0,0
            BYTE ".",0,0,0,0,0,0,0
            BYTE ".._.",0,0,0,0
            BYTE "__.",0,0,0,0,0
            BYTE "....",0,0,0,0
            BYTE "..",0,0,0,0,0,0
            BYTE ".___",0,0,0,0
            BYTE "_._",0,0,0,0,0
            BYTE "._..",0,0,0,0
            BYTE "__",0,0,0,0,0,0
            BYTE "_.",0,0,0,0,0,0
            BYTE "___",0,0,0,0,0
            BYTE ".__.", 0,0,0,0
            BYTE "__._", 0,0,0,0
            BYTE "._.",0,0,0,0,0
            BYTE "...",0,0,0,0,0 
            BYTE "_",0,0,0,0,0,0,0
            BYTE ".._",0,0,0,0,0 
            BYTE "..._",0,0,0,0
            BYTE ".__",0,0,0,0,0 
            BYTE "_.._",0,0,0,0
            BYTE "_.__",0,0,0,0
            BYTE  "__..",0,0,0,0
Numerals	BYTE "_____",0,0,0
            BYTE".____",0,0,0
            BYTE"..___",0,0,0
            BYTE"...__",0,0,0
            BYTE"...._",0,0,0
            BYTE".....",0,0,0
            BYTE"_....",0,0,0
            BYTE"__...",0,0,0
            BYTE"___..",0,0,0
            BYTE"____.",0,0,0
Punctuation	BYTE "._._._",0,0
            BYTE"__..__",0,0
            BYTE"..__..",0,0
            BYTE"_.__._",0,0
            BYTE".____.",0,0
            BYTE"_._._.",0,0
            BYTE"___...",0,0
            BYTE"._.._.",0,0
            BYTE"_...._",0,0
            BYTE"_.._.",0,0,0
            BYTE"..._.._",0

.code
main PROC
re:
	mov		edx,OFFSET Welc  
	call	WriteString
	call	Crlf
	mov		ecx,BUFMAX
	mov		edx,OFFSET prompt
	call	ReadString
	mov		ecx,eax
	mov		bufSize,eax
	mov		eax,edx
	mov		edx,OFFSET upper
	call	lowertoCap
	mov		edx,OFFSET upper
	call	WriteString
    call	Crlf
    call    MorseTran
    call	Crlf
    mov		edx,OFFSET Again
	call	WriteString
    mov     ecx, BUFMAX
    mov		edx,OFFSET prompt
    call	ReadString
    cmp     byte ptr [prompt],'y'
    je      re
	exit
main ENDP

lowertoCap PROC
	;mov     esi, eax        
    ;mov     edi, edx     
L1: 
    mov     bl, [eax]  
    cmp     bl, 'a'   
    jb      notLower  
    cmp     bl, 'z'       
    ja      notLower    
    sub     bl, 32      
notLower:
    mov     [edx], bl   
    inc     eax        
    inc     edx       
    loop    L1         
ret
lowertoCap ENDP

MorseTran PROC
    mov		ecx,bufSize
    mov     eax,OFFSET upper
	mov		esi, eax
	mov		edi, OFFSET morse
L2:
    cmp     ecx, 0            ; Check if string ends
    je      EndTranslation
    dec ecx
	mov		al, [esi]
	inc		esi
    
	cmp		al, 'A'
    jb		CheckDigit
    cmp		al, 'Z'
    jbe		ConvertToMorse
    jmp		ProcessChar

CheckDigit:
    cmp     al, '0'
    jb      CheckSpace
    cmp     al, '9'
    jbe     ConvertToMorseDigit
    jmp     ProcessChar

CheckSpace:
    cmp     al, ' '
    je      PrintSpace
    ;jmp     PrintError
    jmp     ProcessChar

PrintSpace:
    mov     al, '/'
    mov     dl, al
    call    WriteChar
    jmp     L2

PrintError:
    mov     al, '@'
    mov     dl, al
    call    WriteChar
    jmp     L2

ConvertToMorse:
    sub     al, 'A'  
    movzx   ebx, al
    lea     ebx, [Alphabet + ebx * 8]
    mov     edx,ebx
    call    WriteMorse  
    jmp     L2

ConvertToMorseDigit:
    sub     al, '0'   
    movzx   ebx, al
    lea     ebx, [Numerals + ebx * 8] 
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2

ProcessChar:
    cmp     al, '.'
    je      Period
    jmp     next
Period:
    mov     ebx,0
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next:
    cmp     al, ','
    je      Comma
    jmp     next2
Comma:
    mov     ebx,1
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next2:
    cmp     al, '?'
    je      Question
    jmp     next3
Question:
    mov     ebx,2
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next3:
    cmp     al, '('
    je      Parentheses
    cmp     al, ')'
    je      Parentheses
    jmp     next4
Parentheses:
    mov     ebx,3
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next4:
    cmp     al, 27h
    je      Apostrophe
    jmp     next5
Apostrophe:
    mov     ebx,4
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next5:
    cmp     al, ';'
    je      Semicolon
    jmp     next6
Semicolon:
    mov     ebx,5
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next6:
    cmp     al, ':'
    je      Colon
    jmp     next7
Colon:
    mov     ebx,6
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next7:
    cmp     al, '"'
    je      Quotation
    jmp     next8
Quotation:
    mov     ebx,7
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse
    jmp     L2
next8:
    cmp     al, '-'
    je      Hyphen
    jmp     next9
Hyphen:
    mov     ebx,8
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next9:
    cmp     al, '/'
    je      Fraction
    jmp     next10
Fraction:
    mov     ebx,9
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2
next10:
    cmp     al, '$'
    je      Dollar
    jmp     PrintError
Dollar:
    mov     ebx,10
    lea     ebx, [Punctuation + ebx * 8]
    mov     edx,ebx
    call    WriteMorse 
    jmp     L2

EndTranslation:
ret
MorseTran ENDP

WriteMorse PROC
    ; EBX contains the address of the Morse code string
    push        esi
    mov esi, ebx
WriteMorseLoop:
    mov al, [esi]
    cmp al, 0
    je  WriteMorseEnd
    mov dl, al
    call WriteChar        ; Use Irvine32's WriteChar to print character
    inc esi
    jmp WriteMorseLoop
WriteMorseEnd:
    pop     esi
    mov     al,' '
    mov     dl,al
    call    WriteChar
    ret
WriteMorse ENDP

END main