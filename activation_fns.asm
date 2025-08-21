struc vector
    .size resq 1
    .data resq 1
endstruc

extern vector_init

section .rodata
    log_e dq 1.44269504088896340736

section .text
    global ReLU
    global softmax
    global e_pow_x

ReLU:
    ; Aplies ReLU to a vector
    ; Arguments :
    ;     rdi - a pointer to the vector
    ; Returns :
    ;     rax = a pointer to the new vector
    ;
    mov rcx, [rdi + vector.size]
    sub rsp, 8
    push rdi
    push rcx

    mov rdi, rcx
    call vector_init

    pop rcx
    pop rdi
    mov [rsp], rax

    mov rdi, [rdi + vector.data]
    mov rax, [rax + vector.data]
.loop:
    vmovapd ymm0, [rdi]
    vxorpd ymm1, ymm1, ymm1
    vmaxpd ymm0, ymm0, ymm1
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

e_pow_x:
    ; Helper function (for softmax)
    ; Arguments :
    ;     ; xmm1 - X
    ; Returns :
    ;     ; xmm0 - e^X
    ;

    ; I could implement this with AVX instead of FPU for a huge performance boost.
    ; But I'm just lazy :D.
    ; -sorry.
    push rbp
    mov rbp, rsp

    sub rsp, 16
    movsd [rsp], xmm1
    fld qword [rsp] 
    fld qword [rel log_e]
    fmulp ST1, ST0 

    fld ST0
    frndint
    fsub ST1, ST0
    fxch ST1

    f2xm1
    fld1
    faddp ST1, ST0
    fscale
    fstp qword [rsp]
    movsd xmm0, [rsp]
    fstp ST0

    mov rsp, rbp
    pop rbp
    ret

softmax:
    ; Softmax output activation function
    ; Arguments :
    ;     rdi - pointer to the vector
    ; Returns :
    ;     rax - pointer to the new vector
    ;
    push rbp
    mov rbp, rsp

    mov rcx, [rdi + vector.size]
    push rdi
    push rcx

    mov rdi, rcx
    call vector_init

    pop rcx
    pop rdi

    ; find max(x)
    mov rsi, [rdi + vector.data]
    mov rbx, rcx
    movsd xmm6, [rsi] ; xmm6 = max(x)
.max_loop:
    movsd xmm1, [rsi]
    maxsd xmm6, xmm1
    add rsi, 8
    sub rbx, 1
    jg .max_loop

    ; sigma result stored in ymm0
    vxorpd ymm5, ymm5, ymm5

    mov rsi, [rdi + vector.data]
    mov rbx, rcx

.sigma:
    movsd xmm1, [rsi]
    subsd xmm1, xmm6
    call e_pow_x
    addsd xmm5, xmm0

    add rsi, 8
    sub rbx, 1 ; used instead of dec to set flags
    jg .sigma

    ; now, xmm5 should contain sigma.
    mov rsi, [rax + vector.data]
    mov rdi, [rdi + vector.data]
.loop:
    movsd xmm1, [rdi]
    subsd xmm1, xmm6
    call e_pow_x
    divsd xmm0, xmm5
    movsd [rsi], xmm0

    add rsi, 8
    add rdi, 8
    sub rcx, 1
    jg .loop

    mov rsp, rbp
    pop rbp
    ret
