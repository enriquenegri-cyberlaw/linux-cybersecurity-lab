#!/bin/bash
nombre="$1"
numero="$2"
if [ "$#" -ne 2 ]; then
echo "Uso: $0 nombre numero"
exit 1
fi
echo "Hola, $nombre"
if (( numero > 5 )); then
echo "Es mayor que 5"
elif (( numero == 5 )); then
echo "Es exactamente  5"
else
echo "Es menor que 5"
fi
contador=1
while (( contador <= numero )); do
echo "$contador"
contador=$(( contador + 1 ))
done
for archivo in ejercicios/*.txt; do
echo "Archivo: $archivo"
done
exit 0
