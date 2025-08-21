;	main.asm

extern printf
extern vector_init
extern print_int
extern exit
extern print_double
extern vector_hadamard
extern e_pow_x
extern vector_add
extern vector_sub
extern vector_scaler
extern vector_print
extern softmax
extern ReLU

struc vector
    .size resq 1
    .data resq 1
endstruc

section .data
    align 32
    a: dq 1.5, 6.3, 4.9, 5.2
    b: dq 2.3, 4.6, 9.3, 1.6
    test: dq 1.7
    two: dq 2.0
    minus_one: dq -1.0

section .text
global _start
_start:
    call printf
    db "Program started now!", 10, 0
    mov rdi, 4
    call vector_init
    mov rsi, [rax + vector.data]
    vmovapd ymm0, [rel b]
    vmovapd [rsi], ymm0

    push rax
    mov rdi, 4
    call vector_init

    mov rdi, rax
    mov rdi, [rdi + vector.data]
    vmovapd ymm0, [rel a]
    vmovapd [rdi], ymm0

    pop rsi
    mov rdi, rax
    movsd xmm1, [rel two]
    call vector_sub

    call printf
    db "Before :", 0
    mov rdi, rax
    push rdi
    call vector_print

    call printf
    db 10, "After :", 0
    pop rdi
    call ReLU
    mov rdi, rax
    push rdi
    call vector_print

    call printf
    db 10, 0
    pop rdi
    call softmax
    mov rdi, rax
    call vector_print

    mov rdi, 0
    call exit
    db 0
