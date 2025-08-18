section .text
    global exit

exit:
    ;
    ; arguments:
    ;    exit code in rdi
    ;    exit message is after the call
    ;
    pop rsi
    mov rdx, -1
.count:
    inc rdx
    cmp byte [rsi + rdx], 0
    jnz .count

    push rdi
    mov rax, 1          ; syscall number for sys_write
    mov rdi, 1          ; file descriptor 1 (stdout)
    syscall
    pop rdi

    mov rax, 60
    syscall          ; invoke the syscall to exit
