# Procesos y servicios en Linux

## Objetivo

Practicar y comprender los conceptos básicos relacionados con procesos y servicios en Linux, incluyendo:

- programa y proceso;
- PID y PPID;
- procesos padre e hijo;
- búsqueda y visualización de procesos;
- foreground y background;
- jobs de Bash;
- señales;
- estados de procesos;
- daemons;
- servicios;
- systemd;
- unidades de systemd;
- diferencia entre active y enabled;
- logs de servicios;
- relación entre servicios y persistencia.

## Programa y proceso

Un programa es código almacenado en el sistema.

Un proceso es una instancia de un programa que se encuentra en ejecución.

Por ejemplo:

```text
/usr/bin/sleep
```

es un programa.

Cuando se ejecuta:

```bash
sleep 600
```

se crea un proceso con un PID propio.

El mismo programa puede generar varios procesos distintos.

## PID y PPID

Cada proceso tiene un PID, que identifica esa ejecución concreta.

El PPID identifica al proceso padre.

Durante la práctica se observó:

```text
bash
PID 1419
```

y un proceso ejecutado desde esa shell:

```text
ps
PID 2388
PPID 1419
```

Esto permitió comprobar que `ps` era un proceso hijo de Bash.

## ps

Se utilizó:

```bash
ps
```

para observar procesos asociados a la terminal actual.

Después:

```bash
ps -f
```

mostró información adicional, incluyendo:

- UID;
- PID;
- PPID;
- TTY;
- tiempo de CPU;
- comando.

También se utilizó:

```bash
ps -ef --forest
```

para observar las relaciones padre-hijo en forma de árbol.

La práctica mostró que varios procesos pueden ejecutar el mismo programa y seguir siendo procesos diferentes porque tienen PID distintos.

## pgrep

Se utilizó:

```bash
pgrep bash
```

para buscar procesos llamados `bash`.

El resultado fue:

```text
260
1419
```

Después:

```bash
pgrep -a bash
```

permitió mostrar el PID junto con el comando:

```text
260 -bash
1419 -bash
```

## Foreground y background

Un proceso ejecutado normalmente desde Bash puede quedar en foreground y ocupar la terminal hasta que termine.

El operador:

```text
&
```

permite iniciar un comando en background.

Ejemplo:

```bash
sleep 600 &
```

Bash mostró:

```text
[1] 2917
```

Se distinguieron dos identificadores:

```text
[1]  → número de job dentro de Bash
2917 → PID del proceso
```

El número de job pertenece a esa shell.

El PID identifica al proceso en el sistema mientras siga existiendo.

## jobs

Se utilizó:

```bash
jobs
```

para consultar trabajos administrados por la shell actual.

Por ejemplo:

```text
[1]+ Ejecutando sleep 300 &
```

Bash también puede informar cuando un job termina:

```text
[1]+ Terminado sleep 600
```

Estas notificaciones son generadas por Bash y no deben confundirse con la salida de comandos como `pgrep` o `ps`.

## Señales

Las señales permiten comunicar eventos u órdenes a procesos.

Se consultaron las señales disponibles con:

```bash
kill -l
```

Las principales estudiadas fueron:

```text
SIGINT  → interrupción
SIGTERM → solicitud de terminación
SIGKILL → terminación forzada
SIGSTOP → detener
SIGCONT → continuar
```

## SIGINT

`Ctrl+C` normalmente provoca que la terminal envíe `SIGINT` al proceso o grupo de procesos que se encuentra en foreground.

Se comprobó con:

```bash
sleep 999999
```

seguido de:

```text
Ctrl+C
```

El proceso terminó y Bash recuperó el control de la terminal.

SIGINT expresa una interrupción.

Un proceso puede decidir cómo manejarla cuando está permitido.

## SIGTERM

Al ejecutar:

```bash
kill PID
```

sin indicar otra señal, normalmente se envía `SIGTERM`.

SIGTERM solicita que el proceso termine.

Un proceso puede tener la oportunidad de realizar acciones ordenadas antes de salir, dependiendo de cómo esté programado.

## SIGKILL

SIGKILL fuerza la terminación del proceso.

Puede enviarse mediante:

```bash
kill -KILL PID
```

o:

```bash
kill -9 PID
```

El proceso no puede capturar ni ignorar SIGKILL.

Por este motivo no debe utilizarse como primera opción cuando SIGTERM es suficiente.

## SIGSTOP y SIGCONT

Se creó un proceso:

```bash
sleep 999999 &
```

con PID:

```text
4817
```

Después se ejecutó:

```bash
kill -STOP 4817
```

y se comprobó:

```text
PID    PPID STAT CMD
4817   1419 T    sleep 999999
```

El estado `T` mostró que el proceso estaba detenido.

Luego:

```bash
kill -CONT 4817
```

produjo:

```text
PID    PPID STAT CMD
4817   1419 S    sleep 999999
```

El PID no cambió porque seguía siendo el mismo proceso.

## Estados S y T

Durante la práctica se observaron:

```text
S → proceso en espera interrumpible
T → proceso detenido
```

Un proceso en estado `S` sigue existiendo y puede continuar cuando corresponda.

Un proceso en estado `T` sigue existiendo, pero se encuentra suspendido.

Cuando un proceso termina, deja de existir como proceso activo y su PID deja de identificarlo.

## Daemon

Un daemon es, en términos generales, un proceso diseñado para funcionar durante períodos prolongados y sin depender de una terminal interactiva.

No todo proceso sin TTY debe considerarse automáticamente un daemon o un servicio.

## Servicio

Un servicio es una unidad que un gestor como systemd puede administrar.

Un servicio no debe confundirse con el programa que ejecuta ni con los procesos que ese programa genera.

Ejemplo:

```text
cron.service        → servicio
/usr/sbin/cron      → programa
PID 196             → proceso cron en ejecución
```

## systemd

systemd es software de gestión del sistema.

Cuando su ejecutable principal está en ejecución existe como proceso.

Se comprobó:

```bash
readlink -f /sbin/init
```

Resultado:

```text
/usr/lib/systemd/systemd
```

El proceso principal de systemd normalmente utiliza PID 1.

systemd administra servicios y otros tipos de unidades.

## Unidades

Una unidad es algo que systemd sabe gestionar.

Existen diferentes tipos, por ejemplo:

```text
.service
.socket
.timer
.mount
.target
```

Un servicio es un tipo de unidad.

No toda unidad es un servicio.

## systemctl

`systemctl` permite consultar y administrar unidades de systemd.

Se utilizó:

```bash
systemctl status cron
```

La salida mostró:

```text
Loaded: loaded
Active: active (running)
Main PID: 196 (cron)
```

Se distinguieron:

```text
loaded  → systemd pudo cargar la definición
active  → systemd considera activa la unidad
running → el servicio tiene actividad de proceso en ejecución
```

`active` y `running` no son sinónimos.

Por ejemplo, existen servicios que pueden aparecer como:

```text
active (exited)
```

aunque el proceso que realizó la tarea ya haya terminado.

## Active y enabled

Se comprobaron:

```bash
systemctl is-active cron
systemctl is-enabled cron
```

Resultados:

```text
active
enabled
```

La diferencia es:

```text
active  → estado actual
enabled → configurado para arrancar automáticamente cuando corresponda
```

Un servicio puede estar:

```text
active + enabled
active + disabled
inactive + enabled
inactive + disabled
```

## Archivo cron.service

Se utilizó:

```bash
systemctl cat cron
```

y se observó:

```ini
ExecStart=/usr/sbin/cron -f $EXTRA_OPTS
```

`ExecStart=` indica qué programa o comando debe ejecutar systemd al iniciar el servicio.

En este caso:

```text
cron.service
↓
ExecStart
↓
/usr/sbin/cron -f
↓
proceso cron
```

## cron

`cron` se utiliza para ejecutar tareas programadas.

`cron.service` es el servicio mediante el cual systemd administra a cron.

Se observaron registros como:

```text
CRON: session opened for user root
CRON: CMD (cd / && run-parts --report /etc/cron.hourly)
CRON: session closed for user root
```

La secuencia observada fue:

```text
cron abre una sesión
↓
ejecuta una tarea programada
↓
termina la tarea
↓
cierra la sesión
```

## systemd-journald y journalctl

`systemd-journald.service` administra la recolección del journal y registros del sistema.

`journalctl` es una herramienta utilizada para consultar esos registros.

Por ejemplo:

```bash
journalctl -u cron
```

permite consultar eventos relacionados con la unidad `cron`.

En forma simplificada:

```text
cron ejecuta tareas
↓
quedan registros
↓
systemd-journald los administra
↓
journalctl permite consultarlos
```

## Servicio de práctica

Se creó un servicio personal en:

```text
~/.config/systemd/user/demo-sleep.service
```

con el contenido:

```ini
[Unit]
Description=Servicio de practica de systemd

[Service]
ExecStart=/usr/bin/sleep 999999

[Install]
WantedBy=default.target
```

Después se ejecutó:

```bash
systemctl --user daemon-reload
```

para que systemd volviera a leer las definiciones de unidades del usuario.

Inicialmente:

```text
inactive
disabled
```

## start

Se ejecutó:

```bash
systemctl --user start demo-sleep
```

Resultado:

```text
active (running)
disabled
```

Esto demostró que:

```text
start ≠ enable
```

`start` inicia el servicio ahora, pero no habilita automáticamente su arranque futuro.

El proceso principal fue:

```text
Main PID: 6477 (sleep)
```

## enable

Se ejecutó:

```bash
systemctl --user enable demo-sleep
```

systemd creó un enlace simbólico:

```text
default.target.wants/demo-sleep.service
→ demo-sleep.service
```

Después:

```bash
systemctl --user is-active demo-sleep
systemctl --user is-enabled demo-sleep
```

produjo:

```text
active
enabled
```

## stop

Se ejecutó:

```bash
systemctl --user stop demo-sleep
```

Resultado:

```text
inactive
enabled
```

Esto demostró que:

```text
stop ≠ disable
```

Detener un servicio ahora no elimina su configuración de arranque automático.

## disable

Finalmente:

```bash
systemctl --user disable demo-sleep
```

eliminó el enlace simbólico creado anteriormente.

El estado final fue:

```text
inactive
disabled
```

## Relación con ciberseguridad

Los servicios son importantes para seguridad porque pueden ejecutar procesos automáticamente.

Un mecanismo de servicio podría ser abusado para persistencia si alguien con permisos suficientes logra configurar un servicio para volver a ejecutar código después de un reinicio o de otro evento.

Sin embargo:

```text
servicio desconocido ≠ servicio malicioso
```

Antes de llegar a una conclusión se debe investigar, entre otras cosas:

- qué programa ejecuta;
- con qué usuario;
- qué configuración utiliza;
- cuándo apareció;
- quién lo creó o modificó;
- qué procesos genera;
- qué logs existen;
- qué comportamiento presenta.

## Conclusiones

La práctica permitió comprobar que:

1. programa y proceso son conceptos diferentes;
2. el PID identifica una ejecución concreta;
3. el PPID permite identificar al proceso padre;
4. un mismo programa puede generar varios procesos;
5. foreground y background no determinan qué señales puede recibir un proceso;
6. las señales pueden interrumpir, detener, continuar o terminar procesos;
7. un proceso detenido sigue existiendo;
8. daemon y servicio no son sinónimos;
9. un servicio es distinto del programa que ejecuta;
10. systemd administra servicios y otros tipos de unidades;
11. active y enabled representan cosas diferentes;
12. start y enable no son equivalentes;
13. stop y disable no son equivalentes;
14. ExecStart indica qué debe ejecutar systemd al iniciar un servicio;
15. systemd-journald administra registros y journalctl permite consultarlos;
16. la revisión de servicios y sus procesos puede aportar evidencia útil para análisis defensivo y persistencia.
