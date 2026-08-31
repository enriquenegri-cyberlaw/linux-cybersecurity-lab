# SHA-256, integridad y metadatos en Linux

## 1. Objetivo

El objetivo de esta práctica es comprobar experimentalmente cómo puede utilizarse SHA-256 para verificar la integridad del contenido de un archivo y distinguir esa comprobación de la información aportada por los metadatos del sistema de archivos.

La práctica busca desarrollar una metodología de análisis basada en cuatro niveles:

1. observar hechos técnicos;
2. interpretar esos hechos;
3. formular inferencias razonables;
4. evitar conclusiones que la evidencia disponible no permite sostener.

También se analiza la diferencia entre:

- integridad del contenido;
- autenticidad;
- metadatos;
- confiabilidad de un hash de referencia;
- conclusiones técnicas y conclusiones probatorias.

---

## 2. Conceptos principales

### 2.1. Función hash

Una función hash recibe datos como entrada y produce un valor de longitud fija denominado *hash* o *digest*.

En esta práctica se utiliza SHA-256.

Un SHA-256 se representa habitualmente mediante 64 caracteres hexadecimales.

Ejemplo:

```text
d7056a69ae20a904ffb32595aef3b63b7a2a3246a0d5c865e4ad26a734ec3b28
```

El hash calculado sobre un archivo depende de los bytes de su contenido.

El nombre del archivo, su ruta o su inode no forman parte del contenido procesado por `sha256sum`.

---

### 2.2. Integridad

En este contexto, comprobar integridad significa verificar si el contenido actual de un archivo coincide con el contenido representado por un hash de referencia.

Una coincidencia permite sostener que ambos estados de contenido producen el mismo SHA-256.

Sin embargo, la utilidad probatoria de esa comprobación depende también de la confiabilidad y procedencia del hash utilizado como referencia.

---

### 2.3. Integridad y autenticidad no son equivalentes

La coincidencia de un hash no determina por sí sola:

- quién creó el archivo;
- quién lo modificó;
- cuándo fue creado originalmente;
- con qué dispositivo fue creado;
- con qué aplicación fue generado;
- si su contenido es verdadero;
- si su procedencia declarada es auténtica;
- si fue obtenido legítimamente;
- si el hash de referencia fue generado en un momento confiable.

Por ello, integridad y autenticidad son conceptos relacionados, pero diferentes.

---

## 3. Archivo utilizado

Se trabajó con:

```text
ejercicios/integridad.txt
```

Su contenido era:

```text
archivo original
```

---

## 4. Cálculo del SHA-256

Se ejecutó:

```bash
sha256sum ejercicios/integridad.txt
```

Resultado observado:

```text
d7056a69ae20a904ffb32595aef3b63b7a2a3246a0d5c865e4ad26a734ec3b28  ejercicios/integridad.txt
```

El valor SHA-256 calculado fue:

```text
d7056a69ae20a904ffb32595aef3b63b7a2a3246a0d5c865e4ad26a734ec3b28
```

---

## 5. Hash de referencia

El repositorio ya contenía:

```text
ejercicios/integridad.sha256
```

Su contenido era:

```text
d7056a69ae20a904ffb32595aef3b63b7a2a3246a0d5c865e4ad26a734ec3b28  ejercicios/integridad.txt
```

Por lo tanto, el SHA-256 calculado durante la práctica coincidía con el valor previamente almacenado.

---

## 6. Verificación automática

Se utilizó:

```bash
sha256sum -c ejercicios/integridad.sha256
```

La opción:

```text
-c
```

significa *check*.

Hace que `sha256sum` lea los hashes almacenados en el archivo indicado y compruebe los archivos correspondientes.

Resultado:

```text
ejercicios/integridad.txt: La suma coincide
```

### Interpretación

El hecho directamente observado fue que el contenido actual de:

```text
ejercicios/integridad.txt
```

produjo el mismo SHA-256 que el registrado en:

```text
ejercicios/integridad.sha256
```

Puede afirmarse:

> El contenido actual del archivo coincide con el contenido representado por el hash SHA-256 utilizado como referencia.

No puede afirmarse únicamente a partir de esta comprobación:

> El archivo es auténtico, nunca fue modificado desde su creación o fue creado por determinada persona.

---

## 7. Alteración controlada del contenido

Para no modificar el archivo del repositorio se creó una copia temporal:

```bash
cp ejercicios/integridad.txt /tmp/integridad-prueba.txt
```

Se calculó el SHA-256 de la copia:

```bash
sha256sum /tmp/integridad-prueba.txt
```

Resultado:

```text
d7056a69ae20a904ffb32595aef3b63b7a2a3246a0d5c865e4ad26a734ec3b28  /tmp/integridad-prueba.txt
```

La copia producía exactamente el mismo SHA-256 que el archivo original.

### Interpretación

Aunque:

- el nombre era diferente;
- la ruta era diferente;
- se trataba de otro archivo;

su contenido tenía la misma secuencia de bytes.

Por ese motivo, ambos producían el mismo SHA-256.

---

## 8. Modificación de la copia

Se agregó una línea al archivo temporal:

```bash
echo "modificado" >> /tmp/integridad-prueba.txt
```

El operador:

```text
>>
```

redirige la salida agregándola al final del archivo sin eliminar el contenido existente.

Después de la operación:

```bash
cat /tmp/integridad-prueba.txt
```

mostró:

```text
archivo original
modificado
```

---

## 9. SHA-256 después de modificar el contenido

Se volvió a calcular el hash:

```bash
sha256sum /tmp/integridad-prueba.txt
```

Resultado:

```text
8d59241bbcdabd68ae0656cc012d712b13f32d1ad47efc81fc73a5b3e2ae4c23  /tmp/integridad-prueba.txt
```

Antes:

```text
d7056a69ae20a904ffb32595aef3b63b7a2a3246a0d5c865e4ad26a734ec3b28
```

Después:

```text
8d59241bbcdabd68ae0656cc012d712b13f32d1ad47efc81fc73a5b3e2ae4c23
```

Una modificación pequeña del contenido produjo un digest completamente diferente.

La observación ilustra una propiedad característica de las funciones hash criptográficas: pequeños cambios en la entrada pueden producir cambios extensos en la salida.

---

## 10. Comprobación del archivo original

Después de modificar únicamente la copia temporal se ejecutó:

```bash
sha256sum -c ejercicios/integridad.sha256
```

Resultado:

```text
ejercicios/integridad.txt: La suma coincide
```

El archivo original del repositorio permaneció sin modificaciones.

Esto permitió realizar la prueba de forma controlada sin alterar el material utilizado como referencia.

---

## 11. Limitación de un hash suministrado junto con el archivo

Supóngase el siguiente escenario:

Una persona entrega simultáneamente:

```text
evidencia.dat
evidencia.sha256
```

y la comprobación produce una coincidencia.

Eso no demuestra automáticamente que `evidencia.dat` nunca haya sido modificado.

La persona podría haber realizado esta secuencia:

```text
archivo original
      ↓
modificación
      ↓
archivo modificado
      ↓
cálculo de un nuevo SHA-256
      ↓
nuevo archivo .sha256
      ↓
entrega de ambos
```

En ese escenario:

```bash
sha256sum -c evidencia.sha256
```

podría informar correctamente que el hash coincide.

La comprobación matemática sería válida, pero no demostraría que el contenido entregado corresponde al estado original histórico del archivo.

### Consecuencia

También debe analizarse:

- quién generó el hash de referencia;
- cuándo se generó;
- cómo fue registrado;
- cómo fue almacenado;
- quién tuvo acceso a él;
- si existe una fuente independiente;
- si pudo ser sustituido junto con el archivo.

Por ello, la confiabilidad del hash de referencia es parte del análisis.

---

## 12. SHA-256 y metadatos

La siguiente parte de la práctica buscó comprobar si un archivo podía mantener exactamente el mismo contenido y SHA-256 mientras algunos de sus metadatos cambiaban.

Se creó una nueva copia:

```bash
cp ejercicios/integridad.txt /tmp/integridad-metadata.txt
```

Su SHA-256 fue:

```bash
sha256sum /tmp/integridad-metadata.txt
```

Resultado:

```text
d7056a69ae20a904ffb32595aef3b63b7a2a3246a0d5c865e4ad26a734ec3b28  /tmp/integridad-metadata.txt
```

---

## 13. Inspección mediante `stat`

Se ejecutó:

```bash
stat /tmp/integridad-metadata.txt
```

Resultado observado:

```text
Fichero: /tmp/integridad-metadata.txt
Tamaño: 17            Bloques: 8          Bloque E/S: 4096   regular file
Device: 0,71          Inode: 7           Links: 1
Acceso: (0644/-rw-r--r--)  Uid: (1000/enrique)   Gid: (1000/enrique)
Acceso:       2026-08-30 18:35:17.758501473 -0300
Modificación: 2026-08-30 18:35:05.504419271 -0300
Cambio:       2026-08-30 18:35:05.504419271 -0300
Creación:     2026-08-30 18:35:05.502466671 -0300
```

`stat` permitió observar información distinta del contenido del archivo, incluyendo:

- tamaño;
- inode;
- cantidad de enlaces;
- permisos;
- propietario;
- grupo;
- marcas temporales.

---

## 14. Marcas temporales

### 14.1. `atime`

`atime`, o *access time*, representa una marca temporal relacionada con el acceso al archivo.

Una lectura puede provocar su actualización dependiendo de la configuración y política utilizada por el sistema de archivos.

Por lo tanto, no debe asumirse que cada lectura actualiza siempre `atime` de la misma forma en todos los sistemas.

---

### 14.2. `mtime`

`mtime`, o *modification time*, registra el tiempo asociado a la última modificación del contenido registrada por el sistema de archivos.

No debe interpretarse automáticamente como:

> fecha en que el archivo fue creado.

Tampoco constituye por sí solo una reconstrucción completa de la historia del archivo.

---

### 14.3. `ctime`

`ctime` significa:

```text
change time
```

No significa:

```text
creation time
```

Representa el tiempo del último cambio registrado en determinados metadatos del inode.

Por ejemplo, cambios en permisos u otros atributos pueden provocar una actualización de `ctime`.

---

### 14.4. Tiempo de creación o `birth time`

Cuando el sistema de archivos lo soporta, puede existir una marca separada correspondiente a la creación del archivo.

En esta práctica `stat` mostró:

```text
Creación: 2026-08-30 18:35:05.502466671 -0300
```

La disponibilidad y el significado exacto de esta información dependen del sistema de archivos y del entorno utilizado.

---

## 15. Modificación de metadatos mediante `touch`

Se ejecutó:

```bash
touch /tmp/integridad-metadata.txt
```

En un archivo existente, `touch` puede actualizar determinadas marcas temporales sin modificar su contenido.

Después se ejecutó nuevamente:

```bash
stat /tmp/integridad-metadata.txt
```

Resultado:

```text
Fichero: /tmp/integridad-metadata.txt
Tamaño: 17            Bloques: 8          Bloque E/S: 4096   regular file
Device: 0,71          Inode: 7           Links: 1
Acceso: (0644/-rw-r--r--)  Uid: (1000/enrique)   Gid: (1000/enrique)
Acceso:       2026-08-30 18:36:15.278469944 -0300
Modificación: 2026-08-30 18:36:15.278469944 -0300
Cambio:       2026-08-30 18:36:15.278469944 -0300
Creación:     2026-08-30 18:35:05.502466671 -0300
```

Se observaron cambios en:

```text
Acceso
Modificación
Cambio
```

mientras que:

```text
Creación
```

permaneció igual.

El inode también permaneció igual:

```text
Inode: 7
```

y el tamaño siguió siendo:

```text
Tamaño: 17
```

---

## 16. Comprobación del SHA-256 después de `touch`

Después de modificar las marcas temporales se ejecutó:

```bash
sha256sum /tmp/integridad-metadata.txt
```

Resultado:

```text
d7056a69ae20a904ffb32595aef3b63b7a2a3246a0d5c865e4ad26a734ec3b28  /tmp/integridad-metadata.txt
```

El SHA-256 permaneció exactamente igual.

---

## 17. Resultado del experimento

Experimentalmente se observó:

```text
antes de touch
contenido → archivo original
SHA-256   → d7056a69...
mtime     → 18:35:05
ctime     → 18:35:05

después de touch
contenido → archivo original
SHA-256   → d7056a69...
mtime     → 18:36:15
ctime     → 18:36:15
```

Por lo tanto:

```text
mismo contenido
      ↓
mismo SHA-256

pero

metadatos diferentes
```

---

## 18. Conclusión sobre SHA-256 y metadatos

Dos archivos o dos estados de un archivo pueden producir exactamente el mismo SHA-256 y, al mismo tiempo, presentar diferencias en sus metadatos.

Una coincidencia SHA-256 no demuestra que coincidan:

- fechas;
- permisos;
- propietario;
- grupo;
- ruta;
- inode;
- otros atributos del sistema de archivos.

Del mismo modo, una modificación en los metadatos no implica necesariamente una modificación del contenido.

Hash y metadatos responden preguntas técnicas diferentes.

---

## 19. La observación puede afectar la evidencia

Durante la práctica se realizó:

```bash
sha256sum /tmp/integridad-metadata.txt
```

antes de consultar los metadatos.

Para calcular SHA-256, `sha256sum` tuvo que leer el contenido del archivo.

Se observó que la marca de acceso era posterior a otras marcas temporales:

```text
Acceso:       2026-08-30 18:35:17.758501473 -0300
Modificación: 2026-08-30 18:35:05.504419271 -0300
```

Esto es compatible con que la lectura haya influido en el tiempo de acceso dentro de las políticas utilizadas por ese sistema.

No debe generalizarse que toda lectura actualizará necesariamente `atime`, ya que ese comportamiento depende de la configuración del sistema de archivos.

### Consecuencia forense

Una herramienta utilizada para examinar evidencia puede producir efectos sobre ciertos metadatos.

Por ello, en un análisis forense debe considerarse:

- qué herramientas fueron utilizadas;
- qué operaciones realizaron;
- qué información pudieron modificar;
- qué controles se emplearon para reducir o documentar esos efectos.

---

## 20. Hash y timestamps no demuestran lo mismo

El hash responde principalmente a una pregunta:

> ¿El contenido actual produce el mismo SHA-256 que el contenido representado por el hash de referencia?

Los metadatos pueden responder otras preguntas relacionadas con el estado registrado por el sistema de archivos.

Por ejemplo:

```text
mtime
ctime
atime
inode
permisos
propietario
```

No debe utilizarse una de estas fuentes como si demostrara automáticamente lo mismo que las demás.

---

## 21. Un cambio de `mtime` no implica necesariamente un hash diferente

La propia práctica demostró:

```bash
touch /tmp/integridad-metadata.txt
```

Después de ejecutar `touch`:

- `mtime` cambió;
- `ctime` cambió;
- el SHA-256 permaneció igual.

Por lo tanto:

> Un cambio de `mtime` no demuestra por sí mismo que el contenido actual sea diferente.

También sería posible modificar un archivo y posteriormente restaurar exactamente sus bytes anteriores.

Conceptualmente:

```text
contenido A
    ↓
contenido B
    ↓
contenido A
```

El estado final puede volver a producir el mismo SHA-256 que el estado A inicial, aunque determinados metadatos hayan cambiado durante el proceso.

---

## 22. Hecho, inferencia, hipótesis y conclusión

Una metodología rigurosa debe separar claramente distintos niveles de afirmación.

### Hecho observado

Ejemplo:

```text
sha256sum -c informó "La suma coincide".
```

### Inferencia técnica

Ejemplo:

> El contenido actual del archivo produce el mismo SHA-256 que el contenido representado por el hash de referencia.

### Hipótesis

Ejemplo:

> El archivo podría no haber sido modificado desde que se generó el hash de referencia.

La hipótesis necesita evidencia adicional.

### Conclusión sustentada por la práctica

Ejemplo:

> Después de ejecutar `touch`, las marcas `atime`, `mtime` y `ctime` observadas
> cambiaron, mientras que el contenido, el tamaño, el inode y el SHA-256
> registrados permanecieron iguales.

Esta conclusión combina resultados directamente observados y explicita su
alcance. No atribuye una autoría, una intención ni una historia anterior que la
práctica no pueda demostrar.

### Conclusión no justificada únicamente por el hash

Ejemplo:

> El archivo es auténtico y fue creado por una determinada persona en una determinada fecha.

Esa afirmación requiere otras fuentes de evidencia.

---

## 23. Escenario de análisis forense

Supóngase que un perito recibe simultáneamente:

```text
documento
documento.sha256
```

y ambos provienen de la misma persona.

La comprobación:

```bash
sha256sum -c documento.sha256
```

produce una coincidencia.

El hecho observado permite verificar la coherencia entre el contenido actual y el hash entregado.

Pero si no existe:

- un registro anterior independiente;
- una cadena de custodia;
- una fuente confiable del hash;
- documentación sobre su generación;
- otro mecanismo de corroboración;

la coincidencia debe interpretarse de manera limitada.

El archivo pudo haber sido modificado y posteriormente haberse generado un nuevo hash correspondiente al estado modificado.

---

## 24. Importancia para evidencia digital

Un análisis de evidencia digital no debería reducirse a:

```text
hash coincide = evidencia auténtica
```

Una evaluación más rigurosa sería:

```text
archivo
   ↓
contenido
   ↓
SHA-256
   ↓
comparación con referencia
   ↓
procedencia de la referencia
   ↓
metadatos
   ↓
contexto de adquisición
   ↓
cadena de custodia
   ↓
otras fuentes de corroboración
   ↓
conclusión técnicamente sustentada
```

El hash constituye una herramienta importante, pero forma parte de un conjunto mayor de controles y evidencias.

---

## 25. Observación sobre `/tmp`

Durante la práctica inicial se había creado:

```text
/tmp/integridad-prueba.txt
```

Al retomar posteriormente el ejercicio, el archivo ya no se encontraba disponible:

```text
stat: cannot statx '/tmp/integridad-prueba.txt': No existe el fichero o el directorio
```

No puede atribuirse únicamente al reinicio de PowerShell sin evidencia adicional sobre lo ocurrido con WSL y el entorno.

Sin embargo, la observación recuerda una característica práctica importante:

> `/tmp` debe tratarse como un espacio destinado a datos temporales y no como un lugar adecuado para conservar evidencia o documentación que necesite persistencia.

En esta práctica se utilizó precisamente para crear copias descartables y evitar alterar los archivos versionados del laboratorio.

Las salidas de `stat` y `sha256sum` incluidas en este documento constituyen el
registro conservado de esa ejecución. Si un archivo temporal deja de existir,
sus valores de inode y marcas temporales ya no pueden volver a verificarse sobre
ese mismo objeto; por eso conviene guardar oportunamente la salida y describir
el procedimiento.

---

## 26. Resultados de aprendizaje

Después de esta práctica se comprobó que:

1. `sha256sum` calcula SHA-256 sobre el contenido de un archivo.
2. Dos archivos con los mismos bytes producen el mismo SHA-256.
3. Una modificación del contenido produce un digest diferente.
4. `sha256sum -c` permite comparar un archivo con un hash previamente almacenado.
5. Una coincidencia de hash no prueba por sí sola autenticidad, autoría o procedencia.
6. La confiabilidad del hash de referencia es relevante para su valor probatorio.
7. `stat` permite examinar metadatos diferentes del contenido.
8. `mtime` y `ctime` representan conceptos distintos.
9. `ctime` significa *change time*, no *creation time*.
10. Los metadatos pueden cambiar sin que cambien los bytes del archivo.
11. Si los bytes no cambian, el SHA-256 puede permanecer idéntico aunque cambien ciertos metadatos.
12. La propia herramienta de análisis puede afectar determinados metadatos.
13. Los timestamps deben interpretarse como datos registrados por el sistema, no como una reconstrucción infalible de los hechos.
14. Integridad, autenticidad y metadatos son conceptos relacionados, pero no equivalentes.
15. Un análisis técnico debe separar hechos observados, inferencias, hipótesis y conclusiones.

---

## 27. Conclusión

SHA-256 constituye una herramienta eficaz para comparar estados de contenido y detectar diferencias respecto de un hash de referencia.

Sin embargo, una coincidencia SHA-256 no establece automáticamente la autenticidad, la autoría, el origen ni la historia completa de un archivo.

El experimento con `touch` demostró además que los metadatos pueden cambiar sin que cambie el contenido y, por lo tanto, sin que cambie el SHA-256.

Esto permite establecer una distinción fundamental:

```text
integridad del contenido ≠ autenticidad

contenido ≠ metadatos

hash coincidente ≠ historia completa del archivo
```

En evidencia digital, ninguna observación debería interpretarse fuera de su contexto.

Una conclusión técnicamente rigurosa debe apoyarse en:

- el contenido examinado;
- los hashes;
- la procedencia y conservación de los hashes de referencia;
- los metadatos;
- las circunstancias de adquisición;
- las herramientas utilizadas;
- la documentación del procedimiento;
- la cadena de custodia cuando corresponda;
- otras fuentes independientes de corroboración.

El objetivo no es únicamente obtener un resultado con una herramienta, sino poder explicar qué demuestra ese resultado, qué permite inferir y cuáles son sus límites.
