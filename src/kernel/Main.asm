org 0x7C00
bits 16

start:
    jmp main

puts:
    push si
    push ax
.loop:
    lodsb
    or al,al
    jz .done
    jmp .loop

    mov ah,0x0e
    ;mov bh,0
    int 0x10

.done:
    pop ax
    pop si
    ret

main:
    mov ax,0
    mov ds,ax
    mov es,ax

    mov ss,ax
    mov sp,0x7C00

    mov si,msg_hello
    call puts
    hlt

.halt:
    jmp .halt

msg_hello: db "Hello World",10,0

times   510-($-$$) db 0
dw  0AA55h