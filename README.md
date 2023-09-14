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

## Resultados
El sistema cumplió los requerimientos y restricciones planteados. Se verificó su capacidad de adquirir un número por teclado, procesarlo internamente y desplegarlo ordenado en un visualizador de 7 segmentos mediante interrupciones periódicas. El correcto funcionamiento se corroboró tanto en simulación como en implementación real.

## Diagrama esquemático

<br>
<div align="center">
  <img src="https://github.com/strix07/PIC16F873A-DisplayDriver/assets/142692042/5a84e97e-c149-49ba-9301-bdfe2309e9fc" alt="Texto Alternativo de la Imagen">
</div>

