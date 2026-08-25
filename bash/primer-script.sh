#!/bin/bash
if [ "$#" -ne 2 ]; then
 echo "Uso: $0 nombre edad"
 exit 1
fi
nombre="$1"
edad="$2"
 echo "Hola, $nombre"
if (( edad >= 18 )); then
 echo "Sos mayor de edad"
else
 echo "Sos menor de edad"
fi
