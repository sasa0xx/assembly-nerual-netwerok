;   printf.asm
extern exit

section .rodata
    six_d dq 1000000.0
    dot db '.'
    tiny dq 0.0000005
    minus_one dq -1.0
    sign_mask dq 0x8000000000000000, 
    
section .text
    global printf
    global print_double
    global print_int

convert:
    ; helper function
    ; returns:
    ;    rsi - pointer to the buffer with the converted number
    ;    rcx - length of the number in the buffer
    ;
    xor rcx, rcx
.convert_loop:
    xor rdx, rdx
    mov r8, 10
    div r8          ; divide rax by 10, quotient in rax, remainder in rdx
    add dl, '0'     ; convert remainder to ASCII
    dec rbx
    mov [rbx], dl  ; store the ASCII character in the buffer
    inc rcx
    test rax, rax
    jnz .convert_loop
    mov rsi, rbx
    ret

print_int:
    ;
    ; arguments:
    ;    the integer to print is in rdi
    ;
    xor r15, r15
    push rbp
    push rbx
    push rcx
    mov rbp, rsp

    sub rsp, 32  ; allocate space for the integer string
    mov rbx, rsp
    add rbx, 32 ; point rbx to the end of the buffer
    mov rax, rdi
    xor rcx, rcx

    cmp rax, 0
    jge .c1
    neg rax
    mov r15b, 1

.c1:
    call convert

    test r15, r15
    jz .c2
    dec rsi
    inc rcx
    mov byte [rsi], '-'

.c2:
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall

    mov rsp, rbp
    pop rcx
    pop rbx
    pop rbp
    ret

print_double:
    ;
    ; arguments:
    ;    the double to print is in xmm1
    ;
    push rbp
    push rbx
    push rcx
    mov rbp, rsp

    sub rsp, 32
    mov rbx, rsp
    add rbx, 32

    pxor xmm0, xmm0
    ucomisd xmm0, xmm1
    jb .c1

    movsd xmm2, [rel minus_one]
    mulsd xmm1, xmm2

    call printf
    db '-', 0
.c1:
    cvttsd2si rdi, xmm1
    call print_int

    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    lea rsi, [rel dot]
    syscall

    cvttsd2si r8, xmm1
    cvtsi2sd xmm2, r8
    subsd xmm1, xmm2  ; get the fractional part
    addsd xmm1, [rel tiny]
    mulsd xmm1, [rel six_d]
    cvttsd2si rax, xmm1
    call convert

.pad_loop:
    cmp rcx, 6
    jae .print_frac
    dec rbx
    mov byte [rbx], '0'
    inc rcx
    jmp .pad_loop

.print_frac:
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    mov rsi, rbx
    syscall

    mov rsp, rbp
    pop rcx
    pop rbx
    pop rbp
    ret

printf:
    ;
    ; arguments:
    ;    the format string is in rip
    ;    all other arguments are pushed on the stack
    ;
    ; notes to take :
    ;    this function only accepts integers and floats/doubles
    ;    the format for integers is "%d" and for floats/doubles is "%f"
    ;    if an error occurs, the function will exit with error code -42 
    ;
    pop rdi          ; pop the format string pointer into rdi
    push rbp
    push rbx
    push rax
    mov rbp, rsp

    mov rbx, rsp
    add rbx, 24   ; rbx points to the first argument

    mov rcx, -1       ; initialize counter for the loop
.loop:
    push rdi
    inc rcx
    cmp byte [rdi + rcx], 0
    je .done

    cmp byte [rdi + rcx], '%'
    jne .print_letter
    inc rcx     ; skip '%'

    cmp byte [rdi + rcx], 'd'
    je .handle_int
    cmp byte [rdi + rcx], 'f'
    je .handle_float

    ; if the code reaches here, it means an unsupported format was encountered
    mov rdi, -42
    call exit
    db "Unsupported format", 0

.handle_int:
    mov rdi, [rbx]
    add rbx, 8 ; move to the next argument
    add rbp, 8 ; adjust rbp to account for the pushed argument
    call print_int
    pop rdi
    jmp .loop

.handle_float:
    movsd xmm1, [rbx]
    add rbx, 8 ; move to the next argument
    add rbp, 8 ; adjust rbp to account for the pushed argument
    call print_double
    pop rdi
    jmp .loop

.print_letter:
    push rdi
    push rcx

    mov rsi, rdi
    add rsi, rcx
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall

    pop rcx
    pop rdi
    jmp .loop

.done:
    lea rdi, [rdi + rcx + 1] ; adjust rdi to the end of the format string
    mov rsp, rbp
    pop rax
    pop rbx
    pop rbp
    push rdi    ; push the return address
    ret
