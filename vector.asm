;   vector.asm
;   note that this file is for math vectors, not for vectors in the sense of std::vector
struc vector
    .size resq 1
    .data resq 1
endstruc

extern malloc
extern free
extern exit

global vector_init
global vector_free
global vector_dot
global vector_add
global vector_hadamard

vector_init:
    ; Initialize a vector
    ; Arguments:
    ;   rdi - size of the vector (number of elements)
    ; Returns:
    ;   rax - pointer to the initialized vector
    ;
    test rdi, rdi
    jnz .have_n
    mov rdi, 1
.have_n:
    push rdi
    add rdi, 3
    and rdi, -4		; make sure amout of data is dividable by 4
    shl rdi, 3          ; size in bytes (8 bytes per element)
    add rdi, 32

    mov rax, rdi
    push rax

    call malloc
    pop rcx
    sub rcx, 32
    pop rdi

    mov [rax + 0], rdi
    add rcx, rax	; can also be seen as lea rcx, [rax + rcx]
    mov [rax + 8], rcx

    ret

vector_dot:
    ; Get the dot product of two vectors
    ; Arguments:
    ;   rdi - pointer to the first vector
    ;   rsi - pointer to the second vector
    ; Returns:
    ;   xmm0 - the dot product
    ;
    mov rcx, [rdi + vector.size]
    mov rdi, [rdi + vector.data]
    mov rsi, [rsi + vector.data]
    pxor xmm0, xmm0
.loop:
    vmovapd ymm1, [rdi]
    vmovapd ymm2, [rsi]
    vmulpd ymm1, ymm1, ymm2

    vextractf128 xmm3, ymm1, 1
    vaddpd xmm1, xmm1, xmm3
    vhaddpd xmm1, xmm1, xmm1
    addsd xmm0, xmm1

    sub rcx, 4
    jng .done
    add rdi, 32
    add rsi, 32
    jmp .loop

.done:
    ret

vector_hadamard:
    ; Get the hadamard of two vectors
    ; Arguments :
    ;     rdi : pointer to the first vector
    ;     rsi : pointer to the second vector
    ; Returns :
    ;     rax : pointer to new vector
    ;
    mov rcx, [rdi + vector.size]
    sub rsp, 8
    push rdi
    push rsi
    push rcx

    mov rdi, rcx
    call vector_init

    pop rcx
    pop rsi
    pop rdi
    mov [rsp], rax

    mov rdi, [rdi + vector.data]
    mov rsi, [rsi + vector.data]
    mov rax, [rax + vector.data]
.loop:
    vmovapd ymm0, [rdi]
    vmovapd ymm1, [rsi]
    vmulpd ymm0, ymm0, ymm1
    vmovapd [rax], ymm0

    sub rcx, 4
    jng .done
    add rax, 32
    add rdi, 32
    add rsi, 32
    jmp .loop
.done:
    pop rax
    ret
