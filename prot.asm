[BITS 16]
org 0x7C00        ;

start:
    cli                 ; Deshabilitar interrupciones

    lgdt [gdt_descriptor]   ; Cargar GDT

    mov eax, cr0            ; Habilitar el bit PE
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode_start ; Salto a modo protegido

; ----------------
; GDT Definition
; ----------------
gdt_start:
    dq 0                 ; Desciptor nulo

    ; Code Segment: base=0, limit=4GB, executable, readable
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; Data Segment: base=0, limit=4GB, read/write
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b        ; db 10010000b si se quiere que no tenga acceso para escribir
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; ----------------
; 32-bit Protected Mode
; ----------------
[bits 32]

protected_mode_start:
    ; Setup segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Setup stack
    mov esp, 0x90000

    ; Posición de cursor
    mov ebx, 5
    mov ecx, 10
    call set_cursor

    ; Color para el mensaje
    mov ah, 0x01

    ; Imprimir
    mov esi, message
print_loop:
    lodsb
    test al, al
    jz hang              ; Fin
    call print_char
    jmp print_loop

; ----------------
; Imprimir el mensaje
; ----------------
print_char:
    mov edi, [cursor_pos]
    mov [es:edi], ax
    add dword [cursor_pos], 2
    ret

; ----------------
; Posición del cursor
; ----------------
set_cursor:
    mov eax, ebx
    imul eax, 160         ; 80 chars * 2 bytes/char
    mov edx, ecx
    imul edx, 2
    add eax, edx
    add eax, 0xB8000      ; Video
    mov [cursor_pos], eax
    ret

; ----------------
; Bucle infinito
; ----------------
hang:
    hlt
    jmp hang                  ; Bucle infinito

; ----------------
; Datos
; ----------------
cursor_pos dd 0

message db 'Hola, puntos flotantes!', 0

; ----------------
; Para que quede de 512 bytes
; ----------------
times 510-($-$$) db 0
dw 0xAA55
