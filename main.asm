;	main.asm

extern printf
extern vector_init
extern exit
extern vector_hadamard

struc vector
    .size resq 1
    .data resq 1
endstruc

section .data
    align 32
    a: dq 1.5, 6.3, 4.9, 5.2
    b: dq 2.3, 4.6, 9.3, 1.6

section .text
global _start
_start:
    call printf
    db "Program started now!", 10, 0
    mov rdi, 4
    call vector_init
    mov rsi, [rax + vector.data]
    vmovapd ymm0, [rel a]
    vmovapd [rsi], ymm0

    push rax
    mov rdi, 4
    call vector_init

    mov rdi, rax
    mov rdi, [rdi + vector.data]
    vmovapd ymm0, [rel b]
    vmovapd [rdi], ymm0

    pop rsi
    mov rdi, rax
    call vector_hadamard

    mov rax, [rax + vector.data]
    push qword [rax + 24]
    push qword [rax + 16]
    push qword [rax + 8]
    push qword [rax]

    call printf
    db "Result Vector : [%f, %f, %f, %f]", 10, 0

    mov rdi, 0
    call exit
    db 0
