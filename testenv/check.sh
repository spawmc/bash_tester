#!/bin/bash

# Script de comprobación de estado final
# Aqui se pueden agregar instrucciones para comprobar el estado final del ambiente de pruebas
# Para ello se tienen que crear funciones a partir del nombre de la llave del archivo JSON definido anteriormente
#   Ejemplo de funcion:
#   function ejemplo1() {
#     local output=$(cat ./testenv/test.txt)
#     if [ "$output" == "hola mundo" ]; then
#       echo "OK"
#     else
#       echo "FAIL"
#     fi
#   }
#
# En caso de no querer verificar nada en particular, solo se debe de crear una funcion del siguiente modo:
#   function main() {
#     echo "OK"
#   }
function complete() {
  echo " [+] OK"
}

function incomplete() {
  echo " [+] OK"
}

function nothing() {
  echo " [+] OK"
}

function invalid() {
  echo " [+] OK"
}
