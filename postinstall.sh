#!/bin/bash

#
# Copyright (C) 2012 Héctor Arroyo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

IF_PATH="/etc/network/interfaces"
SOURCES_LST_PATH="/etc/apt/sources.list"
LOCAL_DNS="192.168.1.105"
RESOLVCONF_PATH="/etc/resolv.conf"

echo -n "IP de esta máquina: 192.168.1.";
read vmip

echo "# This file describes the network interfaces available on your system" > $IF_PATH
echo "# and how to activate them. For more information, see interfaces(5)." >> $IF_PATH
echo >> $IF_PATH

echo "# The loopback network interface"  >> $IF_PATH
echo "auto lo"                           >> $IF_PATH
echo "iface lo inet loopback"            >> $IF_PATH
echo ""  >> $IF_PATH
echo "# The primary network interface"   >> $IF_PATH
echo "#allow-hotplug eth0"               >> $IF_PATH
echo "auto eth0"                         >> $IF_PATH
echo "iface eth0 inet static"            >> $IF_PATH
echo "        address 192.168.1.$vmip"   >> $IF_PATH
echo "        netmask 255.255.255.0"     >> $IF_PATH
echo "        network 192.168.1.0"       >> $IF_PATH
echo "        broadcast 192.168.1.255"   >> $IF_PATH
echo "        gateway 192.168.1.1"       >> $IF_PATH
echo "" >> $IF_PATH

echo "Generado archivo " $IF_PATH ":"
cat $IF_PATH
echo

echo "Configurando servidores DNS"
echo "nameserver $LOCAL_DNS" > $RESOLVCONF_PATH
echo "nameserver 87.216.1.65" >> $RESOLVCONF_PATH
echo "nameserver 87.216.1.66" >> $RESOLVCONF_PATH
echo "nameserver 62.37.228.20" >> $RESOLVCONF_PATH

echo "Generado archivo " $RESOLVCONF_PATH ":"
cat $RESOLVCONF_PATH
echo
echo "Esperando 5s..."; sleep 5

DEB_LINE1="deb http://ftp.es.debian.org/debian/ squeeze main contrib"
DEB_LINE2="deb-src http://ftp.es.debian.org/debian/ squeeze main contrib"

if ! grep "$DEB_LINE1" $SOURCES_LST_PATH
then
    echo "$DEB_LINE1" >> $SOURCES_LST_PATH
fi

if ! grep "$DEB_LINE2" $SOURCES_LST_PATH
then
    echo "$DEB_LINE2" >> $SOURCES_LST_PATH
fi

echo "Generado archivo " $SOURCES_LST_PATH ":"
cat $SOURCES_LST_PATH
echo
echo "Esperando 5s..."; sleep 5

echo "Actualizando repositorios"
apt-get update
echo "Esperando 5s..."; sleep 5
echo "Instalando paquetes necesarios"
PAQUETES="build-essential openssh-server htop open-vm-tools open-vm-source"
PAQUETES="$PAQUETES links2 cmake curl"
aptitude install $PAQUETES
echo "Esperando 5s..."; sleep 5
echo "(Re)Instalando soporte para vmware"
module-assistant auto-install open-vm -i
echo "Esperando 5s..."; sleep 5

echo "Hecho"
