# Tp_CintaTransportadora
Trabajo Práctico Final ED2  

Sistema de control de una cinta transportadora con regulación de velocidad, cambio de sentido y función de pausa, empleando un motor paso a paso proveniente de una impresora 3D y controlado mediante el microcontrolador PIC16F887 programado en lenguaje ensamblador. El sistema incorpora comunicación UART con LabView para la supervisión y ajuste de parámetros en tiempo real. La implementación física del circuito se realizó sobre una placa perforada (veroboard), en la cual se soldaron todos los componentes para garantizar un montaje estable y compacto y se imprimio el modelo fisico de la cinta para una mejor presentacion.



## 📷 Vista General del Proyecto

Este repositorio contiene:

- Código ensamblador (`TP_FINAL.asm`)
- Código en hexadecimal (`TP_FINAL.hex`)
- Programa de LabVIEW para el control manual via UART (`TP_FINAL_control_manual.vi`)
- Programa de Proteus con simulación del circuito (`TP_FINAL_simulación.pdsprj`)
- Video del circuito funcionando en modo manual (`Modo manual.mp4`)
- Video del circuito funcionando en modo automático  (`Modo automático.mp4`)
- Diagrama de bloques del funcionamiento
- Documentación para instalar, compilar y usar el sistema

---
## 📸 Fotografía del Circuito con la Cinta
![Imagen de WhatsApp 2025-11-17 a las 19 14 00_9baf1325](https://github.com/user-attachments/assets/357fcd24-e373-479e-8566-1d33d2c2bf4a)

## 📸 Fotografía del Motror NEMA 17
![Imagen de WhatsApp 2025-11-17 a las 19 14 01_238aafbf](https://github.com/user-attachments/assets/93c75e2a-0d03-4a2e-a315-d440ac78e733)

## 💡 Diagrama Esquemático
![Imagen de WhatsApp 2025-11-17 a las 19 45 54_e1ed6fb2](https://github.com/user-attachments/assets/a7f299b9-0648-4af7-9e0e-72317a85d198)


## 💡 Descripcion General
## ⚡ Velocidad


El potenciómetro genera una señal analógica que, mediante el módulo ADC del PIC16F887, se convierte en un valor digital. Este valor es comparado con cinco rangos predefinidos que determinan las distintas velocidades de operación. Según el rango detectado, se selecciona la frecuencia de pulsos enviada al driver A4988, el cual controla el motor paso a paso. De esta manera, el sistema ajusta automáticamente la velocidad de la cinta transportadora en función de la posición del potenciómetro.

## ⏸️🔄 Pausa y Sentido de Giro

El pulsador encargado de la pausa está conectado al pin RB0, el cual utiliza una interrupción externa para detener el movimiento. Cuando se activa esta interrupción, el programa envía un nivel lógico alto al pin SLEEP del driver A4988, colocándolo en estado de reposo y deteniendo la cinta.

El sentido de giro se controla mediante el pulsador ubicado en RB7, configurado como interrupción por cambio de estado en el puerto B. Al detectar la transición en este pin, se modifica el nivel lógico enviado al pin DIR del driver, invirtiendo así la rotación del motor y el desplazamiento de la cinta.

## ⚙️ Interrupciones

Las interrupciones cumplen la función de detener momentáneamente el bucle principal para ejecutar una acción urgente de la forma más rápida y eficiente posible. En este proyecto, el bucle principal se encarga de evaluar continuamente la velocidad de la cinta, verificando en todo momento si el potenciómetro ha cambiado de valor para actualizar la frecuencia de pulsos enviada al motor.

Cada vez que ocurre una interrupción, el programa analiza cuál fue la causa y ejecuta la rutina correspondiente. En nuestro sistema existen tres fuentes de interrupción:

Interrupción por UART (USART): se activa al enviar o recibir un dato, permitiendo comunicación con LabView.

Interrupción externa en RB0: utilizada para pausar o reanudar la cinta activando el pin SLEEP del driver.

Interrupción por cambio en el puerto B (RB7): empleada para modificar el sentido de giro del motor cuando se detecta un cambio de estado en este pin.


## 🧭 Driver A4988

Para controlar el motor paso a paso se utilizó el driver A4988, que requiere realizar una calibración inicial de la corriente máxima. Esta etapa se llevó a cabo montando el módulo en una protoboard, conectando un capacitor de 100 µF entre VMOT y GND para estabilizar la alimentación. Luego se aplicaron 12 V en VMOT y 5 V en VDD, con sus respectivas tierras.

Los cálculos para definir la corriente adecuada se realizaron considerando:

Corriente máxima del motor NEMA 17: 1,7 A

Resistencia interna del A4988: 0,1 Ω

Ecuación del fabricante: Vref = Imax × (8 × Rs)

Dado que el motor opera en pasos completos, es recomendable no superar el 70 % de la corriente nominal. El valor final obtenido fue aproximadamente 0,952 A, considerado ideal para el funcionamiento del sistema.Para ajustar esta corriente, se midió la Vref con un voltímetro apoyado sobre la punta del destornillador mientras se giraba el potenciómetro del A4988, hasta alcanzar el valor adecuado.

🔌 Conexión de Entradas y Salidas

Las entradas del driver A4988 provienen directamente de las salidas del PIC16F887. Los pines asignados fueron:

DIR → RB1
STEP → RB3
SLEEP → RB2

El pin SLEEP se conectó conjuntamente con RESET, tal como lo especifica la conexión recomendada para este driver.
Las salidas del A4988 corresponden a 1A, 1B, 2A y 2B, destinadas a alimentar las dos bobinas del motor paso a paso. La identificación de cada bobina se realizó consultando el datasheet del motor, asegurando que cada cable fuera conectado a la terminal correcta.
Finalmente, los pines MS1, MS2 y MS3 se conectaron a tierra, ya que el proyecto utiliza el modo de pasos completos, cuya configuración requiere fijar estos tres pines en nivel bajo.

---

## 🔧 Hardware Necesario
- PIC16F887  (debe tener un bootloader cargado ya en el PIC, puede ser cargado a tráves de un PICkit)
- Driver A4988
- Resistencias (10kΩ)
- Capacitores (100uF, 22pf)
- Cristal de cuarzo de 4MHz
- Pulsadores o Botones
- Protoboard (recomendación)
- Placa Perforada
- LEDs  
- Fuente 5V
- Fuente 12V  
- Conexión UART USB-TTL a PC
- Motor paso a paso NEMA 17
- Potenciometro B10k
- Borneras
---

## 🛠️ Cómo Compilar y Programar

### 1️⃣ Instalar herramientas  

**Softwares usados:**  

- MPLAB X IDE: `v5.35`  
- MPASM Assembler: `v5.87`
- LabVIEW: `v2025 Q3 (64-bit) `
- Proteus: `v8.11`
- AN1310: `v1.05`

---

### 4️⃣ ¿Cómo cargar el programa .hex al PIC?

- Conectar el puerto serie del PC al PIC (USB-TTL)
- Abrir el AN1310
- Configurar el COM correcto y Bootloader Baud Rate (19200 bps recomendados)
- Forzar entrada a modo bootloader en el PIC
  Pulsá el botón Break/Reset Application Firmware y luego el botón Bootloader Mode
- Abrir el archivo .hex y escribirlo
  Open → seleccioná tu archivo.hex. y uego pulsá el botón de programar/escribir (ícono flecha roja hacia abajo)
- Pulsa Run Mode (botón verde) y listo

---

## ⚙️ Configuración del Sistema

### ✔ Configuración UART

- **Baud Rate:** 9600 bps  
- BRGH = 1  
- SPBRG = 25 (a 4 MHz, ~9615 bps)
- RX habilitado permanentemente  
- Cada byte recibido actualiza el duty manual

---

## 🖥️ Interfaz LabVIEW

El panel mostrado en el repositorio permite:

- Configurar el VISA resource name (puerto COM ) -> **Paso que debo realizar obligatoriamente**
- Enviar un valor PWM manual por medio de una perilla
- Enviar un 1,2,3,4 en ASCI para generar las interrupciones por uart
---

## 📝 Notas Útiles para Quien Quiera Usar el Proyecto

Para implementar la comunicación UART y verificar su correcto funcionamiento antes de utilizar el programa en LabView, se empleó la herramienta Hercules, la cual permitió realizar pruebas de transmisión y recepción de datos de manera rápida y sencilla.

Como observación adicional, durante el desarrollo se intentó configurar interrupciones por cambio en el puerto, utilizando los pines RB4 a RB7. Sin embargo, aun configurando los registros correctamente, no fue posible lograr que ambas interrupciones se activaran como se esperaba, lo que generaba errores en la ejecución. Debido a esta limitación, se decidió finalmente utilizar solo una interrupción por cambio en el puerto (RB7) y complementar el control con una interrupción externa en RB0, la cual funcionó de manera confiable dentro del sistema.

---

## 👥 Integrantes

- **Nicolas Borsotti Bosco**  
- **Santiago Ciacci**

---

## 📚 Documentación Recomendada

- Datasheet PIC16F887
- Datasheet de componentes

---

**Fin del README.**
