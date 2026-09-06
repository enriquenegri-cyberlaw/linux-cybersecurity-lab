# Permisos y usuarios en Linux

## Objetivo

Practicar y comprender el modelo básico de permisos de Linux, incluyendo:

- usuario actual, UID, GID y grupos;
- owner, group y others;
- permisos de lectura, escritura y ejecución;
- diferencias entre permisos de archivos y directorios;
- `chmod` en notación simbólica y numérica;
- `umask`;
- cambio de group con `chgrp`;
- cambio de owner con `chown`;
- evaluación de permisos efectivos según la relación del usuario con el archivo.

## Identidad del usuario

Se utilizó:

```bash
id
```

La sesión de práctica mostró al usuario `enrique` con UID y GID principales `1000`, además de pertenencia a varios grupos.

Se distinguieron tres conceptos:

- **usuario actual**: identidad que ejecuta la operación;
- **owner**: usuario asociado al archivo;
- **group**: grupo asociado al archivo.

El usuario actual y el owner pueden coincidir o ser diferentes.

## Owner, group y others

Los permisos tradicionales se dividen en tres categorías:

```text
owner | group | others
```

Por ejemplo:

```text
-rw-r--r--
```

significa:

- owner: lectura y escritura;
- group: sólo lectura;
- others: sólo lectura.

Los permisos de las distintas categorías no se suman.

Si el usuario coincide con el owner, se aplican los permisos del owner. Si no coincide, puede corresponder la categoría group. En caso contrario, se aplican los permisos de others.

## Permisos sobre archivos regulares

Para un archivo regular:

- `r` (`read`): permite leer su contenido;
- `w` (`write`): permite modificar su contenido;
- `x` (`execute`): permite ejecutarlo cuando corresponda.

Durante la práctica se comprobó que un archivo cuyo owner tenía únicamente `r--` podía ser leído pero no modificado.

## chmod en notación simbólica

`chmod` permite modificar permisos.

Se utilizaron tres operadores:

- `=`: establece exactamente los permisos indicados;
- `+`: agrega permisos;
- `-`: quita permisos.

Ejemplos:

```bash
chmod u=r archivo
chmod u+w archivo
chmod u-w archivo
```

`u` representa la categoría del owner en la sintaxis de `chmod`.

Se comprobó experimentalmente que:

```bash
chmod u+w archivo
```

agrega escritura sin eliminar permisos existentes, mientras que:

```bash
chmod u=rw archivo
```

establece exactamente lectura y escritura para el owner.

## chmod en notación numérica

Los permisos se representan mediante:

```text
r = 4
w = 2
x = 1
```

Las combinaciones se obtienen sumando esos valores:

```text
0 = ---
1 = --x
2 = -w-
3 = -wx
4 = r--
5 = r-x
6 = rw-
7 = rwx
```

Por ejemplo:

```bash
chmod 640 archivo
```

produce:

```text
owner  = rw-
group  = r--
others = ---
```

Durante la práctica se verificó que `chmod 640` produjo:

```text
-rw-r-----
```

## umask

La sesión tenía:

```text
0022
```

La `umask` elimina determinados permisos de los permisos solicitados durante la creación de nuevos objetos.

Con una `umask` de `0022`, es habitual obtener:

```text
archivo regular: 644 → -rw-r--r--
directorio:       755 → drwxr-xr-x
```

Los archivos regulares suelen crearse solicitando como máximo `0666`, mientras que los directorios suelen solicitar `0777`.

La `umask` restringe permisos; no agrega permisos que el programa creador no haya solicitado.

## Permisos sobre directorios

Los permisos tienen un significado diferente cuando se aplican a un directorio.

### Lectura (`r`)

Permite leer o enumerar los nombres de las entradas existentes dentro del directorio.

### Ejecución (`x`)

Permite atravesar el directorio y resolver nombres de entradas conocidas.

Se comprobó que con:

```text
d--x------
```

no era posible ejecutar:

```bash
ls directorio
```

pero sí acceder mediante:

```bash
cat directorio/nombre-conocido.txt
```

si el archivo permitía la lectura.

### Escritura (`w`)

Permite modificar las entradas del directorio cuando se combina con los permisos necesarios, especialmente `x`.

Con:

```text
d-wx------
```

se comprobó que era posible:

- crear una nueva entrada;
- renombrarla;
- eliminarla;

aunque no fuera posible enumerar el contenido del directorio.

## Entradas de directorio e inodes

Se distinguió entre:

- nombre de entrada;
- inode;
- objeto del filesystem;
- archivo regular.

Al copiar un archivo con `cp` se obtuvo un inode diferente.

Al renombrarlo con `mv`, el nombre de entrada cambió pero el inode permaneció igual.

Ejemplo observado:

```text
nombre-viejo.txt → inode 20438
nombre-nuevo.txt → inode 20438
```

Esto mostró que el nombre se encuentra asociado a una entrada del directorio y no constituye la identidad del objeto.

## Eliminación de archivos y permisos del directorio

Se creó un archivo y posteriormente se configuró como:

```text
-r--------
```

El archivo no tenía permiso de escritura.

Sin embargo, el directorio tenía:

```text
d-wx------
```

y fue posible eliminar la entrada mediante `rm`.

La prueba demostró que:

- `w` sobre un archivo controla la modificación de su contenido;
- `w` sobre un directorio controla la modificación de sus entradas.

La eliminación de una entrada no debe confundirse con la desaparición inmediata del inode en todos los casos. Si existen otros hard links o procesos que mantienen el archivo abierto, el objeto puede continuar existiendo.

## Cambio de group con chgrp

Se utilizó:

```bash
chgrp users ejercicios/permisos-demo.txt
```

El resultado cambió de:

```text
owner: enrique
group: enrique
```

a:

```text
owner: enrique
group: users
```

sin modificar los bits de permisos.

## Cambio de owner con chown

Después se utilizó:

```bash
sudo chown root ejercicios/permisos-demo.txt
```

El archivo quedó como:

```text
-rw-r----- root users
```

El usuario `enrique` dejó de coincidir con el owner, pero pertenecía al grupo `users`.

Por lo tanto, se le aplicaron los permisos del group:

```text
r--
```

Se comprobó que podía leer el archivo pero no modificarlo.

Esto demostró que los mismos bits de permisos pueden producir permisos efectivos diferentes cuando cambia la relación entre el usuario, el owner y el group.

## Conclusiones

La práctica permitió comprobar que:

1. owner, group y usuario actual son conceptos diferentes;
2. los permisos de owner, group y others no se suman;
3. `chmod` modifica los bits de permisos;
4. `chgrp` modifica el group asociado;
5. `chown` modifica el owner;
6. `r`, `w` y `x` tienen efectos diferentes en archivos y directorios;
7. modificar el contenido de un archivo y modificar una entrada de directorio son operaciones distintas;
8. los permisos efectivos dependen tanto de los bits `rwx` como de la relación entre la identidad del usuario, el owner y el group;
9. `umask` restringe los permisos solicitados al crear nuevos objetos;
10. la verificación práctica de cada cambio es necesaria para comprender su efecto real.
