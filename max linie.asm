.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern scanf: proc
extern printf: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
mat dd 100 dup(0)
lin dd 0
col dd 0
nr dd 0
k dd 0
m dd 0
max dd 0
buffer dd 0
format db "%d", 0

.code

func proc
push ebp
mov ebp, esp

mov esi, [ebp+20];k
	xor eax, eax
	mov eax, [ebp+16];col
	mul esi
	shl eax, 2
	mov esi, eax
	xor eax, eax
	mov edi, 0
	xor edx, edx
	
	mov eax, [ebp+24];m;mat[esi][edi*4]
	bucla:
	cmp eax, mat[esi][edi*4]
	;jg mare
	je mare
	;mov eax, mat[esi][edi*4]
	inc edi
	jmp cont
	mare:
	inc edx;edi
	inc edi
	cont:
	cmp edi, [ebp+16];col
	jl bucla
	
	mov max, edx;eax

mov esp, ebp
pop ebp
ret
func endp

start:
	;aici se scrie codul
	push offset col
	push offset format
	call scanf
	add esp ,8
	
	push offset lin
	push offset format
	call scanf
	add esp ,8
	
	xor esi, esi
	xor eax, eax
	mov esi, col
	mov eax, lin
	mul esi
	shl eax, 2
	mov nr, eax
	xor esi, esi
	xor eax, eax
	mov edi, 0
	
	citire:
	push offset buffer
	push offset format
	call scanf
	add esp, 8
	mov eax, buffer
	mov mat[esi][edi*4], eax
	inc edi
	cmp edi, col
	jl citire
	shl edi, 2
	add esi, edi
	xor edi, edi
	cmp esi, nr
	jl citire
	
	push offset k
	push offset format
	call scanf
	add esp, 8
	
	push offset m
	push offset format
	call scanf
	add esp, 8
	
	; mov esi, k
	; xor eax, eax
	; mov eax, col
	; mul esi
	; shl eax, 2
	; mov esi, eax
	; xor eax, eax
	; mov edi, 0
	
	; mov eax, mat[esi][edi*4]
	; bucla:
	; cmp eax, mat[esi][edi*4]
	; jg mare
	; mov eax, mat[esi][edi*4]
	; mare:
	; inc edi
	; cmp edi, col
	; jl bucla
	
	; mov max, eax
	
	push m
	push k
	push col
	push lin
	push mat
	call func
	add esp, 20
	
	push max
	push offset format
	call printf
	add esp, 8
	;terminarea programului
	push 0
	call exit
end start
