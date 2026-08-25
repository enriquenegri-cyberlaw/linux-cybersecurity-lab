#!/bin/bash
saludar() {
echo "Hola, $1"
}

if 	[ "$#" -ne 2 ]; then

echo "Uso: $0 nombre edad"

exit 1

fi


nombre="$1"
edad="$2"

saludar "$nombre"

if (( edad > 18 )); then

echo "Tenes mas de 18"

elif (( edad == 18 )); then

echo "Tenes exactamente 18"

else

echo "Tenes menos de 18"

fi


echo "Contando del 1 al 3:"

numero=1

while (( numero <= 3 )); do

echo "$numero"

numero=$(( numero + 1 ))

done


echo "Archivos TXT del laboratorio:"

for archivo in ejercicios/*.txt; do

wc -l "$archivo"

done

exit 0
