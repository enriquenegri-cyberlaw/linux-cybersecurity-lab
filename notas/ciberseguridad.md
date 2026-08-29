# Fundamentos de ciberseguridad

Este laboratorio se utiliza únicamente sobre archivos, sistemas y entornos propios, sintéticos o expresamente autorizados.

## Principios de trabajo

- Distinguir entre hechos observados, inferencias técnicas e hipótesis.
- No atribuir una acción, autoría o intención sin evidencia suficiente.
- Verificar los resultados de los comandos antes de formular conclusiones.
- Mantener el alcance de las prácticas limitado a sistemas y datos propios o autorizados.
- Documentar qué se observó y cómo se comprobó.

## Prácticas relacionadas

### Permisos y metadatos

Las prácticas de Linux permiten observar permisos, propietarios, inodes y otros metadatos de archivos.

La práctica documentada en `ejercicios/copia-hardlink-symlink-inodes.md` compara copias, hard links y symlinks mediante evidencia observable.

### Análisis defensivo de logs

El directorio `logs/` contiene registros sintéticos utilizados para practicar identificación de accesos aceptados y fallidos, usuarios, direcciones IP, horarios y patrones repetidos.

Una conclusión debe limitarse a lo que el registro permite sostener. La presencia de un evento o una dirección IP constituye evidencia observable, pero no demuestra por sí sola identidad, autoría o intención.

### Integridad de archivos

El directorio `ejercicios/` contiene material de práctica relacionado con SHA-256 y verificación de integridad.

La revisión detallada de SHA-256, verificación de integridad y `stat` continúa pendiente dentro de la ruta de aprendizaje.
