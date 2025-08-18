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

vector_init:
    ; Initialize a vector
    ; Arguments:
    ;   rdi - size of the vector (number of elements)
    ; Returns:
    ;   rax - pointer to the initialized vector
    ;
    shl rdi, 3          ; size in bytes (8 bytes per element)

    call malloc
    ret

vector_dot:
    ; Get the dot product of two vectors
    ; Arguments:
    ;   rdi - pointer to the first vector
    ;   rsi - pointer to the second vector
    ; Returns:
    ;   xmm0 - the dot product
    ;
    xor rcx, rcx
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
    jz .done
    sub rdi, 32
    sub rsi, 32

.done:
    ret