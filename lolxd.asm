; ADC y PULSOS en bucle, interrupciones USB-UART , RBIF(RB0) , INTF(RB7)
; RB3 = STEP , RB2 = SLEEP , RB1 = DIR

; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0x23E1
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

 ;Variables
 W_TEMP            EQU 0x20
 STATUS_TEMP       EQU 0x21
 velocidad         EQU 0x22
 contDelay         EQU 0x23
 nivel             EQU 0x24
 estado_motor      EQU 0x25
 delayL            EQU 0x26
 delayH            EQU 0x27
 comp              EQU 0x28
 estado_direccion  EQU 0x29


 ORG   0x00
 GOTO  INICIO

 ORG   0x04
 GOTO  ISR

 ORG   0x05

 INICIO
    ; Banco 0
    BCF  STATUS, RP0
    BCF  STATUS, RP1

    ; RCSTA: SPEN=1, CREN=1, RX9=0
    MOVLW  B'10010000'    ; SPEN=1 (bit7), CREN=1 (bit4)
    MOVWF RCSTA

    ; CLK en FOSC/8, canal AN0
    MOVLW B'01000001'
    MOVWF ADCON0


    ; BANCO 1
    BSF  STATUS, RP0
    BCF  STATUS, RP1

    ; Habilitar interrupciones por recepción 
    BSF  PIE1, RCIE 

    ; TXSTA: BRGH=1, TXEN=1, 8-bit, SYNC=0
    MOVLW B'00100100'; BRGH=1 (bit2), TXEN=1 (bit5) => binario aproximado
    MOVWF TXSTA

    ; Configurar BAUD: Fosc=4MHz, Baud=9600, BRGH=1 -> SPBRG = 25
    MOVLW D'25'
    MOVWF SPBRG

    MOVLW B'10000001' ; coloco entradas RB7 y RB0
    MOVWF TRISB

    ; RA0 entrada
    BSF  TRISA, RA0

    BCF TRISC,RC6 ; El TX (RC6) debe ser salida
    BSF TRISC,RC7 ; RX (RC7) debe ser entrada

    ; Refs en VDD y VSS, y los LSB en ADRESL
    CLRF ADCON1

    MOVLW B'11011000' ; Hab interrpciones globales: Perofericas, RB0 y por cambio
    MOVWF INTCON

    CLRF OPTION_REG 

    MOVLW B'10000000'; Hab interrpciones por cambios RB7
    MOVWF IOCB

    MOVLW B'10000001'
    MOVWF WPUB


    ; BANCO 3
    BSF  STATUS, RP0
    BSF  STATUS, RP1

    ; BAUDCTL: BRG16=0 (usar SPBRG de 8-bit)
    MOVLW B'01000000'
    MOVWF BAUDCTL

    ; Entrada analógica A0 y digital todas las otras
    MOVLW B'00000001'
    MOVWF ANSEL
    CLRF  ANSELH

    ; Banco 0
    BCF  STATUS, RP0
    BCF  STATUS, RP1

    CLRF   velocidad
    CLRF   contDelay     
    CLRF   nivel         
    CLRF   estado_motor  
    CLRF   delayL        
    CLRF   delayH
    CLRF   comp
    CLRF   estado_direccion
    CLRF   PORTC


BUCLE
    BSF  ADCON0, 1        ; Inicia primera conversión
    CALL delay_1ms

    CHECKEO
    BTFSC ADCON0, 1
    GOTO CHECKEO

    ; Guarda resultado
    MOVF ADRESH, W
    MOVWF velocidad 

    MOVF    velocidad, W
    SUBLW   d'51'
    BTFSS   STATUS, C
    GOTO    Nivel_2
    MOVLW   .1
    MOVWF   nivel
    GOTO    PULSOS

    Nivel_2    ; <=100 -> usar 101
    MOVF    velocidad, W
    SUBLW   d'101'
    BTFSS   STATUS, C
    GOTO    Nivel_3
    MOVLW   .2
    MOVWF   nivel
    GOTO    PULSOS

    Nivel_3    ; <=150 -> usar 151
    MOVF    velocidad, W
    SUBLW   d'151'
    BTFSS   STATUS, C
    GOTO    Nivel_4
    MOVLW   .3
    MOVWF   nivel
    GOTO    PULSOS

    Nivel_4    ; <=200 -> usar 201
    MOVF    velocidad, W
    SUBLW   d'201'
    BTFSS   STATUS, C
    GOTO    Nivel_5
    MOVLW   .4
    MOVWF   nivel
    GOTO    PULSOS


    Nivel_5    ; else -> Nivel_5
    MOVLW   .5
    MOVWF   nivel
    GOTO    PULSOS

PULSOS
      ; Pone un pulso en STEP
      BSF     PORTB, RB3            ; STEP = 1
      CALL    DELAY_VEL             ; delay según nivel
      BCF     PORTB, RB3            ; STEP = 0
      CALL    DELAY_VEL

    GOTO BUCLE


DELAY_VEL
    MOVF    nivel, W
    ADDWF   PCL, F
    GOTO    VEL_1
    GOTO    VEL_2
    GOTO    VEL_3
    GOTO    VEL_4
    GOTO    VEL_5


VEL_1                         ; 20 Hz -> 25 000 µs
    MOVLW   .250              ; 250 * 100µs = 25ms
    CALL    DELAY_PRECARGA
    RETURN

VEL_2                         ; 50 Hz -> 10 000 µs
    MOVLW   .100              ; 10ms
    CALL    DELAY_PRECARGA
    RETURN

VEL_3                         ; 100 Hz -> 5 000 µs
    MOVLW   .50               ; 5ms
    CALL    DELAY_PRECARGA
    RETURN

VEL_4                         ; 200 Hz -> 2 500 µs
    MOVLW   .25               ; 2.5ms
    CALL    DELAY_PRECARGA
    RETURN

VEL_5                         ; 400 Hz -> 1 250 µs
    MOVLW   .13               ; ~1.3ms
    CALL    DELAY_PRECARGA
    RETURN


DELAY_PRECARGA
        MOVWF    delayH
    DELAY_H
        MOVLW    .100
        MOVWF    delayL
    DELAY_L
        DECFSZ   delayL, F
        GOTO     DELAY_L
        DECFSZ   delayH, F
        GOTO     DELAY_H
        RETURN


ISR
        ; Guarda contexto
        MOVWF   W_TEMP	
        SWAPF  	STATUS, W	
        MOVWF   STATUS_TEMP

        ; UART: ¿Llego dato por EUSART? 
        ; PIR1.RCIF = FLAG DE RECEPCIÓN
        BTFSS   PIR1, RCIF
        GOTO    BOTONES

        ; Si hay dato, orimero chequear OVERRUN OERR
        BTFSC   RCSTA, OERR       ; Si OERR=1 -> Limpiar CREN
        GOTO    CLEAR_OERR

        ; Leer RCREG (Esto borra RCIF)
        MOVF    RCREG, W
        MOVWF   comp
        ; Comparar 
        XORLW   '1'
        BTFSC   STATUS, Z         ; Si no es 1,  Si es 1 AVANCE
        GOTO    AVANCE
        MOVF    comp, W
        XORLW   '2'
        BTFSC   STATUS, Z         ; Si no es 2,  Si es 2  REVERSA
        GOTO   REVERSA
        MOVF    comp, W
        XORLW   '3'
        BTFSC   STATUS, Z         ; Si no es 3,  Si es 3  PRENDE
        GOTO   PRENDE
        MOVF    comp, W
        MOVF    comp, W
        XORLW   '4'
        BTFSC   STATUS, Z
        GOTO    EnviarVelocidad
        GOTO    BOTONES

        EnviarVelocidad
            MOVF    velocidad, W
            CALL    EnviarUART
            GOTO    salir_ISR

    CLEAR_OERR
        ; Limpiar OVERRUN: CREN = 0 ; CREN = 1
        BCF     RCSTA, CREN
        BSF     RCSTA, CREN

    BOTONES
        BTFSC	INTCON, INTF
      GOTO	PRENDE

      BTFSC	INTCON, RBIF
      GOTO	DIRECCION
      GOTO	salir_ISR

    PRENDE
        BCF	INTCON, INTF
        ; Cambiar estado ON/OFF
        BTFSS   estado_motor, 0       ; estaba encendido?
        GOTO    MOTOR_ON              ; no estaba ? encender
        GOTO    MOTOR_OFF             ; si estaba ? apagar

        MOTOR_ON
            BSF     PORTB, 2              ;  motor ON
            BSF     estado_motor, 0       ; guarda estado (encendido)
            GOTO    salir_ISR

        MOTOR_OFF
            BCF     PORTB, 2              ;  motor OFF
            BCF     estado_motor, 0       ; guarda estado (apagado)
            GOTO    salir_ISR


    DIRECCION
      MOVF	PORTB, W
        BCF     INTCON, RBIF 
      BTFSC	PORTB, RB7
      GOTO salir_ISR

        ; Cambiar estado ON/OFF
        BTFSS   estado_direccion, 0       ; estaba en avance?
        GOTO    AVANCE                    ; no estaba ? avance
        GOTO    REVERSA                   ; si estaba ? reversa

        AVANCE
            BSF     PORTB, 1              ; Avance
            BSF     estado_direccion, 0   ; guarda estado (avance)
            GOTO    salir_ISR

        REVERSA
            BCF     PORTB, 1		      ; Reversa
            BCF     estado_direccion, 0   ; guarda estado (reversa)
            GOTO    salir_ISR

    EnviarUART
    BTFSS   PIR1, TXIF   ; Esperar a que TXREG esté vacío
    GOTO    EnviarUART
    MOVWF   TXREG        ; Enviar el contenido de W
    RETURN
    
    salir_ISR
        ; Recupera contexto
        SWAPF	STATUS_TEMP, W
        MOVWF	STATUS
        SWAPF	W_TEMP, F
        SWAPF	W_TEMP, W
        RETFIE


delay_1ms
        MOVLW D'250'     
        MOVWF contDelay      
    LOOP_delay
        NOP               
        NOP               
        NOP                
        NOP                
        DECFSZ contDelay, F
        GOTO LOOP_delay
    RETURN


END