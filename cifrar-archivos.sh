#!/usr/bin/env bash

# Luis Gerardo Hernandez Vazquez

#export password="password"
declare -x password="password"

function usage() {
  echo "Uso: cifrar-archivos.sh <path>"
  echo "Ejemplo: cifrar-archivos.sh /home/usuario/archivos/"
  echo "Cifra los archivos de un directorio recursivamente"
  echo "Parametros:"
  echo "  <path>  Ruta del directorio a cifrar"
  echo "Nota: La contraseña se pide al inicio del script"
}

function ask_password() {
  echo -n "Introduzca la contraseña para cifrar los archivos: "
  read -rs password
  export password
  echo
}

function encrypt_files() {
  local dir="${1}"
  for file in "${dir}"/*; do
    [[ -f "${file}" ]] && ccrypt -e -E password "${file}"
  done
}

function encrypt_recursive() {
  local dir="${1}"
  encrypt_files "${dir}"
  for file in "${dir}"/*; do
    [[ -d "${file}" ]] && encrypt_recursive "${file}"
  done
  exit 0
}

[ -d "${1}" ] || {
  usage
  exit 1
}

#ask_password
encrypt_recursive "${1}"
