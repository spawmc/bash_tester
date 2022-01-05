#!/usr/bin/env bash

# Luis Gerardo Hernandez Vazquez

function usage() {
  echo "Uso: matar_proceso_remoto.sh -p <pid> -u <user> -w <password> -t <host> -r [port]"
  echo "Ejemplo: matar_proceso_remoto.sh -p 12345 -u user -w [password] -t host -r 22"
  echo "Parametros:"
  echo "  -p <pid>    PID del proceso a matar"
  echo "  -u <user>   Usuario con el que se conecta al host remoto"
  echo "  -w <password> Password del usuario, si no se especifica se pedira al usuario"
  echo "  -t <host>   Host remoto"
  echo "  -r <port>   Puerto de conexion, si no se especifica se usa el por defecto 22"
}

optionP=""
optionU=""
optionW=""
optionT=""
optionR=""
paramP=""
paramU=""
paramW=""
paramT=""
paramR=""

while getopts ":p:u:w:t:r:" opt; do
  case $opt in
  p)
    optionP=1
    paramP=$OPTARG
    ;;
  u)
    optionU=1
    paramU=$OPTARG
    ;;
  w)
    optionW=1
    paramW=$OPTARG
    export paramW
    ;;
  t)
    optionT=1
    paramT=$OPTARG
    ;;
  r)
    optionR=1
    paramR=$OPTARG
    ;;
  \?)
    echo "Opción invalida: -${OPTARG}" >&2
    usage
    exit 1
    ;;
  :)
    echo "Opción -${OPTARG} requiere un argumento." >&2
    usage
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

if [[ ! "${optionW}" ]]; then
  echo -n "Ingrese la contraseña del usuario remoto"
  read -rs paramW
  export paramW
fi

if [[ ! "${optionR}" ]]; then
  paramR=22
fi

[[ "${paramP}" =~ ^[0-9]+$ ]] || {
  echo "Falta el parametro -p o el valor no es un numero"
  usage
  exit 1
}
[[ "${paramR}" =~ ^[0-9]+$ ]] || {
  echo "Falta el parametro -r o el valor no es un numero"
  usage
  exit 1
}

function kill_process() {
  local pid="${1}"
  local user="${2}"
  local password="${3}"
  local host="${4}"
  local port="${5}"
  expect -c "
    set timeout -1
    spawn ssh -p $port $user@$host kill -9 $pid
    expect {
      \"*yes/no*\" { send \"yes\r\"; exp_continue }
      \"*password*\" { send \"$password\r\" }
    }
    expect eof
  "
}

trap "echo 'Saliendo...'; exit 0" SIGINT SIGTERM
kill_process "${paramP}" "${paramU}" "${paramW}" "${paramT}" "${paramR}"
