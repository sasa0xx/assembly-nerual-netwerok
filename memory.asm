extern exit

section .text
    global malloc
    global free

malloc:
    ;
    ; allocate memory
    ; arguments:
    ;    rdi - size in bytes to allocate
    ; returns:
    ;    rax - pointer to the allocated memory
    ;
    mov rax, 9          ; syscall number for sys_mmap
    mov rsi, rdi        ; size
    xor rdi, rdi        ; address 0 (kernel chooses the address)
    mov rdx, 3          ; PROT_READ | PROT_WRITE
    mov r10, 0x22       ; MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1          ; file descriptor (not used)
    mov r9, 0           ; offset
    syscall

    cmp rax, -4095
    jae .error
    mov [rax], rsi      ; store the size at the beginning of the allocated memory
    ret
.error:
    mov rdi, 12         ; ENOMEM
    call exit
    db 'Memory allocation failed', 0

free:
    ;
    ; free memory
    ; arguments:
    ;    rdi - pointer to the memory to free
    ;
    sub rdi, 8          ; move pointer to the size
    mov rax, 11         ; syscall number for sys_munmap
    mov rsi, rdi        ; pointer to the memory
    mov rdx, [rdi]      ; size of the memory
    syscall
    ret
