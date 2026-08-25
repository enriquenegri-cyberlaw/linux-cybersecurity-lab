#!/bin/bash

limite="$1"

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 numero"
    exit 1
fi

if (( limite > 3 )); then
    echo "Numero es mayor que 3"
else
    echo "Numero menor o igual a 3"
fi

for archivo in ejercicios/*.txt; do
    echo "Archivo: $archivo"
done

contador=1

while (( contador <= limite )); do
    echo "$contador"
    contador=$(( contador + 1 ))
done
