# SmartPhoton vers Domoticz
Script bash de récupération des données MQTT de SmartPhoton et envoi vers l'API de Domoticz

![Domoticz](https://github.com/kekemar/SmartPhoton_To_Domoticz/blob/main/Domoticz.png)

# Préparation d'une VM
Copier fichier solar.sh dans /root/
```
apt install mosquitto-clients curl bc

mkdir /mnt/ram
nano /etc/fstab
	tmpfs /mnt/ram tmpfs defaults,size=16m 0 0
mount -av

export VISUAL=nano; crontab -e
*/1 * * * * nohup /root/solar.sh
```

# Dans Domoticz
Si votre Domoticz est dans un VM différente, il faut également installer mosquitto-clients
```
apt install mosquitto-clients
```
Créer un script LUA de type device
```
-- Script Onduleur
commandArray = {}

if devicechanged['Mode Onduleur'] == 'UTI' then
    os.execute ("mosquitto_pub -h 192.168.10.14 -m 'Param01-UTI' -t 'Onduleur/Modification-Parametres'")
end
if devicechanged['Mode Onduleur'] == 'SOL' then
    os.execute ("mosquitto_pub -h 192.168.10.14 -m 'Param01-SOL' -t 'Onduleur/Modification-Parametres'")
end
if devicechanged['Mode Onduleur'] == 'SBU' then
    os.execute ("mosquitto_pub -h 192.168.10.14 -m 'Param01-SBU' -t 'Onduleur/Modification-Parametres'")
end
   
return commandArray
```
