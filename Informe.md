# Trabajo Práctico N°3: Modo protegido
## Cátedra de Sistemas de Computación, FCEFyN, UNC. 2025.

### Grupo: Los puntos flotantes
### Alumnos: Bernaus, Julieta; Di Pasquo, Franco; Viccini, Carlos Patricio.
### Profesor: Jorge, Javier.

## Introducción
En el siguiente informe, se desarrollarán las consignas propuestas en clase acerca del modo protegido. Es decir, se explora el modo de operación de los procesadores x86 que permite usar algunas características avanzadas de dichos procesadores, como acceso a más memoria, privilegios y la segmentación avanzada y paginación.

## Desarrollo

### Consigna

La consigna para este trabajo práctico consta de los siguientes puntos:
- contestar una serie de preguntas acerca de UEFI y coreboot;
- contestar una serie de preguntas acerca de los linker;
- realizar código assembler para pasar a modo protegido sin macros y contestar una serie de preguntas acerca de ese programa;
- ejecutar unos ejemplos de código x86 en una máquina virtual y describir su comportamiento.

### UEFI y coreboot

Estas preguntas fueron contestadas en clase pero se recopila la información aquí también.

1. ¿Qué es UEFI? ¿Cómo puedo usarlo? Mencionar además una función a la que podría llamar usando esa dinámica.

UEFI significa Unified Extensible Firmware Interface y es el sucesor del BIOS. Al igual que este, se encarga de iniciar el hardware durante el encendido y de cargar y arrancar el sistema operativo, pero también tiene funciones adicionales que aquel no contaba con: sistema operativo mínimo propio, diseño más modular y permitir programar controladores y apps para el firmware específico. Además, BIOS trabaja en código de 16 bits y UEFI trabaja en 32 o 64 bits.

Se puede utilizar UEFI programando en C una de esas apps particulares con la extensión .efi, que podría ser un bootloader o un sistema operativo.

```SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Hola mundo");```
usa una función de UEFI.

2. Mencionar casos de bugs de UEFI que puedan ser explotados.
3. ¿Qué es Converged Security and Management Engine (CSME), the Intel Management Engine BIOS Extension (Intel MEBx)?
4. ¿Qué es coreboot? ¿Qué productos lo incorporan ? ¿Cuáles son las ventajas de su utilización?

### Linker

1. ¿Qué es un linker? ¿Qué hace ? 
2. ¿Qué es la dirección que aparece en el script del linker? ¿Por qué es necesaria?
3. Comparar la salida de objdump con hd, verifique donde fue colocado el programa dentro de la imagen. 
4. Grabar la imagen en un pendrive y probarla en una pc y subir una foto .
5. ¿Para qué se utiliza la opción --oformat binary en el linker?

### Código assembler

1. Crear un código assembler que pueda pasar a modo protegido (sin macros).
2. ¿Cómo sería un programa que tenga dos descriptores de memoria diferentes, uno para cada segmento (código y datos) en espacios de memoria diferenciados? 
3. Cambiar los bits de acceso del segmento de datos para que sea de solo lectura,  intentar escribir, ¿qué sucede? ¿Qué debería suceder a continuación? (revisar el teórico) Verificarlo con gdb. 
4. En modo protegido, ¿con qué valor se cargan los registros de segmento? ¿Por qué?

### Ejemplos de código para x86



## Conclusión


