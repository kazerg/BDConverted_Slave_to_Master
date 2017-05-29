#!/bin/bash
sleep 30s
while true; do
        #IP Interficie de Monitoring
        ip=$(ip -f inet -o addr show ens38|cut -d\  -f 7 | cut -d/ -f 1)
        #PID del servicio mysql
        mysql=`ps awx | grep 'mysql' |grep -v grep|wc -l`
        #Si el servicio se detiene
        if [ $mysql == 0 ]
        then
        #Se desconecta de la red de base de datos
                sudo chmod 666 /etc/network/interfaces
                sleep 1s
                echo "#Generado por ipvn escrito por veneno" > /etc/network/interfaces
                echo auto ens38 >> /etc/network/interfaces
                echo iface ens38 inet static >> /etc/network/interfaces
                echo address $ip >> /etc/network/interfaces
                echo netmask 255.255.255.0 >> /etc/network/interfaces
                echo auto lo >> /etc/network/interfaces
                echo iface lo inet loopback >> /etc/network/interfaces
                sleep 1s
                # Reinicio de las interfaces
                sudo /etc/init.d/networking restart
                sudo chmod 644 /etc/network/interfaces
                sudo invoke-rc.d networking stop
                sudo invoke-rc.d networking start
                sleep 1s
                sudo ifconfig ens33 down
                sudo ifconfig ens38 up
                break;
        fi
        sleep 10s
done
