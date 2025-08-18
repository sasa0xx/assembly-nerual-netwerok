extern printf
extern exit
extern malloc
extern free
extern vector_init
extern vector_dot
global _start

section .data
    align 32
    my_data: dq 1.0, 2.0, 3.0, 4.0

section .text
_start:
    mov rdi, 4
    call vector_init
    mov rsi, rax
    vmovapd ymm0, [rel my_data]
    vmovapd  [rsi], ymm0

    push rsi
    sub rsp, 8
    mov rdi, 4
    call vector_init
    mov rdi, rax
    pop rsi
    vmovapd ymm0, [my_data]
    vmovapd [rdi], ymm0
    call vector_dot

    mov rdi, 0
    call exit
    db 0
