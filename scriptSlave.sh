#!/bin/bash
while true; do
        ipaddressa=$(ip -f inet -o addr show ens33|cut -d\  -f 7 | cut -d/ -f 1)
        #Si es Master
        if [ $ipaddressa == '192.168.8.1' ]
        then
                mysql=`ps awx | grep 'mysql' |grep -v grep|wc -l`
                #Si el servicio mysql se detiene
                if [ $mysql == 0 ]
                #Deja de ser master y se desconecta de la red de Base de datos
                then
                        sudo chmod 666 /etc/network/interfaces
                        sleep 1s
                        echo "#Generado por ipvn escrito por veneno" > /etc/network/interfaces
                        echo "#auto ens33" >> /etc/network/interfaces
                        echo iface ens33 inet static >> /etc/network/interfaces
                        echo "#address 192.168.8.1" >> /etc/network/interfaces
                        echo "#netmask 255.255.255.0" >> /etc/network/interfaces
                        echo auto ens38 >> /etc/network/interfaces
                        echo iface ens38 inet static >> /etc/network/interfaces
                        echo address 192.168.21.22 >> /etc/network/interfaces
                        echo netmask 255.255.255.0 >> /etc/network/interfaces
                        echo auto lo >> /etc/network/interfaces
                        echo iface lo inet loopback >> /etc/network/interfaces
                        sleep 1s
                        sudo /etc/init.d/networking restart
                        sudo chmod 644 /etc/network/interfaces
                        sleep 1s
                        sudo ifconfig ens33 down
                        break;
                fi
                sleep 10s
        #Si es Slave
        else
                if ping -q -c10 192.168.8.1 &>/dev/null;
                then
                        $@
                #Si deja de estar conectado al servidor Master
                else
                        #Cambiara su IP a la IP del Master
                        sudo chmod 666 /etc/network/interfaces
                        sleep 1s
                        echo "#Generado por ipvn escrito por veneno" > /etc/network/interfaces
                        echo auto ens33 >> /etc/network/interfaces
                        echo iface ens33 inet static >> /etc/network/interfaces
                        echo address 192.168.8.1 >> /etc/network/interfaces
                        echo netmask 255.255.255.0 >> /etc/network/interfaces
                        echo auto ens38 >> /etc/network/interfaces
                        echo iface ens38 inet static >> /etc/network/interfaces
                        echo address 192.168.21.22 >> /etc/network/interfaces
                        echo netmask 255.255.255.0 >> /etc/network/interfaces
                        echo auto lo >> /etc/network/interfaces
                        echo iface lo inet loopback >> /etc/network/interfaces
                        sudo /etc/init.d/networking restart
                        sudo invoke-rc.d networking stop
                        sudo invoke-rc.d networking start
                        sudo chmod 644 /etc/network/interfaces
                        sleep 1s
                        sudo ifconfig ens33 down
                        sudo ifconfig ens33 up
                        ip addr flush ens33 && systemctl restart networking.service
                        ip addr flush ens38 && systemctl restart networking.service sleep 1s
                        #Para de ser Slave
                        mysql -u root -p30393039 -e "STOP SLAVE;"
                        sleep 2s
                        #Se reinicia como Master
                        mysql -u root -p30393039 -e "RESET MASTER;"
                        #Copiamos del directorio la plantilla del mysql Master a la configuración del Mysql
                        #Cambiar el /home/projecte/script/ por el directorio donde estara el script y la plantilla Master
                        sudo cp /home/projecte/script/mysqld_master.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
                        sudo service mysql restart
                        sudo chmod 666 /etc/hostname
                        sudo chmod 666 /etc/hosts
                        sudo chmod 666 /proc/sys/kernel/hostname
                        sleep 1s
                        #Cambiamos el nombre de la máquina
                        echo MasterServerDB > /proc/sys/kernel/hostname
                        echo MasterServerDB > /etc/hostname
                        echo 127.0.0.1  localhost > /etc/hosts
                        echo 127.0.0.1  MasterServerDB >> /etc/hosts
                        echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
                        echo "::1     localhost ip6-localhost ip6-loopback" >> /etc/hosts
                        echo "ff02::1 ip6-allnodes" >> /etc/hosts
                        echo "ff02::1 ip6-allrouters" >> /etc/hosts
                        sudo chmod 644 /etc/hostname
                        sudo chmod 644 /etc/hosts
                        sudo chmod 644 /proc/sys/kernel/hostname
                        sleep 1s
                fi
        fi
done
