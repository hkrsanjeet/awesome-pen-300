.section .data
msg:
    .ascii "I love programming.\n"

.section .text
.globl _start
_start:
    # Output "I love programming."
    mov $1, %rax
    mov $1, %rdi
    lea msg(%rip), %rsi
    mov $20, %rdx
    syscall

    # Simple delay loop (takes >10 seconds)
    mov $0x7FFFFFFF, %rcx
delay_loop:
    nop
    nop
    nop
    nop
    nop
    loop delay_loop

    # exit(3)
    mov $60, %rax
    mov $3, %rdi
    syscall
