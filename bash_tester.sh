#!/usr/bin/env bash

default_docker_dir="/root"
default_docker_name="bash-tester"
default_files_dir="./testenv"

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

_sucess_color() {
  echo -e "$COL_GREEN [+] $COL_RESET $1"
}

_error_color() {
  echo -e "$COL_RED [-] $COL_RESET $1"
}

_warning_color() {
  echo -e "$COL_YELLOW [w] $COL_RESET $1"
}

_info_color() {
  echo -e "$COL_BLUE [!] $COL_RESET $1"
}

function usage() {
  echo "Uso: bash-tester.sh [OPTIONS] -d [dir] script_name"
  echo "Parametros:"
  echo "           -h: Imprime este mensaje de ayuda"
  echo "           -d: Directorio donde se encuentran los scripts"
  echo "  script_name: Nombre del script a ejecutar"
  echo "           -n: Crear archivos para el ambiente de pruebas"
  echo "           -r: Eliminar archivos para el ambiente de pruebas"
  echo "           -j: Comprobar archivos para el ambiente de pruebas"
  echo "           -m: Crear funciones para el archivo check.sh a partir del archivo JSON"
  echo "    -b [NAME]: Crear respaldo del directorio de pruebas"
  echo "    -p script: Restaurar respaldo del directorio de pruebas, se debe de indicar el script principal ubicado en el directorio con los archivos a restaurar"
  echo "   -t timeout: Tiempo de espera para la ejecucion de un script (default: 5s)"
}

function make_env_files() {
  local dir="$1"
  mkdir -p "${default_files_dir}"
  # Script para crear un ambiente de prueba
  echo '#!/bin/bash
  
# Script de inicialización de ambiente de pruebas
# Aqui se pueden agregar instrucciones para inicializar el ambiente de pruebas
# Ejemplo:
#   dir="/home/user/testenv"
#   mkdir -p $dir
#   touch $dir/test.txt
#   echo "hola mundo" > $dir/test.txt
#   pacman -S git' >"${default_files_dir}/init.sh"

  # JSON para ingresar las entradas y salidas esperadas
  echo '{
  "ejemplo1": {
    "input": "--help",
    "output": "^Usage: bash-tester.sh",
    "return": 0
  },
  "ejemplo2": {
    "input": "--version",
    "output": "^bash-tester.sh 0.1.0",
    "return": 1
  },
  "main": {
    "input": "",
    "output": "Usage:",
    "return": 1
  }
}' >"${default_files_dir}/inputs.json"

  # Script de comprobación de estado final
  echo '#!/bin/bash
  
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
#   }' >"${default_files_dir}/check.sh"

  # Dockerfile para crear un ambiente de pruebas
  echo 'FROM archlinux
MAINTAINER spawnmc
RUN pacman -Sy git expect wget --noconfirm
RUN wget http://ccrypt.sourceforge.net/download/1.11/ccrypt-1.11.linux-x86_64.tar.gz
RUN tar -zxf ccrypt-1.11.linux-x86_64.tar.gz
RUN rm ccrypt-1.11.linux-x86_64.tar.gz
RUN mkdir -p /usr/local/ccrypt
RUN mv ccrypt-1.11.linux-x86_64 /usr/local/ccrypt/ccrypt
RUN ln -s /usr/local/ccrypt/ccrypt/ccrypt /usr/bin/ccrypt
RUN chmod +x /usr/bin/ccrypt
' >./Dockerfile

}

function check_files() {
  local dir="$1"
  if [ ! -f "${dir}/init.sh" ] || [ ! -f "${dir}/inputs.json" ] || [ ! -f "${dir}/check.sh" ]; then
    _warning_color "No se encontraron los archivos de inicialización, creandolos..." >&2
    touch "${dir}/init.sh"
    touch "${dir}/inputs.json"
    touch "${dir}/check.sh"
  fi

  _info_color "init.sh"

  if [ "$(
    shellcheck "${dir}"/init.sh &>/dev/null 2>&1
    echo $?
  )" -ne 0 ]; then
    _warning_color "init.sh Verifique su script"
    shellcheck "${dir}"/init.sh
  else
    _sucess_color "init.sh OK"
  fi

  _info_color "check.sh"

  if [ "$(
    shellcheck "${dir}"/check.sh &>/dev/null 2>&1
    echo $?
  )" -ne 0 ]; then
    _warning_color "check.sh Verifique su script"
    shellcheck "${dir}"/check.sh
  else
    _sucess_color "check.sh OK"
  fi

  _info_color "inputs.json"
  if ! jq '.' <"${dir}/inputs.json" &>/dev/null 2>&1; then
    _error_color "El archivo inputs.json no es un JSON válido" >&2
  else
    _sucess_color "JSON OK"
  fi

}

function dependency_check() {
  for dependency; do
    if ! command -v "${dependency}" >/dev/null 2>&1; then
      echo "${dependency} no está instalado, por favor instale ${dependency}" >&2
      exit 2
    fi
  done
  unset dependency
}

function make_backup() {
  local name="$1"
  mv -v "${default_files_dir}" "${name}"
  mv -v logs.txt "${name}"/log.txt
  mv -v resume "${name}"/resume
  mv -v all_logs.txt "${name}"/all_logs.txt
  mv -v Dockerfile "${name}"/Dockerfile
}

function _copy_to_docker() {
  local container_name="$1"
  local file="$2"
  local dir="$3"
  local docker_dir="$4"
  docker cp "${dir}/${file}" "${container_name}:${docker_dir}/${file}"
}

function init_environment() {
  local container_name="$1"
  local file="init.sh"
  local dir="$2"
  local docker_dir="$3"
  _copy_to_docker "${container_name}" "${file}" "${dir}" "${docker_dir}"
  docker exec -it "${container_name}" bash -c "chmod +x ${docker_dir}/${file}"
  docker exec -it "${container_name}" bash -c "${docker_dir}/${file}"
}

function init_container() {
  local container_name="$1"
  docker build -t "bash-tester:1" .
  docker run --rm -d --hostname=archlinux --name="${container_name}" --user=root -it bash-tester:1
}

function stop_container() {
  local container_name="$1"
  docker stop -t 1 "${container_name}" >/dev/null 2>&1
}

function _extract_keys_from_json() {
  local json="$1"
  jq 'keys[]' <"${json}" | xargs
}

function make_function_from_key() {
  local json_file="$1"
  local keys
  keys=$(_extract_keys_from_json "$json_file")
  for key in ${keys}; do
    echo "function ${key}() {
  echo
}
" >>"${default_files_dir}/check.sh"
  done
}

function _extract_input_from_json() {
  local json="$1"
  local key="$2"
  jq ".${key}.input" <"${json}"
}

function _extract_output_from_json() {
  local json="$1"
  local key="$2"
  jq ".${key}.output" <"${json}"
}

function _extract_return_from_json() {
  local json="$1"
  local key="$2"
  jq ".${key}.return" <"${json}"
}

function _check_return_status() {
  local return_status="$1"
  local expected_return_status="$2"
  if [ "${return_status}" == "${expected_return_status}" ]; then
    _sucess_color "return code OK"
  else
    _error_color "return code FAIL"
  fi
}

function _check_output() {
  local output="$1"
  local expected_output="$2"
  if [ "$(grep -cPi "${expected_output}" <<<"${output}")" -gt 0 ]; then
    _sucess_color "[+] output OK"
  else
    _error_color "[-] output FAIL"
  fi
}

function run_final_test() {
  local container_name="$1"
  local key="$2"
  _copy_to_docker "${container_name}" "check.sh" "${default_files_dir}" "$default_docker_dir"
  docker exec -it "${container_name}" bash -c "chmod +x ${default_docker_dir}/check.sh"
  docker exec -it "${container_name}" bash -c ". ${default_docker_dir}/check.sh && ${key}"
}

function restore_from_backup() {
  local main_script="$1"
  local folder="${main_script%/*}"

  if [ -d "${default_files_dir}" ]; then
    _warning_color "El directorio ${default_files_dir} existe, desea sobreescribirlo?"
    read -p "Presione [S/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
      rm -rf "${default_files_dir}"
      cp -rf "${folder}" "${default_files_dir}"
      cp -f "${main_script}" ./"${main_script##*/}"
      cp -f "${folder}"/Dockerfile ./Dockerfile
    else
      _error_color "No se pudo restaurar el directorio ${default_files_dir}"
      exit 1
    fi
  else
    cp -r "${folder}" "${default_files_dir}"
    cp "${main_script}" ./"${main_script##*/}"
    cp -f "${folder}"/Dockerfile ./Dockerfile
  fi
}

function take_tests() {
  local container_name="$1"
  local json="${2}/inputs.json"
  local script_name="$3"
  local time_limit="$4"

  _warning_color "${COL_CYAN}La primera vez que se ejecuta este script puede tardar un poco (se esta creando tu ambiente de pruebas), por favor espere...
  ${COL_RESET}" >&2

  for key in $(jq 'keys[]' <"${json}"); do
    _info_color "--- Test ${key}: ---" | tee -a ./resume
    init_container "$default_docker_name" "$default_files_dir" "$default_docker_dir" &>/dev/null
    init_environment "$default_docker_name" "$default_files_dir" "$default_docker_dir" &>/dev/null
    _copy_to_docker "$default_docker_name" "$script_name" "." "$default_docker_dir"

    local input=""
    input=$(jq -r ".${key}.input" <"${json}")
    local output=""
    output=$(jq -r ".${key}.output" <"${json}")
    local return=""
    return=$(jq -r ".${key}.return" <"${json}")

    docker exec -it "${container_name}" bash -c "chmod +x ${default_docker_dir}/${script_name}"
    docker exec -it "${container_name}" bash -c "timeout --preserve-status ${time_limit}s ${default_docker_dir}/${script_name} ${input}" >./logs.txt
    local return_status=$?

    _check_output "$(cat ./logs.txt)" "${output}" | tee -a ./resume
    _check_return_status "${return_status}" "${return}" | tee -a ./resume

    _info_color "Ejecutando pruebas de estado final para ${key}" | tee -a ./resume
    run_final_test "${container_name}" "${key}" | tee -a ./resume

    echo "---------------------------------------------------------" | tee -a ./resume
    cat ./logs.txt >>./all_logs.txt
    stop_container "${container_name}"
  done
  echo
  _warning_color "El resumen de las pruebas se encuentra en el archivo ./resume"
}

optionD=""
optionN=""
optionR=""
optionJ=""
optionM=""
optionB=""
optionP=""
optionT=""
paramT=""
paramP=""
paramB=""
paramD=""

while getopts ":hd:nrjmb:p:t:" opt; do
  case $opt in
  h)
    usage
    exit 0
    ;;
  d)
    optionD="1"
    paramD="$OPTARG"
    ;;
  n)
    optionN="1"
    ;;
  r)
    optionR="1"
    ;;
  j)
    optionJ="1"
    ;;
  m)
    optionM="1"
    ;;
  b)
    optionB="1"
    paramB="$OPTARG"
    ;;
  p)
    optionP="1"
    paramP="$OPTARG"
    ;;
  t)
    optionT="1"
    paramT="$OPTARG"
    ;;
  \?)
    _error_color "Opción inválida: -$OPTARG" >&2
    exit 1
    ;;
  :)
    _error_color "Opción -$OPTARG requiere un argumento." >&2
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

script_to_test="$1"

[ "$optionN" == "1" ] && make_env_files '.' && exit 0
[ "$optionR" == "1" ] && rm -rf "${default_files_dir}" && rm -f all_logs.txt logs.txt resume Dockerfile && exit 0
[ "$optionJ" == "1" ] && check_files "$default_files_dir" && exit 0
[ "$optionB" == "1" ] && make_backup "$paramB" && exit 0
[ "$optionM" == "1" ] && make_function_from_key "${default_files_dir}/inputs.json" && exit 0
[ "$optionP" == "1" ] && restore_from_backup "${paramP}" && exit 0
[ "$optionT" == "1" ] && take_tests "$default_docker_name" "$default_files_dir" "$script_to_test" "${paramT}" && exit 0
[ "$script_to_test" ] || {
  _error_color "Si desea probar un script debe especificarlo" >&2 && usage
  exit 1
}

dependency_check "jq" "docker" "shellcheck"

function ctrl_c() {
  _error_color "Se ha interrumpido la ejecución del script"
  stop_container "${default_docker_name}"
  exit 1
}

trap ctrl_c INT

take_tests "$default_docker_name" "$default_files_dir" "$script_to_test" "5"
