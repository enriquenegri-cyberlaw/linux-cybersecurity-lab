# Copias, hard links, symlinks e inodes en Linux

## 1. Objetivo

El objetivo de esta práctica es distinguir, mediante evidencia observable, tres formas de relacionar nombres y datos en Linux:

- una **copia**, que constituye un archivo independiente;
- un **hard link**, que agrega otro nombre al mismo archivo;
- un **enlace simbólico** o **symlink**, que es un objeto separado que guarda una ruta hacia otro nombre.

La práctica se realizó manualmente en Debian dentro de `/tmp/practica-enlaces`. Para comprobar el comportamiento se crearon los tres casos, se compararon sus inodes, se modificaron por distintas rutas, se eliminó el nombre `original.txt` y, por último, se restauró ese nombre. Las conclusiones se basan en los comandos y resultados registrados, no solamente en definiciones teóricas.

## 2. Conceptos fundamentales

En un sistema de archivos Linux, el nombre que aparece en un directorio no contiene por sí mismo todos los datos del archivo. Simplificando, intervienen tres elementos:

1. una **entrada de directorio**, que asocia un nombre con un inode;
2. un **inode**, que identifica al objeto dentro de ese sistema de archivos y conserva metadatos y referencias a sus datos;
3. el **contenido** del archivo.

El número de inode sirve para comprobar si dos nombres del mismo sistema de archivos llegan al mismo objeto. No es un identificador universal: solo tiene sentido junto con el sistema de archivos en el que fue observado.

El contador de enlaces que muestra `ls -l` indica cuántas entradas de directorio apuntan a ese inode. Por eso aumentó a `2` al crear el hard link y volvió a `1` cuando se eliminó uno de los nombres.

Las tres alternativas se comportan de manera diferente:

- `cp` crea otro archivo con identidad y contenido lógicamente independientes. Aunque al principio los bytes sean iguales, una modificación posterior no se propaga al otro archivo.
- `ln` sin `-s` crea otro nombre para el mismo inode. No existe un nombre “más original” que el otro: ambos son entradas equivalentes hacia los mismos datos.
- `ln -s` crea un symlink con inode propio. Su contenido especial es una ruta que el sistema intenta resolver cada vez que se accede mediante ese enlace.

Un hard link debe permanecer dentro del mismo sistema de archivos porque el número de inode solo es significativo allí. Un symlink, en cambio, referencia una ruta y puede apuntar a otro sistema de archivos o a un directorio, aunque también puede quedar roto si esa ruta deja de existir.

## 3. Preparación del experimento

El archivo inicial se creó con:

```bash
printf 'contenido inicial\n' > original.txt
```

Cada parte del comando cumple una función concreta:

- `printf` escribe texto con un formato controlado;
- `\n` representa un salto de línea final;
- `>` redirige la salida hacia `original.txt` y crea el archivo si no existe; si ya existiera, reemplazaría su contenido.

El resultado fue un archivo regular cuyo contenido inicial era una única línea: `contenido inicial`. Ese archivo fue el punto de referencia para crear la copia y ambos tipos de enlace.

## 4. Copia de archivo

La copia se creó con:

```bash
cp original.txt copia.txt
```

En ese momento `copia.txt` comenzó con los mismos bytes que `original.txt`, pero `cp` creó otro archivo. La comprobación posterior con `ls -li` mostró inodes distintos: `original.txt` usaba el inode `10`, mientras que `copia.txt` usaba el inode `12`.

La igualdad inicial del contenido no implica una relación permanente. Desde la perspectiva de las operaciones sobre archivos, cada uno posee identidad y datos independientes; por eso fue posible modificar `copia.txt` sin alterar `original.txt`.

## 5. Hard link

El hard link se creó con:

```bash
ln original.txt hardlink.txt
```

Al no utilizar `-s`, `ln` agregó la entrada de directorio `hardlink.txt` asociada al mismo inode que `original.txt`. No duplicó el contenido ni inició un mecanismo de sincronización.

La evidencia mostró que ambos nombres usaban el inode `10` y que el contador de enlaces era `2`. Esto significa que existían dos nombres capaces de alcanzar exactamente el mismo objeto y los mismos datos.

## 6. Enlace simbólico o symlink

El enlace simbólico se creó con:

```bash
ln -s original.txt symlink.txt
```

La opción `-s` solicita un enlace simbólico. A diferencia del hard link, `symlink.txt` fue un objeto independiente, con inode `13`, que almacenó la referencia relativa `original.txt`.

Cuando un programa abre `symlink.txt`, el sistema resuelve esa ruta y, si existe, continúa la operación sobre el destino. El symlink no comparte inode con `original.txt` y tampoco incrementa el contador de hard links del destino.

## 7. Comparación mediante inodes

La inspección se realizó con:

```bash
ls -li
```

De la salida real se toman las columnas relevantes para la comparación:

| Inode | Tipo y permisos | Enlaces | Tamaño | Nombre |
|---:|---|---:|---:|---|
| `12` | `-rw-r--r--` | `1` | `18` | `copia.txt` |
| `10` | `-rw-r--r--` | `2` | `18` | `hardlink.txt` |
| `10` | `-rw-r--r--` | `2` | `18` | `original.txt` |
| `13` | `lrwxrwxrwx` | `1` | `12` | `symlink.txt -> original.txt` |

La primera columna permite obtener la conclusión principal:

- `original.txt` y `hardlink.txt` comparten el inode `10`;
- el contador `2` confirma que ese inode tiene dos nombres;
- `copia.txt` tiene el inode `12`, por lo que es otro archivo;
- `symlink.txt` tiene el inode `13`, también independiente;
- la `l` inicial de `lrwxrwxrwx` identifica un enlace simbólico;
- `symlink.txt -> original.txt` muestra la ruta almacenada como destino.

El siguiente diagrama resume las relaciones observadas:

```text
COPIA

original.txt ── inode 10 ── datos A
copia.txt    ── inode 12 ── datos A independientes

HARD LINK

original.txt ─┐
              ├── inode 10 ── mismos datos
hardlink.txt ─┘

SYMLINK

symlink.txt ── inode 13
    │
    └── "original.txt"
            │
            └── inode 10
                    │
                    └── datos
```

El diagrama no representa una sincronización entre dos archivos en el caso del hard link. Representa dos entradas de directorio que llegan directamente al mismo inode.

## 8. Modificación mediante hard link

Se agregó una línea mediante `hardlink.txt` y luego se leyó desde ambos nombres:

```bash
printf 'modificado desde hardlink\n' >> hardlink.txt
cat hardlink.txt
cat original.txt
```

Tanto `hardlink.txt` como `original.txt` mostraron:

```text
contenido inicial
modificado desde hardlink
```

El operador `>>` agrega la salida al final del archivo sin reemplazar lo que ya existía. El cambio apareció desde ambos nombres porque los dos llegan al inode `10` y, por lo tanto, a los mismos datos. Linux no copió ni sincronizó el cambio entre dos archivos distintos: la escritura se realizó una sola vez sobre el objeto compartido.

## 9. Modificación independiente de la copia

Después se modificó solamente la copia:

```bash
printf 'modificado solo en copia\n' >> copia.txt
cat copia.txt
cat original.txt
```

`copia.txt` mostró:

```text
contenido inicial
modificado solo en copia
```

Mientras tanto, `original.txt` conservó:

```text
contenido inicial
modificado desde hardlink
```

Esta diferencia comprobó que `copia.txt`, inode `12`, era independiente del inode `10`. La copia partió del mismo contenido, pero ninguna relación de enlace obligaba a que las escrituras posteriores afectaran al otro archivo.

## 10. Acceso y modificación mediante symlink

Primero se leyó mediante el symlink y se inspeccionó la ruta que almacenaba:

```bash
cat symlink.txt
readlink symlink.txt
```

La lectura mediante `symlink.txt` mostró el contenido vigente del destino:

```text
contenido inicial
modificado desde hardlink
```

Y `readlink symlink.txt` devolvió:

```text
original.txt
```

`readlink` muestra la referencia guardada dentro del enlace simbólico; no lee el contenido del archivo destino. El resultado `original.txt` comprobó que el symlink almacenaba esa ruta relativa.

Luego se escribió mediante el enlace:

```bash
printf 'modificado desde symlink\n' >> symlink.txt
cat symlink.txt
cat original.txt
cat hardlink.txt
cat copia.txt
```

`symlink.txt`, `original.txt` y `hardlink.txt` mostraron:

```text
contenido inicial
modificado desde hardlink
modificado desde symlink
```

En cambio, `copia.txt` conservó:

```text
contenido inicial
modificado solo en copia
```

La escritura no modificó los datos internos del symlink. El sistema resolvió `symlink.txt` hacia `original.txt` y escribió en el inode `10`, también accesible como `hardlink.txt`. La copia siguió sin cambios porque pertenecía al inode `12`.

## 11. Eliminación del nombre original

Se eliminó el nombre `original.txt` y se volvió a inspeccionar el directorio:

```bash
rm original.txt
ls -li
```

Los datos relevantes de la salida fueron:

| Inode | Tipo y permisos | Enlaces | Tamaño | Nombre |
|---:|---|---:|---:|---|
| `12` | `-rw-r--r--` | `1` | `43` | `copia.txt` |
| `10` | `-rw-r--r--` | `1` | `69` | `hardlink.txt` |
| `13` | `lrwxrwxrwx` | `1` | `12` | `symlink.txt -> original.txt` |

`rm original.txt` eliminó una entrada de directorio, no el inode `10`. Como `hardlink.txt` todavía apuntaba a ese inode, los datos continuaron existiendo y el contador de enlaces bajó de `2` a `1`.

La ausencia de `original.txt` afectó al symlink porque este conservaba literalmente esa ruta. No afectó a `copia.txt`, que seguía siendo otro archivo.

## 12. Comportamiento del hard link y del symlink tras la eliminación

Las comprobaciones se realizaron con:

```bash
cat copia.txt
cat hardlink.txt
cat symlink.txt
readlink symlink.txt
```

`copia.txt` continuó disponible con su contenido independiente:

```text
contenido inicial
modificado solo en copia
```

`hardlink.txt` también continuó disponible y conservó los datos del inode `10`:

```text
contenido inicial
modificado desde hardlink
modificado desde symlink
```

En cambio, el acceso a través del symlink falló:

```text
cat: symlink.txt: No existe el fichero o el directorio
```

El enlace simbólico no había sido borrado. Había quedado **roto** o **colgante** porque la ruta almacenada ya no resolvía a un destino existente. Esto se comprobó porque `readlink symlink.txt` todavía devolvió:

```text
original.txt
```

Por lo tanto:

- el hard link siguió funcionando porque el inode `10` aún tenía el nombre `hardlink.txt`;
- el contador de enlaces del inode bajó a `1`;
- la copia no se vio afectada porque pertenece al inode `12`;
- el symlink siguió existiendo como inode `13`, pero su ruta dejó de ser válida;
- `readlink` siguió mostrando `original.txt` porque un symlink no se actualiza automáticamente cuando desaparece su destino.

No sería correcto afirmar que el hard link “quedó como una copia”. Continuó siendo el mismo inode y los mismos datos que ya existían; simplemente quedó una sola entrada de directorio asociada a ese inode.

## 13. Restauración de original.txt

El nombre se restauró creando otro hard link desde el nombre que todavía funcionaba:

```bash
ln hardlink.txt original.txt
```

La inspección posterior con `ls -li` volvió a mostrar esta relación:

| Inode | Tipo y permisos | Enlaces | Tamaño | Nombre |
|---:|---|---:|---:|---|
| `12` | `-rw-r--r--` | `1` | `43` | `copia.txt` |
| `10` | `-rw-r--r--` | `2` | `69` | `hardlink.txt` |
| `10` | `-rw-r--r--` | `2` | `69` | `original.txt` |
| `13` | `lrwxrwxrwx` | `1` | `12` | `symlink.txt -> original.txt` |

`ln hardlink.txt original.txt` volvió a asociar el nombre `original.txt` con el inode `10`. El contador regresó de `1` a `2` y no se copiaron datos.

Las lecturas finales registradas fueron:

```text
copia.txt:
contenido inicial
modificado solo en copia

original.txt, hardlink.txt y symlink.txt:
contenido inicial
modificado desde hardlink
modificado desde symlink
```

El symlink volvió a funcionar automáticamente: continuaba guardando `original.txt` y esa ruta volvió a existir. En cambio, usar `cp hardlink.txt original.txt` habría creado un archivo independiente con otro inode; habría recuperado contenido, pero no la relación de hard link observada en la práctica.

## 14. Tabla comparativa

| Aspecto | Copia (`copia.txt`) | Hard link (`hardlink.txt`) | Symlink (`symlink.txt`) |
|---|---|---|---|
| Comando de creación | `cp original.txt copia.txt` | `ln original.txt hardlink.txt` | `ln -s original.txt symlink.txt` |
| ¿Mismo inode que `original.txt`? | No. En la práctica: `12` frente a `10`. | Sí. Ambos nombres usaron el inode `10`. | No. El symlink usó el inode `13`. |
| ¿Datos independientes? | Sí, desde el punto de vista de las operaciones sobre archivos. | No. Ambos nombres acceden a los mismos datos. | El symlink es independiente, pero no contiene los datos del destino: contiene una ruta. |
| ¿Referencia mediante ruta? | No mantiene una referencia al original. | No. La entrada apunta directamente al mismo inode. | Sí. Almacenó la ruta relativa `original.txt`. |
| Efecto de modificarlo | Solo cambia la copia. | El cambio se observa desde todos los nombres del mismo inode. | Si la ruta resuelve, la escritura modifica el archivo destino. |
| Al desaparecer `original.txt` | Sigue funcionando sin cambios. | Sigue funcionando mientras exista `hardlink.txt`; el contador baja. | El symlink existe, pero queda roto hasta que la ruta vuelva a existir. |

Los números `10`, `12` y `13` son evidencia de esta ejecución concreta. En otra ejecución pueden cambiar; lo importante es comparar igualdad o diferencia dentro del mismo sistema de archivos.

## 15. Conclusiones

Una copia crea un archivo independiente; un hard link crea otro nombre para el mismo inode; un symlink crea un objeto independiente que referencia una ruta. La práctica permitió justificar esa frase con comportamiento observable.

La copia comenzó con el mismo contenido que `original.txt`, pero recibió el inode `12`. Al modificarla, únicamente cambió `copia.txt`. Esto demuestra que la igualdad inicial de bytes no implica identidad ni una relación futura entre ambos archivos.

El hard link compartió el inode `10` con `original.txt`. Por eso escribir desde cualquiera de los dos nombres produjo una única modificación visible desde ambos. Cuando se borró `original.txt`, los datos no desaparecieron: `hardlink.txt` todavía mantenía una entrada hacia el inode y el contador bajó de `2` a `1`. Ninguno de esos nombres era una copia ni tenía prioridad sobre el otro.

El symlink tuvo su propio inode, el `13`, y guardó `original.txt`. Mientras esa ruta existió, leer o escribir mediante `symlink.txt` terminó operando sobre el destino. Cuando el nombre desapareció, el enlace siguió presente pero quedó colgante; `readlink` aún pudo mostrar la ruta, aunque `cat` ya no pudo resolverla.

La restauración terminó de demostrar la diferencia: al recrear `original.txt` con `ln hardlink.txt original.txt`, se recuperó un segundo nombre para el inode `10`, el contador volvió a `2` y el symlink recuperó su destino sin ser modificado. Una copia con `cp` no habría restablecido esa identidad.

En términos prácticos, la elección depende de la relación deseada: una copia sirve cuando los cambios deben separarse; un hard link, cuando varios nombres deben representar el mismo archivo dentro de un sistema de archivos; y un symlink, cuando se necesita una referencia flexible mediante ruta y se acepta que pueda quedar rota si el destino cambia o desaparece.
