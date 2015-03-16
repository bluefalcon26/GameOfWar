
; Game of War, Windows x32

INCLUDE \masm32\include\masm32rt.inc

.DATA     
        
	;The following 11 dwords contain 312 bits representing 52 consecutive 
	;6-bit card identifiers.
	;Each dword contains 5 6-bit cards with a 2-bit zero pad at the
	;big end (32 bits total).
	;Except for dword 'cards10' which contains 20 zeroes followed by 2 6-bit
	;card identifiers.
	;Initially the cards are ordered from 0 to 51, left to right.
	;It is worth noting that the traditional symbolic designators for the
	;standard 52 cards deck are arbitrary here.

  cards00 dd 270532
  cards01 dd 85488137
  cards02 dd 170705742
  cards03 dd 255923347
  cards04 dd 341140952
  cards05 dd 426358557
  cards06 dd 511576162
  cards07 dd 596793767
  cards08 dd 682011372
  cards09 dd 767228977
  cards10 dd 3251
  cards11 dd 0
  sptr    dd 0
  retS0   dd 0
  retS1   dd 0
  retS2   dd 0
  retS3   dd 0
  retS4   dd 0
  aptr1   dd 0
  aptr2   dd 0
  P1Cards dd 0
  P2Cards dd 0

  FileName db 'WarOutput.txt',0

  .DATA?

  hFile HANDLE ?
  nBytes dw ?

.CODE

loadCards PROC Far C
	pop eax
	mov aptr1,eax
	pop eax
	mov aptr2,eax
	;Player 1 has even cards dwords
	;Player 2 has odd cards dwords
	;loadPlayer1Cards
	mov eax,P1Cards
	lea esi,P1Cards
	cmp eax,0
	je Player2Wins
	;loadPlayer2Cards
	mov ebx,P2Cards
	lea edi,P2Cards
	cmp ebx,0
	je Player1Wins
	mov eax,aptr2
	push eax
	mov eax,aptr1
	push eax
	mov ecx,0
	RET
	Player1Wins:
	mov     eax,12345678h
    mov     edx,uhex$(eax)     ;EDX = address of hexidecimal string
	push    edx
    mov     hFile,eax
    pop     edx
	INVOKE  WriteFile,eax,edx,8,offset nBytes,NULL
	mov eax,aptr2
	push eax
	mov eax,aptr1
	push eax
	mov ecx,1
	RET
	Player2Wins:
	mov     eax,12345678h
    mov     edx,uhex$(eax)     ;EDX = address of hexidecimal string
	push    edx
    mov     hFile,eax
    pop     edx
	INVOKE  WriteFile,eax,edx,8,offset nBytes,NULL
	mov eax,aptr2
	push eax
	mov eax,aptr1
	push eax
	mov ecx,1
	RET
loadCards ENDP

endRound PROC Far C
	pop eax
	mov aptr1,eax
	pop eax
	mov aptr2,eax
	;Player 1 has even cards dwords
	;Player 2 has odd cards dwords
	cmp al,bl
	jb P2Wins
	P1Wins:
	mov edx,0
	loop1:
		mov eax,[P1Cards+edx]
		lea esi,[P1Cards+edx]
		mov ecx,eax
		mov ebx,0
		iloop1:
			shl ecx,2
			cmp cl,0
			je P1Add
			shr ecx,8
			inc ebx
			cmp ebx,5
		jne iloop1
		add edx,4
	jmp loop1
	P1Add: ;place card on bottom of player card stack
	pop edx
	or ecx,edx
	shr ecx,2
	ploop1:
		cmp ebx,0
		je placeP1
		shl ecx,6
		dec ebx
	jmp ploop1
	placeP1:
	or eax,ecx
	mov [esi],ecx
	;check stack for more cards
	mov eax, DWORD PTR SS:[esp]
	cmp eax,0
	jne P1Wins
	mov eax,aptr2
	push eax
	mov eax,aptr1
	push eax
	RET
	P2Wins:
	mov edx,0
	loop2:
		mov eax,[P2Cards+edx]
		lea esi,[P2Cards+edx]
		mov ecx,eax
		mov ebx,0
		iloop2:
			shl ecx,2
			cmp cl,0
			je P2Add
			shr ecx,8
			inc ebx
			cmp ebx,5
		jne iloop2
		add edx,4
	jmp loop2
	P2Add: ;place card on bottom of player card stack
	pop edx
	or ecx,edx
	shr ecx,2
	ploop2:
		cmp ebx,0
		je placeP2
		shl ecx,6
		dec ebx
	jmp ploop2
	placeP2:
	or eax,ecx
	mov [esi],ecx
	;check stack for more cards
	mov eax, DWORD PTR SS:[esp]
	cmp eax,0
	jne P2Wins
	mov eax,aptr2
	push eax
	mov eax,aptr1
	push eax
	RET

endRound ENDP

game PROC Far C
	;handle return address so we can use hardware stack
	mov retS1,ebp
	mov retS2,edi
	mov retS3,esi
	mov retS4,esp
	pop eax
	mov retS0,eax

	;manual allocate space
	mov eax,[P1Cards]
	mov P1Cards,eax
	add eax,312
	mov P2Cards,eax
	;Create output file
	mov     eax,12345678h
    mov     edx,uhex$(eax)     ;EDX = address of hexidecimal string
	push    edx
    INVOKE  CreateFile,offset FileName,GENERIC_WRITE,FILE_SHARE_READ,
            NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
    mov     hFile,eax
    pop     edx
	;SHUFFLE CARDS
	mov ecx,88
	mov sptr,esp
	shuffle:
		mov eax,cards00
		mov ebx,cards01
		mov esi,cards02
		mov edi,cards03
		mov esp,cards04
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards00,edx
		shr eax,6
		shr ebx,6
		shr esi,6
		shr edi,6
		shr esp,6
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards01,edx
		shr eax,6
		shr ebx,6
		shr esi,6
		shr edi,6
		shr esp,6
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards02,edx
		shr eax,6
		shr ebx,6
		shr esi,6
		shr edi,6
		shr esp,6
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards03,edx
		shr eax,6
		shr ebx,6
		shr esi,6
		shr edi,6
		shr esp,6
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards04,edx
		;;
		mov eax,cards05
		mov ebx,cards06
		mov esi,cards07
		mov edi,cards08
		mov esp,cards09
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards05,edx
		shr eax,6
		shr ebx,6
		shr esi,6
		shr edi,6
		shr esp,6
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards06,edx
		shr eax,6
		shr ebx,6
		shr esi,6
		shr edi,6
		shr esp,6
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards07,edx
		shr eax,6
		shr ebx,6
		shr esi,6
		shr edi,6
		shr esp,6
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards08,edx
		shr eax,6
		shr ebx,6
		shr esi,6
		shr edi,6
		shr esp,6
		;
		mov dx,si
		shl edx,16
		mov dx,di
		shl dx,10
		shl edx,6
		mov dx,sp
		shl dx,10
		shr edx,2
		mov dl,al
		shl dl,2
		shl edx,6
		mov dl,bl ;edx now contains last card of, in order, esi,edi,esp,eax,ebx
		shr edx,2
		mov cards09,edx
		;;
		mov eax,cards02
		mov ebx,cards10
		mov edx,eax
		shl edx,8
		mov dl,bl
		shl dl,2 ;edx now contains last of, in order, eax,eax(2),eax(3),eax(4),ebx
		shr edx,2
		mov cards02,edx
		shr eax,24
		shr ebx,6
		;
		mov dh,bl
		mov dl,al
		shl dl,2 ;edx now contains last 2 cards
		shr edx,2
		mov cards10,edx
		;;
	cmp ecx,0
	je next1
	dec ecx
	jmp shuffle
	next1:
	mov esp,sptr
	;PLAY WAR
	;
	;
	;Deal Cards
	mov eax,cards10
	and eax,63
	mov cards11,eax
	mov eax,cards10
	shr eax,6
	mov cards10,eax
	;
	mov eax,cards00
	mov P1Cards,eax
	mov eax,cards02
	mov P1Cards+4,eax
	mov eax,cards04
	mov P1Cards+8,eax
	mov eax,cards06
	mov P1Cards+12,eax
	mov eax,cards08
	mov P1Cards+16,eax
	mov eax,cards10
	mov P1Cards+20,eax
	;
	mov eax,cards01
	mov P2Cards,eax
	mov eax,cards03
	mov P2Cards+4,eax
	mov eax,cards05
	mov P2Cards+8,eax
	mov eax,cards07
	mov P2Cards+12,eax
	mov eax,cards09
	mov P2Cards+16,eax
	mov eax,cards11
	mov P2Cards+20,eax
	;;
	roundStart:
	call loadCards
	cmp ecx,1
	je gameOver
	mov ecx,eax
	mov edx,ebx
	shr ecx,6
	shr edx,6
	mov [esi],ecx
	mov [edi],edx
	shl eax,2
	shl ebx,2
	and eax,255
	and ebx,255
	push eax
	push ebx
	;remove cards from player stacks
	call loadCards
	Compare:
	mov cl,al
	mov dl,bl
	and cl,3 ;modulo 4
	and dl,3 ;modulo 4
	add al,dl ;compensate for suit
	add bl,cl ;compensate for suit
	cmp al,bl ;compare cards
	je War
	call endRound
	jmp roundStart
	War:
	call loadCards
	mov ecx,eax
	mov edx,ebx
	shr ecx,6
	shr edx,6
	mov [esi],ecx
	mov [edi],edx
	shl eax,2
	shl ebx,2
	and eax,255
	and ebx,255
	push eax
	push ebx
	jmp roundStart
	gameOver:
	mov ebp,retS1
	mov edi,retS2
	mov esi,retS3
	mov esp,retS4
	mov eax,retS0
	push eax
	RET
game ENDP 
END 
