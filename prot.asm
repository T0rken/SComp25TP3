[BITS 16]               ; Estando en modo real

cli                     ; Deshabilitar interrupciones

lgdt [gdt_descriptor]   ; Cargar la GDT

mov eax, cr0            ; Habilitar el bit PE
or eax, 1
mov cr0, eax

jmp 0x08:pm_start   ; Salto lejano a modo protegido

; GDT
gdt_start:
    dq 0x0000000000000000

    ; Descriptor de código: base=0, límite=4GB
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b        ; Código, ejecutable, readable, accessed
    db 11001111b        ; Flags: 4K granularity, 32 bits
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1   ; Tamaño de la GDT - 1
    dd gdt_start                 ; Dirección base de la GDT

[BITS 32]               ; Ahora en modo protegido

pm_start:

    mov esi, 0x0000           ; Offset dentro del segmento VRAM
    mov ax, 0xB800            ; Segmento de VRAM
    mov es, ax                ; Configurar ES para apuntar a VRAM

    mov edi, message          ; Dirección del mensaje
    mov ecx, message_length   ; Cantidad de caracteres

write_loop:
    lodsb                     ; Cargar un byte de [EDI] en AL, avanzar EDI
    mov ah, 0x0F              ; Atributo: blanco sobre negro
    stosw                     ; Guardar AX en [ESI], avanzar ESI
    loop write_loop           ; Repetir para todos los caracteres

hang:
    hlt
    jmp hang                  ; Bucle infinito

; Datos
message db 'hola, puntos flotantes', 0
message_length equ $ - message
