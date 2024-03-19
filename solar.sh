#!/bin/bash

#Valeur à modifier
#--------------------------------
IP_Domoticz=192.168.10.12
IP_SmartPhoton=192.168.10.14
#IDX Domoticz
Consommation=2392					#Capteur Virtuel de type Electrique (Instantané + Compteur)		Type : Utilisation		Energy Read : Computed
Utilisation_Onduleur=2295			#Capteur Virtuel de type Pourcentage
Tension_Batterie=2284				#Capteur Virtuel Tension
Capacite_Batterie=2290				#Capteur Virtuel de type Pourcentage
Charge_Batterie_Watt=2399			#Capteur Virtuel de type Electrique (Instantané + Compteur)		Type : Retour			Energy Read : Computed
Decharge_Batterie_Watt=2310			#Capteur Virtuel de type Electrique (Instantané + Compteur)		Type : Utilisation		Energy Read : Computed
Charge_Batterie_Ampere=2291			#Capteur Virtuel de type Ampere Monophasé
Decharge_Batterie_Ampere=2292		#Capteur Virtuel de type Ampere Monophasé
Tension_Panneau_Solaire=2300		#Capteur Virtuel de type Tension
Puissance_Panneau_Solaire=2308		#Capteur Virtuel de type Electrique (Instantané + Compteur)		Type : Retour			Energy Read : Computed
Mode_Onduleur=2397					#Interrupteur Virtuel Selecteur		Cacher le niveau Off	Niveaux :	10 UTI	|	20 SOL	|	30 SBU
#--------------------------------

#Récupération des valeurs
mosquitto_sub -h $IP_SmartPhoton -t "Onduleur/conso-maison" 			-C 1 >/mnt/ram/conso-maison.txt &
mosquitto_sub -h $IP_SmartPhoton -t "Onduleur/battery-voltage" 			-C 1 >/mnt/ram/battery-voltage.txt &
mosquitto_sub -h $IP_SmartPhoton -t "Onduleur/Batt-Capacite" 			-C 1 >/mnt/ram/Batt-Capacite.txt &
mosquitto_sub -h $IP_SmartPhoton -t "Onduleur/PhotoVoltaique-Voltage" 	-C 1 >/mnt/ram/PhotoVoltaique-Voltage.txt &
mosquitto_sub -h $IP_SmartPhoton -t "Onduleur/PhotoVoltaique-Watt" 		-C 1 >/mnt/ram/PhotoVoltaique-Watt.txt &
mosquitto_sub -h $IP_SmartPhoton -t "Onduleur/Battery-charge" 			-C 1 >/mnt/ram/Battery-charge.txt &
mosquitto_sub -h $IP_SmartPhoton -t "Onduleur/Battery-discharge" 		-C 1 >/mnt/ram/Battery-discharge.txt &
mosquitto_sub -h $IP_SmartPhoton -t "Onduleur/Parameter-01" 			-C 1 >/mnt/ram/Parameter-01.txt &

#Pause le temps de récupérer les valeurs
sleep 30

usage_w=$(awk '{print $1}' /mnt/ram/conso-maison.txt)
tension_bat=$(awk '{print $1}' /mnt/ram/battery-voltage.txt)
cap_bat=$(awk '{print $1}' /mnt/ram/Batt-Capacite.txt)
tension_solaire=$(awk '{print $1}' /mnt/ram/PhotoVoltaique-Voltage.txt)
watt_solaire=$(awk '{print $1}' /mnt/ram/PhotoVoltaique-Watt.txt)
charge_bat_w=$(awk '{print $1}' /mnt/ram/Battery-charge.txt)
watt_bat=$(awk '{print $1}' /mnt/ram/Battery-discharge.txt)
mode=$(awk '{print $1}' /mnt/ram/Parameter-01.txt)
mode_inverter=$(awk '{print $1}' /mnt/ram/mode_onduleur_save.txt)

#Calcul pourcentage utilisation
if [ -n "$usage_w" ]
	then
		usage_pc=$(echo "$usage_w/5000*100" | bc -l)
fi

#Envoi des données à Domoticz
if [ -n "$tension_bat" -a "$tension_bat" != "0" ]	#Pour eviter les problemes en cas diviseur à 0
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Tension_Batterie&nvalue=0&svalue=$tension_bat" > /dev/null
		if [ -n "$watt_bat" ]
			then
			decharge_bat=$(echo "$watt_bat/$tension_bat" | bc)
			/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Decharge_Batterie_Ampere&nvalue=0&svalue=$decharge_bat" > /dev/null
			/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Decharge_Batterie_Watt&nvalue=0&svalue=$watt_bat" > /dev/null
		fi
		if [ -n "$charge_bat_w" ]
			then
			charge_bat=$(echo "$charge_bat_w/$tension_bat" | bc)
			/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Charge_Batterie_Ampere&nvalue=0&svalue=$charge_bat" > /dev/null
			/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Charge_Batterie_Watt&nvalue=0&svalue=$charge_bat_w" > /dev/null
		fi
fi

#Vérification qu'il y a bien des données dans la variable avant envoi
if [ -n "$usage_pc" ]
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Utilisation_Onduleur&nvalue=0&svalue=$usage_pc" > /dev/null
fi

if [ -n "$usage_w" ]
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Consommation&nvalue=0&svalue=$usage_w" > /dev/null
fi

if [ -n "$cap_bat" ]
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Capacite_Batterie&nvalue=0&svalue=$cap_bat" > /dev/null
fi

if [ -n "$tension_solaire" ]
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Tension_Panneau_Solaire&nvalue=0&svalue=$tension_solaire" > /dev/null
fi

if [ -n "$watt_solaire" ]
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$Puissance_Panneau_Solaire&nvalue=0&svalue=$watt_solaire" > /dev/null
fi

#Pour eviter de multiple envoi
if [ "$mode_inverter" != "UTI" -a "$mode" = "UTI" ]
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=switchlight&idx=$Mode_Onduleur&switchcmd=Set%20Level&level=10" > /dev/null
		echo "UTI" > /mnt/ram/mode_onduleur_save.txt
fi

if [ "$mode_inverter" != "SOL" -a "$mode" = "SOL" ]
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=switchlight&idx=$Mode_Onduleur&switchcmd=Set%20Level&level=20" > /dev/null
		echo "SOL" > /mnt/ram/mode_onduleur_save.txt
fi

if [ "$mode_inverter" != "SBU" -a "$mode" = "SBU" ]
	then
		/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=switchlight&idx=$Mode_Onduleur&switchcmd=Set%20Level&level=30" > /dev/null
		echo "SBU" > /mnt/ram/mode_onduleur_save.txt
fi
