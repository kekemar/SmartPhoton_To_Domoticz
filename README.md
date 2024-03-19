# SmartPhoton_To_Domoticz
Script bash de récupération des données MQTT de SmartPhoton et envoi vers l'API de Domoticz

# Préparation d'une VM
apt install mosquitto-clients curl bc

Copie fichier solar.sh dans /root/

mkdir /mnt/ram
ajouter dans /etc/fstab
	tmpfs /mnt/ram tmpfs defaults,size=16m 0 0

mount -av

export VISUAL=nano; crontab -e
*/1 * * * * nohup /root/solar.sh

# Dans Domoticz
Si votre Domoticz est dans un VM différente, il faut également installer mosquitto-clients
Créer un script LUA de type device
