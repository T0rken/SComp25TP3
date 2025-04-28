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

Los bugs en UEFI no solo existen, sino que además han sido explotados en la práctica. Algunos ejemplos de bugs y exploits reales en UEFI son:

- LoJax (2018):
    * Fue el primer malware detectado que infectó el firmware UEFI.
    * Modificaba el UEFI para persistir incluso después de formatear el disco o reinstalar el sistema operativo.
    * Lo desarrolló el grupo _APT28_ (relacionado con amenazas avanzadas persistentes).

- MoonBounce (2022):
    * Otro malware UEFI, descubierto por _Kaspersky_.
    * Infectaba la memoria flash SPI (donde está el firmware UEFI) y sobrevivía a reinstalaciones.
    * Era aún más sofisticado, ya que no dejaba rastros en disco duro.

- Fallos de BIOS de fabricantes (2019-2023):
    * Lenovo, Dell, HP, Fujitsu, ASUS y otros han tenido múltiples vulnerabilidades serias en sus firmwares.
    * Muchas de esas fallas permitían:
        - Escalada de privilegios.
        - Inyección de código malicioso antes de arrancar el sistema operativo.
        - Desactivación de protecciones como Secure Boot.

- BINARIES Firmados con fallos de seguridad:
    - A veces los fabricantes publicaban firmwares "firmados" (firmware que ha sido autenticado y verificado mediante un proceso de firma digital), pero que contenian bugs que podían ser aprovechados antes de que se verifiquen firmas digitales.

3. ¿Qué es Converged Security and Management Engine (CSME), the Intel Management Engine BIOS Extension (Intel MEBx)?

El **Converged Security and Management Engine (CSME)** y la **Intel Management Engine BIOS Extension (Intel MEBx)** son tecnologías de seguridad y gestión integradas en los sistemas basados en procesadores Intel, que están diseñadas para proporcionar control, administración y seguridad en los dispositivos sin intervención del sistema operativo principal.

* __Converged Security and Management Engine (CSME)__

    El CSME es un sub-sistema embebido en los procesadores Intel modernos que opera como un microcontrolador independiente dentro del chipset de la computadora. Funciona de manera autónoma y con acceso directo al hardware del sistema, lo que le permite ejecutar varias funciones críticas sin depender del sistema operativo o de los controladores principales.
    
    Algunas de sus funciones claves son:
    - Seguridad: El CSME proporciona un conjunto de características de seguridad avanzadas, como encriptación, autenticación y protección contra ataques maliciosos. Un ejemplo es la protección de claves criptográficas a través de hardware.
    - Gestión Remota: Facilita las capacidades de administración de dispositivos a nivel de hardware. Esto es particularmente útil para entornos empresariales, donde los administradores pueden gestionar sistemas de manera remota, incluso cuando el sistema operativo principal no está en funcionamiento.
    - Protección de datos: Ayuda a proteger la confidencialidad y la integridad de los datos almacenados en dispositivos al cifrarlos de manera transparente para el usuario final.
    - Arranque Seguro: El CSME está involucrado en la implementación de medidas de arranque seguro, lo que significa que asegura que el firmware y el sistema operativo no hayan sido comprometidos antes de que el sistema se inicie.

* __Intel Management Engine BIOS Extension (Intel MEBx)__

    El Intel MEBx es una interfaz de usuario que forma parte de la tecnología _Intel Active Management Technology (AMT)_, la cual es utilizada para administrar y controlar computadoras de forma remota a través del CSME. La MEBx permite a los administradores de sistemas configurar y administrar las funcionalidades de la tecnología Intel AMT.

    Entre sus funciones mas importantes encontramos:
    - Interfaz de configuración: El Intel MEBx proporciona una interfaz que permite a los administradores de IT configurar características de gestión remota del sistema, como encender o apagar un dispositivo de manera remota, incluso si el sistema operativo no está funcionando.
    - Acceso al firmware de administración: El MEBx permite configurar diversos parámetros del Intel Management Engine a través de un conjunto de menús en una interfaz de texto, que se accede durante el proceso de arranque del sistema.
    - Gestión remota y diagnóstico: Junto con AMT, MEBx permite a los administradores acceder y diagnosticar computadoras de forma remota, incluso si el sistema operativo ha fallado o el dispositivo no está encendido, ya que se ejecuta en un nivel de hardware más bajo.
    - Seguridad en el arranque: A través del MEBx, los administradores pueden gestionar configuraciones de arranque seguro y otras características relacionadas con la seguridad a nivel de hardware.

A pesar de todos sus beneficios, estas tecnologías también han sido **objeto de controversia** en términos de **privacidad** y **seguridad**, ya que permiten acceso a los dispositivos sin la intervención del sistema operativo. Debido a que CSME tiene acceso directo al hardware, podría ser un vector de ataque en manos equivocadas, ya que funciona de manera independiente del sistema operativo.

4. ¿Qué es coreboot? ¿Qué productos lo incorporan ? ¿Cuáles son las ventajas de su utilización?

coreboot es un proyecto de firmware libre y liviano que reemplaza los BIOS propietarios. Se utiliza en todos los modelos actuales de Chromebooks, las computadoras con sistema operativo Chrome OS, además de en muchísimos modelos de computadoras personales enfocadas al software libre y, teóricamente, cualquier sistema con arquitectura IA-32, x86-64, ARM, ARM64, MIPS o RISC-V puede ejecutarlo. 

La pricipal ventaja de utilizar coreboot radica en que todo su código es libre, de manera que se puede minimizar la superficie de riesgo a ataques, porque se lo puede conocer en su totalidad. Además, al ser muy minimalista es rápido para arrancar y muy liviano. También es más flexible y se lo puede customizar según las necesidades de los usuarios.

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


