# Módulo 1: comandos básicos de Linux

Este módulo enseña a orientarte en la terminal y a pedir ayuda cuando no conoces un comando. Ejecuta los ejemplos en tu propio equipo o en un entorno de práctica autorizado.

## `pwd`

1. **Qué hace:** muestra la ruta completa del directorio en el que estás trabajando. Su nombre significa *print working directory*.
2. **Ejemplo:**

   ```bash
   pwd
   ```

3. **Qué observar:** verás una ruta que empieza normalmente por `/`, por ejemplo `/home/enrique/laboratorio`.
4. **Ejercicio:** ejecuta `pwd` desde el directorio del laboratorio.
5. **Cómo comprobarlo:** la salida debe terminar en `laboratorio` si estás en la carpeta principal de este repositorio.

## `ls`

1. **Qué hace:** muestra los archivos y directorios visibles que hay en la ubicación actual.
2. **Ejemplo:**

   ```bash
   ls
   ```

3. **Qué observar:** aparecerán nombres como `linux`, `ejercicios` o `notas`. Los nombres que representan directorios suelen mostrarse con un color diferente, según la configuración de tu terminal.
4. **Ejercicio:** ejecuta `ls` en la carpeta principal del laboratorio e identifica un archivo y un directorio.
5. **Cómo comprobarlo:** debes poder señalar, por ejemplo, `notas.txt` como archivo y `linux` como directorio.

## `ls -la`

1. **Qué hace:** muestra una lista detallada de archivos y directorios, incluidos los ocultos. `-l` significa formato largo y `-a` significa todos.
2. **Ejemplo:**

   ```bash
   ls -la
   ```

3. **Qué observar:** cada línea incluye permisos, propietario, tamaño, fecha y nombre. También verás entradas que comienzan con punto, como `.git`.
4. **Ejercicio:** ejecuta `ls -la` en la carpeta principal del laboratorio y localiza `.git`.
5. **Cómo comprobarlo:** debe aparecer una línea cuyo nombre final sea `.git`. Es el directorio donde Git guarda el historial local del repositorio.

## `cd`

1. **Qué hace:** cambia de directorio. Debes indicar la carpeta a la que quieres entrar.
2. **Ejemplo:**

   ```bash
   cd linux
   ```

3. **Qué observar:** normalmente la terminal no muestra un mensaje. Usa `pwd` para confirmar que la ruta cambió.
4. **Ejercicio:** desde la carpeta principal del laboratorio, ejecuta `cd linux` y luego `pwd`.
5. **Cómo comprobarlo:** la ruta mostrada por `pwd` debe terminar en `/laboratorio/linux`.

## `cd ..`

1. **Qué hace:** sube un nivel, al directorio padre. Los dos puntos `..` representan el directorio que contiene al actual.
2. **Ejemplo:**

   ```bash
   cd ..
   ```

3. **Qué observar:** no suele haber salida inmediata; la ubicación se comprueba con `pwd`.
4. **Ejercicio:** entra en `linux` con `cd linux`, ejecuta `cd ..` y después `pwd`.
5. **Cómo comprobarlo:** después de volver, la ruta debe terminar en `/laboratorio` y no en `/laboratorio/linux`.

## `cd ~`

1. **Qué hace:** te lleva a tu directorio personal. El símbolo `~` representa tu carpeta de usuario.
2. **Ejemplo:**

   ```bash
   cd ~
   ```

3. **Qué observar:** no se imprime un mensaje. Al ejecutar `pwd`, normalmente verás una ruta como `/home/enrique`.
4. **Ejercicio:** ejecuta `cd ~` desde cualquier carpeta y luego ejecuta `pwd`.
5. **Cómo comprobarlo:** la salida debe ser tu directorio personal, normalmente una ruta bajo `/home/`.

## `clear`

1. **Qué hace:** limpia la pantalla visible de la terminal. No borra archivos ni elimina el historial de comandos de la sesión.
2. **Ejemplo:**

   ```bash
   clear
   ```

3. **Qué observar:** la pantalla se verá vacía, salvo por el nuevo indicador de comandos.
4. **Ejercicio:** escribe algunos comandos sencillos, ejecuta `clear` y vuelve a ejecutar `pwd`.
5. **Cómo comprobarlo:** verás una pantalla limpia y, después, la ruta mostrada por `pwd`. Tus archivos no cambian por usar `clear`.

## `man`

1. **Qué hace:** abre el manual de un comando. Es una fuente de ayuda incluida en muchos sistemas Linux.
2. **Ejemplo:**

   ```bash
   man ls
   ```

3. **Qué observar:** se abrirá una página de documentación con la descripción y las opciones de `ls`. Puedes desplazarte con las flechas o con la barra espaciadora; pulsa `q` para salir.
4. **Ejercicio:** abre `man ls` y busca la explicación de la opción `-a`.
5. **Cómo comprobarlo:** debes encontrar que `-a` permite mostrar también entradas ocultas, es decir, nombres que comienzan con un punto.

## `--help`

1. **Qué hace:** muchos comandos aceptan `--help` para mostrar una ayuda breve directamente en la terminal.
2. **Ejemplo:**

   ```bash
   ls --help
   ```

3. **Qué observar:** verás una descripción de uso y una lista de opciones disponibles para `ls`.
4. **Ejercicio:** ejecuta `ls --help` e identifica las opciones `-a` y `-l`.
5. **Cómo comprobarlo:** la ayuda debe indicar que `-a` muestra todas las entradas y que `-l` usa el formato largo.

> **Nota:** `--help` no funciona con todos los comandos. Por ejemplo, `cd` es parte de la shell; para consultar su ayuda puedes usar `help cd` en Bash.

## Ejercicio integrador

Partiendo de la carpeta principal del laboratorio, ejecuta esta secuencia de forma pausada y observa cada resultado:

```bash
pwd
ls
cd linux
pwd
ls -la
man ls
ls --help
cd ..
cd ~
pwd
clear
pwd
```

Al finalizar, deberías poder explicar dónde empezaste, qué había en el laboratorio, cómo entraste y saliste de `linux`, qué información adicional muestra `ls -la`, dónde encontraste ayuda sobre `ls` y cuál es la ruta de tu directorio personal.
