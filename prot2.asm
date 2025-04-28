[BITS 16]               ; Modo real

cli                     ; Deshabilitar interrupciones

lgdt [gdt_descriptor]    ; Cargar la GDT

mov eax, cr0            ; Habilitar modo protegido
or eax, 1
mov cr0, eax

jmp 0x08:pm_start   ; Salto lejano a modo protegido

; Definición de la GDT
gdt_start:
    ; Descriptor nulo (obligatorio)
    dq 0x0000000000000000

    ; Descriptor de código 32 bits
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; Descriptor de datos 32 bits
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[BITS 32]               ; Ahora en modo protegido

pm_start:

    ; Código
    mov eax, 0x12345678     ; Operación en código
    mov [0x5000], eax       ; Almacenar valor en datos

    ; Datos
    mov eax, [0x5000]       ; Cargar dato de memoria

    ; Escribir en VRAM (pantalla de texto)
    mov esi, 0xB8000        ; Dirección de VRAM
    mov edi, message        ; Mensaje
    mov ecx, message_length ; Longitud del mensaje

write_loop:
    lodsb                   ; Cargar un byte del mensaje
    mov ah, 0x0F            ; Atributo: blanco sobre negro
    stosw                   ; Guardar en VRAM
    loop write_loop         ; Repetir

hang:
    hlt                     ; Detener la CPU
    jmp hang

message db 'Hola, segmentos diferenciados', 0
message_length equ $ - message
