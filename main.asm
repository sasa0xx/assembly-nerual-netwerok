;	main.asm

extern printf
extern vector_init
extern vector_dot
extern exit

struc vector
    .size resq 1
    .data resq 1
endstruc

section .data
    align 32
    my_data: dq 1.0, 2.0, 3.0, 4.0, 5.0

section .text
global _start
_start:
    call printf
    db "Program started now!", 10, 0
    mov rdi, 5
    call vector_init
    mov rsi, [rax + vector.data]
    vmovapd ymm0, [rel my_data]
    vmovapd [rsi], ymm0
    movsd xmm0, [rel my_data + 4 * 8]
    movsd [rsi + 4 * 8], xmm0

    push rax
    mov rdi, 5
    call vector_init

    mov rdi, rax
    mov rdi, [rdi + vector.data]
    vmovapd ymm0, [rel my_data]
    vmovapd [rdi], ymm0
    movsd xmm0, [rel my_data + 4 * 8]
    movsd [rdi + 4 * 8], xmm0

    pop rsi
    mov rdi, rax
    call vector_dot

    movq rax, xmm0
    push rax
    call printf
    db "Dot product : %f", 10, 0

    mov rdi, 0
    call exit
    db 0
