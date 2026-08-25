#!/bin/bash
for archivo in ejercicios/*.txt; do
echo "Archivo: $archivo"
wc -l "$archivo";
done
