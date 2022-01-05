#!/bin/bash
  
# Script de inicialización de ambiente de pruebas
# Aqui se pueden agregar instrucciones para inicializar el ambiente de pruebas
# Ejemplo:
#   dir="/home/user/testenv"
#   mkdir -p $dir
#   touch $dir/test.txt
#   echo "hola mundo" > $dir/test.txt
#   pacman -S git

mkdir -p /root/prueba/primer_nivel
echo "A text file" > /root/prueba/1.txt
echo "A text file" > /root/prueba/2.txt
echo "A text file" > /root/prueba/3.txt
echo "A text file" > /root/prueba/4.txt
echo "A text file" > /root/prueba/5.txt
echo "A text file" > /root/prueba/6.txt
echo "A text file" > /root/prueba/primer_nivel/1.txt
echo "A text file" > /root/prueba/primer_nivel/2.txt
echo "A text file" > /root/prueba/primer_nivel/3.txt
echo "A text file" > /root/prueba/primer_nivel/4.txt
echo "A text file" > /root/prueba/primer_nivel/5.txt
echo "A text file" > /root/prueba/primer_nivel/7.txt
echo "A text file" > /root/prueba/primer_nivel/6.txt
echo "declare -x password=password" >> /etc/bash.bashrc
source /etc/bash.bashrc