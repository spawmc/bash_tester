#!/bin/bash
  
# Script de inicialización de ambiente de pruebas
# Aqui se pueden agregar instrucciones para inicializar el ambiente de pruebas
# Ejemplo:
#   dir="/home/user/testenv"
#   mkdir -p $dir
#   touch $dir/test.txt
#   echo "hola mundo" > $dir/test.txt
#   pacman -S git

pacman -S openssh --noconfirm
mkdir /root/.ssh
echo "192.168.100.11 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOCqiZU59Wm06v1s+OltI+iwCaRoNe7GFgqcIsFqCy5BSAaY2oBJf5wJ+EN+18s3Nl4L+s0Z+bYultYtR8wcK2g=" > /root/.ssh/known_hosts