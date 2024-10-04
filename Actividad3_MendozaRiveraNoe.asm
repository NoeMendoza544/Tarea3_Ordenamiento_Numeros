;Actividad 3
;Escriba un programa enlenguaje ensamblador para el microprocesadorZ80 que haga lo siguiente
;1.Muestre un texto para iniciar la generación de números.
;2.Generar20 números enteros pseudo aleatorios(aquí un algoritmo), de tamaño máximo 1 byte
;y depositarlos en un área de memoria
;3.Mostrar en la pantalla los números(en decimal) generados.
;4.Mostrar un texto para preguntar cómo se desea ordenar los números¿ascendente o descendente?
;5.Ordenar los números(de acuerdo con la selección anterior) y dejarlos en otra área de memoria.
;6.Mostrar en la pantalla los números(en decimal) ordenados(de acuerdo con la elecciónen el punto anterior).
;7.Mostrar un texto para preguntar si se desea terminar o repetir el programa.
;8.Si elige continuar, regresar al punto 1, de lo contrario, enviar un texto para informar
;que ha salido del programa

;----------------------------------
;programa principal
;----------------------------------

.org 0000h            ; Dirección de inicio del programa
    ld sp,27ffh           ; Inicializa el stack pointer

inicio:
    ld A,89h              ; Carga 89h en el acumulador
    out (cw),A            ; Envía el valor al puerto de control cw
    ld hl,txtin           ; Carga la dirección del texto "Generar numeros $" en HL
    call most_txt          ; Llama a la subrutina para mostrar el texto en la pantalla LCD
    ld HL,27ffh           ; Carga la dirección 27ffh (inicio de memoria) en HL
    ld B,20               ; Carga 20 en el registro B, para generar 20 números aleatorios
    call nums_randoms         ; Llama a la subrutina para generar números aleatorios
    ld HL,27ffh           ; Carga la dirección 27ffh (inicio de memoria) en HL
    ld B,20               ; Carga 20 en el registro B, para mostrar los 20 números generados
    call mostrar_num      ; Llama a la subrutina para mostrar los números generados
    ld hl,ord_txt         ; Carga la dirección del texto "ORDENAR ASCENDENTE O DESCENDENTE?" en HL
    call most_txt          ; Llama a la subrutina para mostrar el texto en la pantalla LCD
    in A,(teclado)        ; Espera la entrada del usuario desde el teclado
    cp 'A'                ; Compara la entrada con 'A' (para ordenar ascendentemente)
    jp Z,orden_asc        ; Si es 'A', salta a la rutina de orden ascendente
    cp 'D'                ; Compara la entrada con 'D' (para ordenar descendentemente)
    jp Z,orden_desc       ; Si es 'D', salta a la rutina de orden descendente
    call num_orden        ; Llama a la subrutina para mostrar los números ya ordenados
    call ask         ; Llama a la subrutina para preguntar si repetir o salir
    halt                  ; Detiene el programa

;---------
; Subrutinas
;---------

; Subrutina para mostrar texto en pantalla LCD
most_txt:
    ld A,(HL)             ; Carga el carácter de la dirección HL en el acumulador
    cp '$'                ; Compara el carácter con el terminador '$'
    jp z,fin_mstxt        ; Si es '$', termina la rutina
    out (lcd),A           ; Muestra el carácter en el LCD
    inc HL                ; Incrementa HL para el siguiente carácter
    jp most_txt            ; Repite el ciclo hasta encontrar el '$'
fin_mstxt:
    ret                   ; Retorna al programa principal

; Subrutina para generar números aleatorios
nums_randoms:
    ld A,r                ; Carga el registro R (contador de refresco) en A, que es pseudoaleatorio
    ld (HL),A             ; Almacena el valor en la memoria apuntada por HL
    inc HL                ; Incrementa HL para el siguiente valor
    djnz nums_randoms          ; Decrementa B y repite hasta generar 20 números
    ret                   ; Retorna al programa principal

; Subrutina para mostrar números generados en pantalla
mostrar_num:
    ld A,(HL)             ; Carga el número almacenado en HL en A
    call decimal     	  ; Llama a la subrutina para convertir y mostrar el número en formato decimal
    inc HL                ; Incrementa HL para el siguiente número
    djnz mostrar_num      ; Decrementa B y repite hasta mostrar 20 números
    ret                   ; Retorna al programa principal

; Subrutina para convertir el número a formato decimal y mostrar en LCD
decimal:
    ld B,10               ; Carga 10 en B (para dividir entre 10)
    ld D,0                ; Inicializa el registro D a 0 (contará las decenas)
decenas:
    cp B                  ; Compara A con 10
    jp mostrar_unidades   ; Si es menor que 10, salta a mostrar las unidades
    sub B                 ; Resta 10 a A (para contar una decena)
    inc D                 ; Incrementa el contador de decenas
    jp decenas            ; Repite hasta que A sea menor que 10
mostrar_decenas:
    ld A,D; Carga el número de decenas en A
    add A,'0'             ; Convierte el valor a su carácter ASCII
    out (lcd),A           ; Muestra la decena en el LCD
mostrar_unidades:
    ld A,(HL)             ; Carga el valor original en A
    and 0fh               ; Asegura que solo se trate la parte baja del byte (unidades)
    ld B,10               ; Carga 10 en B para el cálculo de unidades
    ld D,0                ; Inicializa el registro D para contar las unidades
unidades:
    cp B                  ; Compara A con 10
    jp fin_conv           ; Si es menor que 10, finaliza la conversión
    sub B                 ; Resta 10 para reducir el valor
    inc D                 ; Incrementa el contador de unidades
    jp unidades           ; Repite hasta que A sea menor que 10
fin_conv:
    ld A,D                ; Carga el valor de las unidades en A
    add A,'0'             ; Convierte el valor a su carácter ASCII
    out (lcd),A           ; Muestra la unidad en el LCD
    ret                   ; Retorna al programa principal

; Subrutina para ordenar los números en forma ascendente
orden_asc:
    ld HL,27ffh           ; Carga la dirección de inicio de los números en HL
    ld B,20               ; Carga 20 en B (número de valores)
ascendente_loop:
    ld D,B                ; Carga B en D
    dec D                 ; Decrementa D para controlar el bucle interno
    ld HL,27ffh           ; Reinicia HL al inicio de los números
ascendente_inr_loop:
    ld A,(HL)             ; Carga el valor actual en A
    ld C,(HL+1)           ; Carga el siguiente valor en C
    cp C                  ; Compara A con C
    jr C,nsw_ascendente   ; Si ya están en orden, no intercambia
    ld (HL),c             ; Intercambia los valores si no están en orden
    ld (HL+1),A           ; Intercambia el valor actual
nsw_ascendente:
    inc HL                ; Avanza al siguiente número
    inc HL                ; Incrementa de nuevo para comparar el siguiente par
    djnz ascendente_inr_loop ; Repite el bucle hasta que todos estén en orden
    djnz ascendente_loop  ; Repite el proceso hasta completar las 20 iteraciones
    ret                   ; Retorna al programa principal

; Subrutina para ordenar los números en forma descendente (similar a la anterior)
orden_desc:
    ld HL,27ffh           ; Carga la dirección de inicio de los números en HL
    ld B,20               ; Carga 20 en B
descendente_loop:
    ld D,B                ; Carga B en D
    dec D                 ; Decrementa D para controlar el bucle interno
    ld HL,27ffh           ; Reinicia HL al inicio de los números
descendente_inr_loop:
    ld A,(HL)             ; Carga el valor actual en A
    ld c,(HL+1)           ; Carga el siguiente valor en C
    cp c                  ; Compara A con C
    jr nc,nsw_descendente ; Si ya están en orden, no intercambia
    ld (HL),c             ; Intercambia los valores si no están en orden
    ld (HL+1),A           ; Intercambia el valor actual
nsw_descendente:
    inc HL                ; Avanza al siguiente número
    inc HL                ; Incrementa de nuevo para comparar el siguiente par
    djnz descendente_inr_loop ; Repite el bucle hasta que todos estén en orden
    djnz descendente_loop ; Repite el proceso hasta completar las 20 iteraciones
    ret                   ; Retorna al programa principal

; Subrutina para mostrar los números ordenados
num_orden:
    ld HL,27ffh           ; Carga la dirección de inicio de los números
    ld B,20               ; Carga 20 en B
loop_mstr_ord:
    ld A,(HL)             ; Carga el número actual en A
    call decimal     ; Llama a la subrutina para convertir y mostrar en decimal
    inc HL                ; Incrementa HL al siguiente número
    djnz loop_mstr_ord    ; Repite hasta mostrar todos los números
    ret                   ; Retorna al programa principal

; Subrutina para preguntar si repetir o salir del programa
ask:
    ld HL,preg_txt        ; Carga la dirección del texto "Repetir programa (Y) o Salir (N)?$" en HL
    call most_txt          ; Muestra el texto en el LCD
    in A,(teclado)        ; Lee la entrada del usuario desde el teclado
    cp 'Y'                ; Compara el carácter ingresado con 'Y' (Repetir)
    jp z,inicio           ; Si es 'R', salta al inicio del programa para repetir
    cp 'N'                ; Compara el carácter ingresado con 'N' (Salir)
    jp z,fin_programa     ; Si es 'S', salta a la rutina para finalizar el programa

; Subrutina para finalizar el programa
fin_programa:
    ld hl,txt_salida      ; Carga la dirección del texto "SE HA TERMINADO EL PROGRAMA.$" en HL
    call most_txt          ; Muestra el texto en el LCD
    halt                  ; Detiene la ejecución del programa

;-------
; Datos
;-------

    .org 2000h            ; Define el origen de los datos en la dirección 2000h
    txtin .db "Generar numeros randoms:$"                           ; Texto inicial para generar números
    ord_txt .db "Como desea Ordenarlos Ascendente o Descendente?$"          ; Texto para solicitar ordenamiento
    preg_txt .db "Repetir programa (Y) o Salir (N)?$"         ; Texto para preguntar al usuario
    txt_salida .db "Fin del Programa.$"           ; Texto de salida al finalizar
    lcd    .equ 01h                                           ; Define el puerto del LCD como 01h
    teclado .equ 02h                                           ; Define el puerto del teclado como 02h
    cw     .equ 03h                                           ; Define el puerto de control como 03h

        .end
