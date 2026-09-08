# Logs y análisis defensivo

## Objetivo

Practicar lectura, filtrado, interpretación y correlación de logs en Debian WSL2 y Windows, diferenciando hechos observables de hipótesis.

## Concepto central

Un log es un registro generado por un componente del sistema.

Su contenido permite observar eventos, pero una sola línea no siempre alcanza para reconstruir lo ocurrido.

Método utilizado:

    log
    ↓
    hecho observable
    ↓
    hipótesis
    ↓
    búsqueda de evidencia adicional
    ↓
    correlación de fuentes
    ↓
    confirmación, refutación o mantenimiento de la hipótesis

## Lectura inicial del journal

Se consultaron las últimas entradas:

    journalctl -n 20 --no-pager

Elementos:

- `journalctl`: comando que consulta el journal.
- `-n`: opción.
- `20`: argumento de `-n`.
- `--no-pager`: opción que muestra directamente la salida.

Entre los eventos observados aparecieron mensajes relacionados con:

- sesiones PAM;
- systemd;
- journald;
- WSL;
- resolución de nombres;
- kernel.

Uno de los principios aplicados fue no interpretar automáticamente un mensaje llamativo como evidencia de actividad maliciosa.

## Hechos e hipótesis

Durante la práctica se utilizó esta distinción:

    HECHO
    lo que el registro muestra directamente

    HIPÓTESIS
    una posible explicación de ese hecho

    CONCLUSIÓN
    explicación que puede sostenerse después de buscar más evidencia

Ejemplo:

    WSL: CheckConnection: getaddrinfo() failed: -5

Este mensaje permite afirmar que falló una operación relacionada con resolución de nombres.

Por sí solo no permite afirmar que:

- un servidor DNS falló;
- hubo un ataque;
- se perdió completamente la conectividad.

## PAM

PAM significa:

    Pluggable Authentication Modules

PAM es una infraestructura utilizada por Linux para aplicar reglas relacionadas con autenticación, cuentas y sesiones.

Un mensaje como:

    pam_unix(...): session opened

no implica necesariamente que una persona haya iniciado sesión.

El significado depende del servicio y del contexto que esté utilizando PAM.

## Investigación de sesiones

Se amplió la ventana temporal:

    journalctl --since "2026-09-07 21:10:00" --until "2026-09-07 21:11:00" --no-pager

Se observaron dos sesiones asociadas al mismo usuario:

    New session c1 of user enrique.
    New session c2 of user enrique.

Inicialmente esto podía parecer compatible con dos inicios de sesión.

Se investigó con:

    loginctl list-sessions --no-pager

Resultado relevante:

    SESSION  UID  USER     LEADER  CLASS    TTY
    c1       1000 enrique  220     user     pts/1
    c2       1000 enrique  230     manager  -

Luego se examinaron individualmente:

    loginctl show-session c1
    loginctl show-session c2

## Sesión c1

Campos relevantes:

    Service=login
    Leader=220
    Type=tty
    Class=user
    TTY=pts/1

Estos datos se correlacionaron con el journal:

    login[220]: pam_unix(login:session): session opened for user enrique

El PID `220` coincide con `Leader=220`.

La evidencia muestra una sesión de usuario asociada a una terminal.

## Sesión c2

Campos relevantes:

    Service=systemd-user
    Leader=230
    Type=unspecified
    Class=manager

Se correlacionó con:

    (systemd)[230]: pam_unix(systemd-user:session): session opened

El PID `230` coincide con `Leader=230`.

La sesión `c2` corresponde al gestor systemd del usuario.

No constituye evidencia de un segundo login humano independiente.

## Correlación de campos

La interpretación de una sesión no debe basarse en un único campo.

Por ejemplo:

    Class=manager
    Service=systemd-user
    TTY=-

considerados en conjunto indican un contexto diferente al de:

    Class=user
    Service=login
    TTY=pts/1

La ausencia de TTY, por sí sola, tampoco demuestra que una sesión no sea humana.

## Filtrado de logs por servicio

Se consultaron únicamente registros correspondientes a cron:

    journalctl -u cron.service -n 10 --no-pager

Análisis sintáctico:

    journalctl      comando
    -u              opción
    cron.service    argumento de -u
    -n              opción
    10              argumento de -n
    --no-pager      opción

`cron.service` no es un comando.

Es el argumento que indica a `journalctl` qué unidad de systemd debe filtrar.

## Logs de cron

Se observaron secuencias como:

    CRON[499]: pam_unix(cron:session): session opened for user root
    CRON[501]: (root) CMD (...)
    CRON[499]: pam_unix(cron:session): session closed for user root

Los números entre corchetes son PID.

En este ejemplo:

    CRON[499]

indica un proceso de CRON con PID `499`.

La apertura de una sesión PAM para `root` no demuestra que una persona haya iniciado sesión como root.

En este contexto, cron está ejecutando automáticamente una tarea programada con identidad root.

## Tarea horaria

Se observó:

    cd / && run-parts --report /etc/cron.hourly

`cd /` cambia al directorio raíz.

El operador:

    &&

indica que el comando situado a la derecha se ejecutará solamente si el comando de la izquierda finaliza correctamente.

Por tanto:

    cd / && run-parts --report /etc/cron.hourly

puede interpretarse como:

1. cambiar al directorio `/`;
2. si eso funciona;
3. ejecutar las tareas correspondientes de `/etc/cron.hourly`.

## Detección de un hueco temporal

Se observaron ejecuciones horarias aproximadamente a:

    21:17
    22:17
    00:17
    01:17

No apareció una ejecución de cron a las `23:17`.

No se concluyó inmediatamente que cron hubiera fallado.

Primero se consultó únicamente cron:

    journalctl -u cron.service --since "2026-09-07 22:50:00" --until "2026-09-07 23:30:00" --no-pager

Resultado:

    -- No entries --

Luego se consultó el journal completo:

    journalctl --since "2026-09-07 22:50:00" --until "2026-09-07 23:30:00" --no-pager

Resultado:

    -- No entries --

Esto mostró que la ausencia de registros no afectaba solamente a cron.

La hipótesis de un problema exclusivo de cron perdió fuerza.

## Comprobación de reinicios

Se utilizó:

    journalctl --list-boots --no-pager

El boot actual había comenzado aproximadamente a:

    2026-09-07 21:10:16

y continuaba después de medianoche.

Por tanto, no hubo un nuevo boot entre las `22:00` y las `00:00` que explicara el hueco.

La hipótesis de un reinicio de Debian/WSL fue descartada.

## Cronología del hueco

Se amplió la ventana de observación:

    journalctl --since "2026-09-07 22:15:00" --until "2026-09-08 00:20:00" --no-pager

Se observaron, entre otros:

    22:38:32 WSL WARNING relacionado con zona horaria
    23:31:14 kernel: hv_utils: TimeSync IC version 4.0
    23:31:17 apt-daily.service iniciado

El hueco observable quedó aproximadamente entre:

    22:38:32
    23:31:14

No se asumió que el warning de zona horaria fuera la causa del hueco simplemente por haber ocurrido antes.

Correlación temporal no significa necesariamente causalidad.

## Investigación del warning de zona horaria

WSL informó que no encontraba:

    /usr/share/zoneinfo/America/Buenos_Aires

Se comprobó que el paquete `tzdata` estaba instalado.

La zona horaria configurada era:

    America/Argentina/Buenos_Aires

También se utilizó:

    dpkg -L tzdata | grep Buenos_Aires

Resultado:

    /usr/share/zoneinfo/America/Argentina/Buenos_Aires

Luego:

    readlink -f /etc/localtime

Resultado:

    /usr/share/zoneinfo/America/Argentina/Buenos_Aires

También se observó mediante `timedatectl` que:

- la zona horaria era `America/Argentina/Buenos_Aires`;
- la hora local tenía offset `-03`;
- el reloj figuraba sincronizado.

Conclusión:

`tzdata` estaba instalado y la zona horaria del sistema estaba configurada correctamente.

El warning de WSL no fue considerado causa demostrada del hueco.

## Búsqueda de eventos del kernel

Se utilizó:

    journalctl -k --since "2026-09-07 23:25:00" --until "2026-09-07 23:35:00" --no-pager

La opción `-k` filtra mensajes del kernel.

Se observaron:

    hv_utils: TimeSync IC version 4.0

y múltiples mensajes:

    WSL: CheckConnection: getaddrinfo() failed: -5

También apareció:

    mini_init: drop_caches: 1

Los errores repetidos de `getaddrinfo()` indicaban problemas relacionados con resolución de nombres o comprobación de conectividad.

No demostraban por sí solos la causa exacta.

## Búsqueda de suspensión o reanudación

Se utilizó:

    journalctl --since "2026-09-07 22:30:00" --until "2026-09-07 23:40:00" --no-pager | grep -Ei 'suspend|resume|sleep|freeze|hibernate|timesync'

Opciones de `grep`:

    -E    expresiones regulares extendidas
    -i    ignore case

El símbolo:

    |

dentro de la expresión regular funciona como OR:

    suspend OR resume OR sleep OR freeze OR hibernate OR timesync

Dentro de los logs de Debian únicamente apareció un evento relacionado con `TimeSync`.

No se encontró un mensaje explícito que confirmara una suspensión.

Esto no demostraba que la suspensión no hubiera ocurrido.

Solamente significaba que no se había encontrado evidencia explícita de ella en esa fuente.

## Cambio de fuente de evidencia

Como WSL2 depende de infraestructura de Windows y Hyper-V, se decidió consultar también los registros del host Windows.

Se utilizó PowerShell para consultar el log:

    System

y filtrar eventos relacionados con:

    Power
    Hyper-V

Esto permitió correlacionar los eventos del host Windows con los registros observados dentro de Debian.

## Evidencia de Windows

Entre los eventos se encontró:

    Microsoft-Windows-Power-Troubleshooter

con un mensaje indicando que:

    El sistema estaba en un estado de baja energía y se reanudó.

También aparecieron eventos de:

    Microsoft-Windows-Kernel-Power
    Microsoft-Windows-Hyper-V-VmSwitch

alrededor de las `23:31`.

Se observaron además eventos relacionados con:

    S3
    Resume
    cambios de energía
    actividad del switch virtual de Hyper-V

La reanudación registrada por Windows coincidió temporalmente con:

    23:31:14 kernel: hv_utils: TimeSync IC version 4.0

dentro de Debian.

## Correlación final

La secuencia observada fue aproximadamente:

    actividad normal
    ↓
    último registro alrededor de 22:38
    ↓
    hueco de logs
    ↓
    ausencia de la tarea cron de las 23:17
    ↓
    Windows registra reanudación desde estado de baja energía
    ↓
    reaparece actividad de Hyper-V
    ↓
    Debian registra TimeSync
    ↓
    WSL registra múltiples fallos de getaddrinfo()
    ↓
    continúa la actividad normal

## Conclusión

La ausencia de la ejecución de cron de las `23:17` no debía interpretarse automáticamente como un fallo de cron.

La investigación permitió:

    detectar el hueco
    ↓
    comprobar que afectaba al journal general
    ↓
    descartar un problema exclusivo de cron
    ↓
    descartar un nuevo boot
    ↓
    formular la hipótesis de suspensión o pausa
    ↓
    comprobar que Debian no contenía evidencia suficiente
    ↓
    cambiar de fuente
    ↓
    consultar los logs de Windows
    ↓
    encontrar evidencia de reanudación desde un estado de baja energía
    ↓
    correlacionarla temporalmente con la reaparición de actividad en WSL

La evidencia de Windows es consistente con el hueco observado dentro de Debian y con la ausencia de la ejecución de cron de las `23:17`.

## Aprendizajes principales

- Un log registra eventos, pero necesita interpretación.
- Una observación y una hipótesis no son lo mismo.
- Una hipótesis debe contrastarse con evidencia adicional.
- Un mensaje llamativo no equivale automáticamente a un incidente.
- PAM no interviene únicamente en logins humanos.
- Los PID permiten correlacionar procesos.
- Dos sesiones del mismo usuario pueden tener funciones diferentes.
- `Class=user` y `Class=manager` representan contextos diferentes.
- La ausencia de un evento también puede aportar información.
- La ausencia de evidencia no equivale a evidencia de ausencia.
- La correlación temporal no implica necesariamente causalidad.
- Los logs de diferentes sistemas pueden complementarse.
- En un entorno WSL puede ser necesario investigar tanto Linux como Windows.
- La fuente que contiene la evidencia decisiva puede ser distinta de aquella donde apareció inicialmente el síntoma.

## Método práctico de análisis

    observar
    ↓
    identificar hechos
    ↓
    formular hipótesis
    ↓
    buscar contexto
    ↓
    buscar otras fuentes
    ↓
    correlacionar
    ↓
    confirmar o refutar
    ↓
    documentar únicamente lo que permite sostener la evidencia
