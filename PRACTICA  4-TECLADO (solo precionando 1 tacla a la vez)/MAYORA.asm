;===========================================================
; TECLADO
list p=16f873a 
include <p16f873a.inc> 
__CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

;===========================================================
;Librerias 
		CBLOCK 0Ch
		endc 
;==============================================================
;variables 

	CONT1 equ 20h			;indica cuantos numeros se han guardado
	CONT2 equ 21h			;indica cuaos numeros guardados se han mostrado
	CONT3 equ 22h			;indica que precione numeral	
	CONT4 equ 23h			;indicador para ordenar numeros
	CONT5 equ 24h			;indicador para ordenar numeros
	CONT6 equ 24h			;indicador para ordenar numeros
	CUENTA equ 07h			;indica cuantos numeros se van a ordenar
	LISTA equ 40h			;se guarda momentaneamene el digito		
	LISTA1 equ 41h			;se guarda el digito 1 de la cedula
	LISTA2 equ 42h			;se guarda el digito 2 de la cedula	
	LISTA3 equ 43h			;...
	LISTA4 equ 44h
	LISTA5 equ 45h
	LISTA6 equ 46h
	LISTA7 equ 47h
	LISTA8 equ 48h

;===========================================================
;REDIRECCIONAMIENTO: redireciona el programa dependiendo si se 
;activó un reset o una interrupcion externa

RESET	
	ORG 0
	GOTO INICIO				;me dirijo al inicio del programa
	ORG 4
	GOTO LISTO				;voy a la rutina de interrupcion

;=================================================================
;RUTINA DE INTERRUPCION: se activa solo si se preciona asterisco y 
;se encarga de mostrar los numeros ya guardadados

LISTO
	BCF INTCON,INTE			;deshabilito interruocuiones externas "RB0"
	call Retardo_2ms		;espero un instante
	MOVF CONT1,w			;
	SUBLW 08H				;
	BTFSS STATUS,Z			;si aun no he guardado los 8 numeros
	GOTO VOLVER				;regresr
	MOVF CONT3,w			;
	SUBLW 55H				;
	BTFSS STATUS,Z			;si aun no se a precionado numeral
	GOTO VOLVER				;regresr
	GOTO COMPROBAR2			;si ya lo hice mostrar uno de los números

VOLVER
	BCF INTCON,INTF			;indico que ya se ejecuto la inerrupción
	BSF INTCON,INTE			;habilito interruocuiones externas "RB0"
	RETFIE					;regreso

;=================================================================
;SUBRUTINA GRABADO: se ejecutara solo al haber introducido los 8
;digitos de la cedula, se trara de un bucle del que solo se saldra
;al precionar la tecla numeral

GRABADO
	BCF PORTC,7				;me aceguro que RC7 este en nivel bajo
	BTFSS PORTC,2			;solo si se preciono numeral			
	GOTO MOSTRAR			;ir a mostrar
	GOTO GRABADO

;=================================================================
;SUBRUTINA MOSTRAR Y ACTIVO: se activa solo si ya se han guardado 
;los 8 digitos de la cedula y si se ha presiondo la tecla numeral,
;se encrga de avisarnos que ta se han guardado los 8 digitos al 
;enceder el LED activo y mostrar en el display un guion, solo se 
;saldra de esta subrutina con una interupcion

MOSTRAR 
	MOVF CONT1,w				
	SUBLW 08H
	BTFSS STATUS,Z			;si aun no he guardado los 8 numeros
	GOTO TECLADO			;esperar a que se precione otra tecla
	MOVLW 55H		
	MOVWF CONT3				;indico que se preciono numeral
	CALL ORDENAR
	MOVLW B'11111111'		
	MOVWF PORTA				;apagar Led grabando
	GOTO ACTIVO				;encener led activo

ACTIVO
	BCF	PORTC,7				;me aceguro que RC7 este en nivel bajo
	MOVF CONT2,w			;
	SUBLW 08H				;
	BTFSC STATUS,Z			;si ya guardade los 8 numeros
	GOTO FIN				;finalizar el programa
	MOVLW B'11111011'		;sino enciendo led ativo
    MOVWF PORTA				;
	MOVLW B'01111111'		;muestro un guion en el display
    MOVWF PORTB				;
	CALL Retardo_2s			;espero un tiempo
	MOVLW B'11111111'		;apago led acivo
    MOVWF PORTA				;
	MOVLW B'11111111'		;muestro un guion en el display
    MOVWF PORTB				;
	CALL Retardo_2s			;espero un tiempo
	goto ACTIVO				;repito


;=================================================================
;SUBRUTINA ORDENAR: una vez introducido los 8 numeros, esta subrutina 
;los ordenara de forma ascendente, se ordenaran un numero de CUENTA+1. 
;Por ejemplo como CUENTA es 7, se ordenan de menor a mayor 8 valores a 
;partir de la dirección 41h=LISTA1, luego de esto, convertira los 
;numeros ordenados  anteriormente en su equivalente 7 segmentos 

ORDENAR	
		MOVLW CUENTA		;aviso cuantos nuemros voy a ordenar
		MOVWF CONT4			;lo muevo alontador 1
BUCLE1	MOVLW CUENTA		;aviso cuantos nuemros voy a ordenar
		MOVWF CONT5			;lo muevo a contador 2
		MOVLW LISTA8		
		MOVWF FSR			;apunto al comienzo de la lista
BUCLE2
		CALL ORDENADOS		;llamo a ordenados
		DECF FSR,1			;incremento el apuntador
		DECFSZ CONT5		;indico que verifique 2 numeros
		GOTO BUCLE2			;verifico los siguientes 2 numeros
		DECFSZ CONT4		;decrementamos el cotador
		GOTO BUCLE1			;vuelvo a revisar la lista
		GOTO CONVERTIR		;si ya revise todo terminar

ORDENADOS
		MOVF INDF,W			;guardo w lo que este en la direccion del apuntador
		DECF FSR,1			;decremento el apuntador
		SUBWF INDF,W		;resto el primer numero con el segundo
		BTFSS STATUS,C		;elnumero es mayor o menor?
		GOTO NOHACERNADA	;si es menor no hacer nada
		MOVF INDF,W			;si es mayor intercambiar numeros
		INCF FSR,1
		XORWF INDF,F
		XORWF INDF,W
		XORWF INDF,F
		DECF FSR,1			
		MOVWF INDF

NOHACERNADA
		INCF FSR,1			
		RETURN				;revisar siguiente par de numeros

CONVERTIR
		MOVLW 41H
		MOVWF FSR			;apunto al comienzo de la lista
		CLRF CONT6			;me aseguro que contador6=0
VOLVER4
		INCF CONT6,1		;incremento el contador 6	
		GOTO SIETESEG		;convierto a 7 segmentos
VOLVER3	
		INCF FSR,1			;apunto al siguiete numero		
		MOVF CONT6,w		;reviso el contador 6
		SUBLW 08H			;
		BTFSC STATUS,Z		;si aun no he guardado los 8 numeros
		RETURN				;regresr
		GOTO VOLVER4		;si lo hice revisar el siguiente numero
	
SIETESEG
		MOVF INDF,W
		SUBLW 00H			
		BTFSC STATUS,Z			
		GOTO COD0			 
		MOVF INDF,W
		SUBLW 01H			
		BTFSC STATUS,Z			
		GOTO COD1			
		MOVF INDF,W
		SUBLW 02H
		BTFSC STATUS,Z			
		GOTO COD2			
		MOVF INDF,W
		SUBLW 03H
		BTFSC STATUS,Z			
		GOTO COD3
		MOVF INDF,W
		SUBLW 04H
		BTFSC STATUS,Z			
		GOTO COD4
		MOVF INDF,W
		SUBLW 05H
		BTFSC STATUS,Z			
		GOTO COD5
		MOVF INDF,W
		SUBLW 06H
		BTFSC STATUS,Z			
		GOTO COD6	
		MOVF INDF,W
		SUBLW 07H
		BTFSC STATUS,Z			
		GOTO COD7
		MOVF INDF,W
		SUBLW 08H
		BTFSC STATUS,Z			
		goto COD8
		MOVF INDF,W
		SUBLW 09H
		BTFSC STATUS,Z			
		goto COD9
		MOVF INDF,W
		GOTO SIETESEG

COD0	movlw B'10000000'	;muestro que se guardo el digito 1
		MOVWF INDF
		goto VOLVER3
COD1	movlw B'11110011'	;muestro que se guardo el digito 1
		MOVWF INDF
		goto VOLVER3
COD2	movlw B'01001000'	;muestro que se guardo el digito 2
		MOVWF INDF
		goto VOLVER3
COD3	movlw B'01100000'
		MOVWF INDF
		goto VOLVER3
COD4	movlw B'00110011'
		MOVWF INDF
		goto VOLVER3
COD5	movlw B'00100100'
		MOVWF INDF
		goto VOLVER3
COD6	movlw B'00000100'
		MOVWF INDF
		goto VOLVER3
COD7	movlw B'11110000'
		MOVWF INDF
		goto VOLVER3
COD8	movlw B'00000000'
		MOVWF INDF
		goto VOLVER3	
COD9	movlw B'00100000'
		MOVWF INDF
		goto VOLVER3


;==================================================================
;RUTINA DE INICIO: configura los puertos, pone a 0 los contadores Y
;entra en un bucle en el que solo saldra si se preciona el boton RESET


INICIO

	BCF STATUS,RP1			;
	BSF STATUS,RP0			;coloco en 1 el bit RP0 (seleccion banco 1)
  	MOVLW B'00000001'		;configuro el puerto B
    MOVWF PORTB				;todo salidas expeto RB0
    MOVLW B'00001111'		;configuro el puerto C
    MOVWF PORTC				;mitad del puerto C entradas y mitad salidas
    movlw 06h				;configuro el puerto A como entrada digital
	movwf ADCON1			;
	movlw B'00000001'		;configuro el puerto A como salida
	movwf PORTA				;RA0=ENTRADA
	BSF INTCON,GIE			;hago posible que se puedan hbilitar inerrupciones
	BSF INTCON,INTE			;habilito interruocuiones externas "RB0"
	BCF INTCON,INTF			;me aseguro que haya interrupciones 
	BCF STATUS,RP0			;coloco en 0 el bit RP0 (seleccion banco 0)	
	MOVLW 0FFh				;
   	MOVWF PORTB				;apago el display
	MOVLW 0FFh				;
   	MOVWF PORTA				;apago los leds
	MOVLW 0FFh				;
   	MOVWF PORTC				;apago el teclado	
   	CLRF CONT1				;contador 1 en 0
   	CLRF CONT2				;contador 2 en 0
   	CLRF CONT3				;contador 3 en 0			
   	CLRF CONT4				;contador 4 en 0
   	CLRF CONT5				;contador 5 en 0
   	CLRF CONT6				;contador 6 en 0

BUCLE
	BTFSS PORTA,0			;solo sale si se preciona RESET
	GOTO EMPIEZA
	GOTO BUCLE

;===========================================================
;SUBRUTINA EMPIEZA: se encarga de idicar en el dislay que se
;han presionado 0 digitos de enceder el led grabando, para
;indicar que se estan guardando los digios

EMPIEZA
	MOVLW B'10000000'		;indico en el display que se han
	MOVWF PORTB				;presionado 0 digitos
	MOVLW B'11111101'
   	MOVWF PORTA				;enciendo el led GRABANDO
	CALL Retardo_2s			;espero un tiempo
	
;===========================================================
;SUBRUTINA TECLADO: se encarga de idicanos cual fue la tecla
;presionda en el teclado
	
TECLADO

		MOVLW 0FFh
   		MOVWF PORTC			;descelecciono todas la colunas y filas

		BCF		PORTC,4 	;coloca en bajo el pin B4 (escaneo culmna 1)
		BTFSS	PORTC,0 	;si el pin C0=0 envia el numero 0 de lo contrario salta fila siguiente
		GOTO	UNO
		BTFSS	PORTC,1 	;si el pin C1=0 envia el numero 2 de lo contrario salta fila siguiente
		GOTO	DOS
		BTFSS	PORTC,2		;si el pin C2=0 envia el numero 4 de lo contrario salta fila siguiente
		GOTO	TRES
		
		BSF		PORTC,4  	;coloco en alto el pin B4 
		BCF		PORTC,5  	;coloco en B5 el pin B4 (escaneo columna 2)
		BTFSS	PORTC,0		;repito lo mismo que en la columna 1 
		GOTO	CUATRO
		BTFSS	PORTC,1
		GOTO	CINCO
		BTFSS	PORTC,2
		GOTO	SEIS

		BSF		PORTC,5  
		BCF		PORTC,6
		BTFSS	PORTC,0
		GOTO	SIETE
		BTFSS	PORTC,1
		GOTO	OCHO
		BTFSS	PORTC,2
		GOTO	NUEVE
	
		BSF		PORTC,6
		BCF		PORTC,7
		BTFSS	PORTC,0
		GOTO	TECLADO
		BTFSS	PORTC,1
		GOTO	CERO
		BTFSS	PORTC,2
		GOTO	NUMERAL
		BSF		PORTC,7
		GOTO	TECLADO		;vuelvo a TECLADO

;===============================================================
;SUBRUTINA GUARDAR: se encarga de guardar el el numero 
;del digito precionado en la LISTA 

CERO 	movlw 00H		
		movwf LISTA			;guardo el codigo de 0 en LISTA
		goto COMPROBAR		;ir a comprobar

UNO		movlw 01H	
		movwf LISTA			;guardo el codigo de 1 en LISTA
	 	goto COMPROBAR		;ir a comprobar

DOS		movlw 02H			;repito...
		movwf LISTA
		goto COMPROBAR

TRES	movlw 03H
		movwf LISTA
		goto COMPROBAR

CUATRO	movlw 04H
		movwf LISTA
		goto COMPROBAR

CINCO	movlw 05H
		movwf LISTA
		goto COMPROBAR

SEIS	movlw 06H
		movwf LISTA
		CALL COMPROBAR

SIETE	movlw 07H
		movwf LISTA
		goto COMPROBAR

OCHO	movlw 08H
		movwf LISTA
		goto COMPROBAR

NUEVE	movlw 09H
		movwf LISTA
		goto COMPROBAR

NUMERAL MOVF CONT1,w
		SUBLW 08H
		BTFSC STATUS,Z			;SI ES 8 MOSTRAR
		GOTO MOSTRAR
		call Retardo_2s
		goto TECLADO

;=================================================================
;SUBRUTINA COMPROBAR: se encarga de comprobar cual de los 8
;digitos de la cedula fue el precionado, utilizando el contador 1,
;una vez comprobado, se guardara en la posicion de la lista
;al que pertenece y se mostrara en el display cuantos digitos se han
;presionado

COMPROBAR
	MOVF CONT1,w
	SUBLW 08H				;
	BTFSC STATUS,Z			;si ya se precionaron los 8 digitos
	GOTO TECLADO			;esperar a que se precione numeral
	
	INCF CONT1,1			;sino aumentar contador
	
	MOVF CONT1,w			
	SUBLW 01H
	BTFSC STATUS,Z			;si cont1 es 1 ir a guardar en Lista1			
	GOTO UNO1				;y mostrar 1 en el display

	MOVF CONT1,w			;sino
	SUBLW 02H
	BTFSC STATUS,Z			;si cont1 es 2 ir a guardar en Lista2	
	GOTO DOS1				;y mostrar 2 en el display 

	MOVF CONT1,w			;repito...
	SUBLW 03H
	BTFSC STATUS,Z			
	GOTO TRES1

	MOVF CONT1,w
	SUBLW 04H
	BTFSC STATUS,Z			
	GOTO CUATRO1

	MOVF CONT1,w
	SUBLW 05H
	BTFSC STATUS,Z			
	GOTO CINCO1

	MOVF CONT1,w
	SUBLW 06H
	BTFSC STATUS,Z			
	GOTO SEIS1

	MOVF CONT1,w
	SUBLW 07H
	BTFSC STATUS,Z			
	GOTO SIETE1

	MOVF CONT1,w
	SUBLW 08H
	BTFSC STATUS,Z			
	GOTO OCHO1
	goto ESPERAR

	
UNO1
	movf LISTA,W		;recupero el codigo antes guardado
	movwf LISTA1		;lo guardo en lista1
	movlw B'11110011'	;muestro que se guardo el digito 1
	movwf PORTB			;
	call Retardo_2s		;espero un tiempo
	goto ESPERAR		;espero a que se precione otro digito

DOS1
	movf LISTA,w		;recupero el codigo antes guardado
	movwf LISTA2		;lo guardo en lista2
	movlw B'01001000'	;muestro que se guardo el digito 2
	movwf PORTB			;
	call Retardo_2s		;espero un tiempo
	goto ESPERAR		;espero a que se precione otro digito

TRES1
	movf LISTA,w		;repito...
	movwf LISTA3
	movlw B'01100000'
	movwf PORTB
	call Retardo_2s
	goto ESPERAR

CUATRO1
	movf LISTA,w
	movwf LISTA4
	movlw B'00110011'
	movwf PORTB
	call Retardo_2s
	goto ESPERAR

CINCO1
	movf LISTA,w
	movwf LISTA5
	movlw B'00100100'
	movwf PORTB
	call Retardo_2s
	goto ESPERAR

SEIS1
	movf LISTA,w
	movwf LISTA6
	movlw B'00000100'
	movwf PORTB
	call Retardo_2s
	goto ESPERAR

SIETE1	
	movf LISTA,w
	movwf LISTA7
	movlw B'11110000'
	movwf PORTB
	call Retardo_2s
	goto ESPERAR

OCHO1
	movf LISTA,w
	movwf LISTA8
	movlw B'00000000'
	movwf PORTB
	call Retardo_2s
	goto GRABADO

NUEVE1
	movlw B'00100000'
	movwf PORTB
	call Retardo_2s
	goto TECLADO


;============================================================================
;SUBRUTINA ESPERAR: esta subrutina funciona para que si se deja precionado el  
;boton de una tecla solo se guarde 1 vez el digito y hasta que no se deje de
;presionar no se podra ingresar otro digito

ESPERAR
		movf PORTC,W
		andlw 07h
		sublw B'00000111'
		btfss STATUS,Z			;salta un espacio si el resultado no es 0
		goto ESPERAR			;
		call Retardo_2s			
		GOTO TECLADO	


;=======================================================================
;SUBRUTINA COMPROBAR2: se encarga de mostrar los digitos antes guardados,
;en el display utilizando el contador 2

COMPROBAR2
	
	INCF CONT2,1		;indico que se presion asterisco

	MOVF CONT2,w		
	SUBLW 01H			
	BTFSC STATUS,Z			
	GOTO DIG1			;si cont2 es 1 ir a mostrar el digito 1

	MOVF CONT2,w		;sino ver si cont2 es 2
	SUBLW 02H
	BTFSC STATUS,Z			
	GOTO DIG2			;si cont2 es 3 ir a mostrar el digito 3

	MOVF CONT2,w		;repito...
	SUBLW 03H
	BTFSC STATUS,Z			
	GOTO DIG3

	MOVF CONT2,w
	SUBLW 04H
	BTFSC STATUS,Z			
	GOTO DIG4

	MOVF CONT2,w
	SUBLW 05H
	BTFSC STATUS,Z			
	GOTO DIG5

	MOVF CONT2,w
	SUBLW 06H
	BTFSC STATUS,Z			
	GOTO DIG6

	MOVF CONT2,w
	SUBLW 07H
	BTFSC STATUS,Z			
	GOTO DIG7

	MOVF CONT2,w
	SUBLW 08H
	BTFSC STATUS,Z			
	goto DIG8
	

DIG1	
	MOVF LISTA1,w		;recupero el digito 1
	movwf PORTB			;lo muetro en el display
	CALL Retardo_1s		;espero un tiempo		
	BCF INTCON,INTF		;indico que fializo la interrupcion
	BSF INTCON,INTE		;habilito interruocuiones externas "RB0"
	RETFIE				;espero a que se presione asterisco 

DIG2
	MOVF LISTA2,w		;recupero el digito 1
	movwf PORTB			;lo muetro en el display
	CALL Retardo_1s		;espero un tiempo
	BCF INTCON,INTF		;indico que fializo la interrupcion
	BSF INTCON,INTE		;habilito interruocuiones externas "RB0"
	RETFIE				;espero a que se presione asterisco

DIG3
	MOVF LISTA3,w		;repito...
	movwf PORTB
	CALL Retardo_1s			
	BCF INTCON,INTF
	BSF INTCON,INTE		
	RETFIE

DIG4
	MOVF LISTA4,w
	movwf PORTB
	CALL Retardo_1s
	BCF INTCON,INTF
	BSF INTCON,INTE		
	RETFIE

DIG5
	MOVF LISTA5,w
	movwf PORTB
	CALL Retardo_1s
	BCF INTCON,INTF
	BSF INTCON,INTE		
	RETFIE

DIG6
	MOVF LISTA6,w
	movwf PORTB
	CALL Retardo_1s
	BCF INTCON,INTF
	BSF INTCON,INTE		
	RETFIE

DIG7
	MOVF LISTA7,w
	movwf PORTB
	CALL Retardo_1s
	BCF INTCON,INTF
	BSF INTCON,INTE		
	RETFIE

DIG8
	MOVF LISTA8,w
	movwf PORTB
	CALL Retardo_1s
	BCF INTCON,INTF			;mantengo desabilitadas las interrupciones
	BCF INTCON,INTE			;ya que termine de mostrar los digitos
	RETFIE


;====================================================================
;SUBRUTINA FIN: si ya finalice espero un tiempo y reinicio el programa

FIN	
	call Retardo_2s			;espero un tiempo
	call Retardo_2s			;espero un tiempo
	call Retardo_2s			;espero un tiempo
	goto INICIO				;reinicio el programa

	include <RETARDOS.inc>

	END

