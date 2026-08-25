#!/bin/bash
if [ "$#" -ne 1 ]; then
echo "Uso: $0 edad"
exit 1
fi
edad="$1"
if (( edad > 18 )); then
echo "Sos mayor de 18"
elif (( edad == 18 )); then
echo "Tenes 18 años"
else
echo "Sos menor de 18 años"
fi
