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

declare -x password="password"

function check_status() {
  local dir="${1}"
  for file in "${dir}"/*; do
    if [[ -f "${file}" && "$(grep -o data <<<"$(file "${file}")")" == "data" ]]; then
      if [ "$(ccrypt -c -E password "${file}")" ]; then
        echo " [+] $file Encrypted"
      else
        echo " [-] $file Not Encrypted"
      fi
    else
      [ -d "$file" ] && echo " [!] $file is a directory" || echo " [-] $file Not Encrypted"
    fi
  done
}

function carpeta() {
  local dir="/root/prueba"
  check_status "${dir}"
  for inner_dir in "${dir}"/*; do
    [ -d "${inner_dir}" ] && check_status "${inner_dir}"
  done
}

function archivo() {
  carpeta
}

function nothing() {
  carpeta
}
