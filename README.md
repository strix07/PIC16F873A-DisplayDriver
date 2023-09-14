# Desarrollo de un sistema para ingreso y visualización de números en PIC 16F873A utilizando el metodo burbaja 
## Introducción

El presente proyecto consistió en el desarrollo de un sistema capaz de recibir un número de identificación por entrada de teclado matricial, ordenar dicho número de forma ascendente y desplegarlo en un visualizador de 7 segmentos. Todo ello implementado en un microcontrolador PIC 16F873A.

## Descripción técnica
El sistema fue desarrollado mediante las siguientes etapas:

Declaración de variables tipo contador y arreglo en memoria RAM para almacenamiento temporal y ordenado de dígitos ingresados.
Configuración de puertos de E/S digitales y comunicación serial así como fuses para oscilador interno.
Desarrollo de rutina para identificación de tecla presionada por multiplexación de líneas de teclado matricial 3x4.
Almacenamiento en arreglo de cada dígito ingresado a través de teclado numérico mediante contadores.
Ordenamiento ascendente (burbuja) del arreglo en memoria al completar ingreso promovido por tecla especial.
Conversión a código de 7 segmentos y envío a visualizador multiplexado.
Manejo de interrupción externa para mostrar los dígitos ordenados secuencialmente en cada flanco.
Simulación, depuración y pruebas en ambiente Proteus y físicamente.

## Descripción del hardware
A nivel de hardware se utilizaron los siguientes componentes principales:

- Microcontrolador PIC16F873A en encapsulado DIP40
- Crystal de 4MHz
- Teclado matricial de 12 teclas dispuestas en matriz de 3 filas x 4 columnas
- Dos display de ánodo común de 7 segmentos con sus resistencias de limitación
- Tres LEDs indicadores con sus respectivas resistencias
- Pulsadores de reset e interrupción externa
- Fuente de alimentación regulada de 5V

El microcontrolador se encarga de la generación de las señales de control y multiplexación para el teclado matricial y los displays. Los LEDs se usan para indicar distintos estados del sistema.

## Descripción del software
El flujo del programa implementado consiste en:

- Configuración de puertos y periféricos al inicio
- Detección de tecla presionada por escaneo de filas y columnas
- Almacenamiento temporal del dígito detectado
- Verificación e ingreso ordenado a arreglo en memoria
- Ordenamiento ascendente tipo burbuja del arreglo
- Conversión a código de 7 segmentos
- Envío a display multiplexado
- Rutina de interrupción para mostrar dígitos ordenados

El software fue desarrollado en su totalidad en lenguaje ensamblador, utilizando el compilador MPASM provisto por Microchip.

## Resultados
El sistema cumplió los requerimientos y restricciones planteados. Se verificó su capacidad de adquirir un número por teclado, procesarlo internamente y desplegarlo ordenado en un visualizador de 7 segmentos mediante interrupciones periódicas. El correcto funcionamiento se corroboró tanto en simulación como en implementación real.

## Diagrama esquemático

<br>
<div align="center">
  <img src="https://github.com/strix07/PIC16F873A-DisplayDriver/assets/142692042/5a84e97e-c149-49ba-9301-bdfe2309e9fc" alt="Texto Alternativo de la Imagen">
</div>

