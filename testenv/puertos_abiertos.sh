#!/usr/bin/env bash

# Luis Gerardo Hernandez Vazquez

function usage() {
  echo "Uso: puertos_abiertos.sh <host>"
  echo "Ejemplo: puertos_abiertos.sh 152.242.1.15"
  echo "Parámetros:"
  echo "  host: hostname o ip del servidor"
  exit 1
}

function open_ports() {
  local host="${1}"
  local ports
  ports=$(nmap -sT -p- "${host}")
  echo "${ports}" | grep -oP '[0-9]+(?=\/tcp)'
}

[ "${1}" ] || {
  usage
  exit 1
}

open_ports "${1}"
