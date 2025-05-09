# Trabajo Práctico N°3: Modo protegido

## Cátedra de Sistemas de Computación, FCEFyN, UNC. 2025

### Grupo: Los puntos flotantes

### Alumnos: Bernaus, Julieta; Di Pasquo, Franco; Viccini, Carlos Patricio

### Profesor: Jorge, Javier

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

Los bugs en UEFI no solo existen, sino que además han sido explotados en la práctica. Algunos ejemplos de bugs y exploits reales en UEFI son:

- LoJax (2018):
  - Fue el primer malware detectado que infectó el firmware UEFI.
  - Modificaba el UEFI para persistir incluso después de formatear el disco o reinstalar el sistema operativo.
  - Lo desarrolló el grupo _APT28_ (relacionado con amenazas avanzadas persistentes).

- MoonBounce (2022):
  - Otro malware UEFI, descubierto por _Kaspersky_.
  - Infectaba la memoria flash SPI (donde está el firmware UEFI) y sobrevivía a reinstalaciones.
  - Era aún más sofisticado, ya que no dejaba rastros en disco duro.

- Fallos de BIOS de fabricantes (2019-2023):
  - Lenovo, Dell, HP, Fujitsu, ASUS y otros han tenido múltiples vulnerabilidades serias en sus firmwares.
  - Muchas de esas fallas permitían:
    - Escalada de privilegios.
    - Inyección de código malicioso antes de arrancar el sistema operativo.
    - Desactivación de protecciones como Secure Boot.

- BINARIES Firmados con fallos de seguridad:
  - A veces los fabricantes publicaban firmwares "firmados" (firmware que ha sido autenticado y verificado mediante un proceso de firma digital), pero que contenian bugs que podían ser aprovechados antes de que se verifiquen firmas digitales.

3. ¿Qué es Converged Security and Management Engine (CSME), the Intel Management Engine BIOS Extension (Intel MEBx)?

El **Converged Security and Management Engine (CSME)** y la **Intel Management Engine BIOS Extension (Intel MEBx)** son tecnologías de seguridad y gestión integradas en los sistemas basados en procesadores Intel, que están diseñadas para proporcionar control, administración y seguridad en los dispositivos sin intervención del sistema operativo principal.

- **Converged Security and Management Engine (CSME)**

    El CSME es un sub-sistema embebido en los procesadores Intel modernos que opera como un microcontrolador independiente dentro del chipset de la computadora. Funciona de manera autónoma y con acceso directo al hardware del sistema, lo que le permite ejecutar varias funciones críticas sin depender del sistema operativo o de los controladores principales.

    Algunas de sus funciones claves son:
  - Seguridad: El CSME proporciona un conjunto de características de seguridad avanzadas, como encriptación, autenticación y protección contra ataques maliciosos. Un ejemplo es la protección de claves criptográficas a través de hardware.
  - Gestión Remota: Facilita las capacidades de administración de dispositivos a nivel de hardware. Esto es particularmente útil para entornos empresariales, donde los administradores pueden gestionar sistemas de manera remota, incluso cuando el sistema operativo principal no está en funcionamiento.
  - Protección de datos: Ayuda a proteger la confidencialidad y la integridad de los datos almacenados en dispositivos al cifrarlos de manera transparente para el usuario final.
  - Arranque Seguro: El CSME está involucrado en la implementación de medidas de arranque seguro, lo que significa que asegura que el firmware y el sistema operativo no hayan sido comprometidos antes de que el sistema se inicie.

- **Intel Management Engine BIOS Extension (Intel MEBx)**

    El Intel MEBx es una interfaz de usuario que forma parte de la tecnología _Intel Active Management Technology (AMT)_, la cual es utilizada para administrar y controlar computadoras de forma remota a través del CSME. La MEBx permite a los administradores de sistemas configurar y administrar las funcionalidades de la tecnología Intel AMT.

    Entre sus funciones mas importantes encontramos:
  - Interfaz de configuración: El Intel MEBx proporciona una interfaz que permite a los administradores de IT configurar características de gestión remota del sistema, como encender o apagar un dispositivo de manera remota, incluso si el sistema operativo no está funcionando.
  - Acceso al firmware de administración: El MEBx permite configurar diversos parámetros del Intel Management Engine a través de un conjunto de menús en una interfaz de texto, que se accede durante el proceso de arranque del sistema.
  - Gestión remota y diagnóstico: Junto con AMT, MEBx permite a los administradores acceder y diagnosticar computadoras de forma remota, incluso si el sistema operativo ha fallado o el dispositivo no está encendido, ya que se ejecuta en un nivel de hardware más bajo.
  - Seguridad en el arranque: A través del MEBx, los administradores pueden gestionar configuraciones de arranque seguro y otras características relacionadas con la seguridad a nivel de hardware.

A pesar de todos sus beneficios, estas tecnologías también han sido **objeto de controversia** en términos de **privacidad** y **seguridad**, ya que permiten acceso a los dispositivos sin la intervención del sistema operativo. Debido a que CSME tiene acceso directo al hardware, podría ser un vector de ataque en manos equivocadas, ya que funciona de manera independiente del sistema operativo.

4. ¿Qué es coreboot? ¿Qué productos lo incorporan ? ¿Cuáles son las ventajas de su utilización?

coreboot es un proyecto de firmware libre y liviano que reemplaza los BIOS propietarios. Se utiliza en todos los modelos actuales de Chromebooks, las computadoras con sistema operativo Chrome OS, además de en muchísimos modelos de computadoras personales enfocadas al software libre y, teóricamente, cualquier sistema con arquitectura IA-32, x86-64, ARM, ARM64, MIPS o RISC-V puede ejecutarlo.

La principal ventaja de utilizar coreboot radica en que todo su código es libre, de manera que se puede minimizar la superficie de riesgo a ataques, porque se lo puede conocer en su totalidad. Además, al ser muy minimalista es rápido para arrancar y muy liviano. También es más flexible y se lo puede customizar según las necesidades de los usuarios.

### Linker

1. ¿Qué es un linker? ¿Qué hace?

Un linker es un programa que combina uno o más archivos de código ya compilado en un único archivo ejecutable y se asegura de que este tenga el formato que corresponda para que pueda ser ejecutado por el firmware.

En el caso de BIOS, lo que se genera a la salida del linker son archivos .bin, mientras que para UEFI son archivos .efi, que luego es cargado como si fuese un sistema operativo pequeño.

2. ¿Qué es la dirección que aparece en el script del linker? ¿Por qué es necesaria?

La dirección que aparece en el script del linker de BIOS es la dirección de memoria donde debe empezar el código una vez que está cargado. Es necesaria para poder calcular las direcciones relativas, además de para poder asegurarse de que los saltos, llamadas a funciones y accesos de datos funcionen como se espera.

3. Comparar la salida de objdump con hd, verifique donde fue colocado el programa dentro de la imagen.

Con **objdump**, se obtiene la dirección de memoria a la que apunta un programa, mientras que con **hd** se obtiene en qué offset real dentro del archivo están las instrucciones. Es decir, comparándolos se puede ver si el código comienza en la dirección que pidió el linker.

4. Grabar la imagen en un pendrive y probarla en una pc y subir una foto.

Para probar esto, se cargo la imagen protected_mode.img con su texto modificado en un pendrive y se booteo desde el mismo una pc real utilizando en la Terminal el comando:

```sudo dd if=protected_mode.img of=/dev/sda```

![Imagen N°1, programa de ejemplo modificado cargado a un pendrive](img/img-usb.png)

Luego, booteando la PC de manera correcta y desde el pendrive, se observa lo siguiente:

![Imagen N°2, programa de ejemplo modificado corriendo desde un USB](img/usb.jpeg)

5. ¿Para qué se utiliza la opción --oformat binary en el linker?

La opción `--oformat binary` le pide al linker una salida en formato binario puro. Esto significa que no tendrá cabeceras, secciones ni símbolos.

### Código assembler

1. Crear un código assembler que pueda pasar a modo protegido (sin macros).

El programa se encuentra en el archivo prot.asm.

Se comienza en modo real y luego se actualizan los valores del Global Descriptor Table (GDT) y se entra en modo protegido, donde se imprime un saludo.

2. ¿Cómo sería un programa que tenga dos descriptores de memoria diferentes, uno para cada segmento (código y datos) en espacios de memoria diferenciados?

En la segunda iteración de prot.asm, se tiene un GDT con dos descriptores diferentes, uno para código y uno para datos, además de ambos segmentos y los saltos correspondientes.

3. Cambiar los bits de acceso del segmento de datos para que sea de solo lectura,  intentar escribir, ¿qué sucede? ¿Qué debería suceder a continuación? (revisar el teórico) Verificarlo con gdb.

Para que sea solo lectura, el único cambio es un bit, en la línea 33. Es `db 10010010b` si se quiere escribir, mientras que en es `db 10010000b` si no se lo permite. Ese bit cambia el acceso a solo lectura. No se permite escribir y se debería obtener una General Protection Fault. Lo que se ve es que el programa queda en un bucle porque se encuentra con que no puede terminar de ejecutar el código.

4. En modo protegido, ¿con qué valor se cargan los registros de segmento? ¿Por qué?

En modo protegido, los registros de segmento se cargan con selectores de segmento, que son índices en las tablas de descriptores local o global (LDT o GDT). Los selectores son de 16 bits, incluyendo 13 bits de índice de descriptor y 3 de atributos de acceso. Se maneja el acceso a los segmentos de esta manera porque se protege mejor la memoria, controlando el acceso a ellos y no limitándose a una distribución física de segmentos en concreto, aumentando la abstracción.

![Imagen N°3, bios_hello_world](img/asm.png)

### Ejemplos de código para x86

En la imagen N°4

![Imagen N°4, bios_hello_world](img/qemu-1.png)

se puede observar el resultado de ejecutar el programa bios_hello_world de los ejemplos de código. En este, se puede ver que se está utilizando el firmware libre iPXE, con dirección PCI 00:03.0 y versión de PCI 2.10. Después menciona algunas direcciones de memoria que este programa utiliza.

En la imagen N°5

![Imagen N°5, depurado](img/qemu-2.png)

se utilizó gdb dashboard y la instrucción debug para ver más detalles sobre la ejecución del mismo ejemplo. Se puede ver cómo la primera dirección de memoria es 0x00007c00 y que esto se corresponde a la quinta línea del programa. También se muestra cómo se tienen dos hilos, el segundo de los cuales se corresponde al programa en cuestión.

## Conclusión

Este trabajo práctico nos permitió entender en profundidad el modo protegido y su importancia en la arquitectura de los procesadores modernos. No solo trabajamos con conceptos teóricos como UEFI, coreboot y el funcionamiento de los linkers, sino que también llevamos todo eso a la práctica: escribimos código assembler para configurar la GDT y pasar de modo real a modo protegido, manejando de manera explícita los descriptores de memoria y los permisos de acceso. Además, pudimos ver el impacto de los errores en la configuración de segmentos, como las General Protection Faults, y comprobarlo tanto en máquinas virtuales como en hardware real.

Todo el recorrido realizado refuerza la idea de que el modo protegido no es solo una cuestión histórica, sino una pieza fundamental para entender cómo los sistemas operativos gestionan la memoria y protegen los recursos del sistema. Haber trabajado de forma tan cercana con estos mecanismos nos deja una mejor base para futuros desarrollos a bajo nivel y una visión más completa del arranque y la inicialización de un sistema.
