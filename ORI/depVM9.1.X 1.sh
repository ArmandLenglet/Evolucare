#!/bin/bash
#######################
# WASS2WASS CORPORATION
# VERSION DU 08/06/2023
# V9.1.4


#################
#ORDRE D'EXECUTION : BDD, APP, HUB, INTEROP, UVIEW

#################
#DO NOT EDIT THIS
G='\033[32;1m'
R='\033[0;31m'
Y='\033[33m'
W='\033[38m'
ERRORS=()

#################
#Variables TO EDIT
VMTYPE=$(cut -d '-' -f 2 /etc/hostname)
CLIENT=""								#a changer en minuscule | futur hostname - exemple : (imgprd-app-nomduclient)
HOSTNAME="imgprd-$VMTYPE"
AUTOUPDATEH="00"							#a changer | heure autoupdate dans crontab
AUTOUPDATEM="30"							#a changer | minute autoupdate dans crontab
IPGATEWAY="" 					#a changer | passerelle reseau
IP="IP${VMTYPE^^}"
NETMASK="255.255.255.0" 					#a changer | masque reseau
NDD=""  				#a changer | nom de domaine du client
DNS1=""							#peut etre remplace par une ip entre guillemets "" ou quotes ''
DNS2=""
ISMIPIH=false								#peut etre remplace par une autre ip entre guillemets "" ou quotes ''
ISHYPERV=true								#HYPERV (true) OR ESX (false)
ISTX=false									#TX (true) OR NOT TX (false)

#Variables APP
IPAPP=""   					#a changer | adresse ip de la vm app
IPP=""       							#a changer | ipp a definir, vide "" par défaut = 1
HOSTMAIL=""				 		#a changer | serveur mail correspondant au nom de domaine
USERMAIL=""	    				#a changer | user mail du nom de domaine
PASSWORDMAIL=''  		 	#a changer | password mail correspondant a l utilisateur du dessus

#Variables BDD
IPBDD=""   					#a changer | adresse ip de la vm bdd
IPBDDINTERNE="10.42.42.102"

#Variables HUB
IPHUB=""   						#a changer, vide "" si aucun | adresse ip de la vm hub

#Variable UVIEW
IPUVIEW="" 					    #a changer, vide "" si aucun | adresse ip de la vm uview

#Variables INTEROP
IPINTEROP=""       				#a changer, vide "" si aucun | adresse ip de la vm introp

#Variables APPBIS
IPAPPBIS=""        			#a changer, vide "" si aucun | adresse ip de la vm appbis

#Variable NAS BACKUP
IPNAS=""   					#a changer, vide "" si aucun | adresse ip du NAS

################
#Main GLOBAL
#Change hostname
echo -e "${G}[+] EDIT HOSTNAME TO $HOSTNAME"
echo $HOSTNAME > /etc/hostname
hostname $HOSTNAME
sed -i "s;.*127.0.1.1.*;127.0.1.1\t$HOSTNAME;" /etc/hosts

#Change DNS
cp /dev/null /etc/resolv.conf
if [[ $IPGATEWAY != "" ]]
then
	echo -e "${G}[+] ADD DNS1 TO $DNS1"
	echo "nameserver $DNS1" >> /etc/resolv.conf
fi
echo -e "${G}[+] ADD DNS2 TO $DNS2"
echo "nameserver $DNS2" >> /etc/resolv.conf

echo -e "${G}[+] EDIT GENERAL SCRIPTS.CONF"
sed -i 's;.*HOSTNAME_NAGIOS.*;HOSTNAME_NAGIOS="imgprd-bdd";' /opt/scripts/scripts.conf

#CRONTAB
echo -e "${G}[+] EDIT GENERAL CRONTAB"
if [[ $AUTOUPDATEH != "" ]] || [[ $AUTOUPDATEM != "" ]]
then
	crontab -l | sed -r "s;.*/opt/scripts/autoupdate.sh.*;$AUTOUPDATEM $AUTOUPDATEH     \* \* \*   \/opt\/scripts\/autoupdate.sh \>\> \/var\/log\/etmi\/scripts.log 2\>\&1;g" | crontab -
fi
crontab -l | sed '/local-nagios-check/s/^#//g' | crontab -
	
#NETWORK file
if [[ $IPAPP != "" || $IPBDD != "" || $IPINTEROP != "" || $IPHUB != "" || $IPUVIEW != "" ]]
then
	echo -e "${G}[+] CONFIGURE ETH0 NETWORK"
	echo '# This file describes the network interfaces available on your system' > /etc/network/interfaces
	echo -e "# and how to activate them. For more information, see interfaces(5).\n" >> /etc/network/interfaces
	echo -e "source /etc/network/interfaces.d/*\n" >> /etc/network/interfaces
	echo '# The loopback network interface' >> /etc/network/interfaces
	echo 'auto lo' >> /etc/network/interfaces
	echo -e "iface lo inet loopback\n" >> /etc/network/interfaces
	echo '# The primary network interface' >> /etc/network/interfaces
	echo 'auto eth0' >> /etc/network/interfaces
	echo 'allow-hotplug eth0' >> /etc/network/interfaces
	echo 'iface eth0 inet static' >> /etc/network/interfaces
	echo -e "\taddress ${!IP}" >> /etc/network/interfaces
	echo -e "\tnetmask $NETMASK" >> /etc/network/interfaces
	echo -e "\tgateway $IPGATEWAY" >> /etc/network/interfaces
	echo -e "\tpost-up iptables-restore < /etc/iptables.up.rules\n" >> /etc/network/interfaces
	echo -e "#auto eth1" >> /etc/network/interfaces
	echo '#allow-hotplug eth1' >> /etc/network/interfaces
	echo '#iface eth1 inet static' >> /etc/network/interfaces
	echo -e "\t#address 10.42.42.X" >> /etc/network/interfaces
	echo -e	"\t#netmask 255.255.255.0" >> /etc/network/interfaces
	sed -i "/iface eth0 inet dhcp/d" /etc/network/interfaces
	systemctl restart networking
fi

#IPTABLES
if [[ "$VMTYPE" == "app" || "$VMTYPE" == "hub" ]]
then
		echo -e "${G}[+] CONFIGURE GENERAL IPTABLES"
		if [[ $IPAPPBIS != "" ]]
        then
                sed -i '/1443/s/^#//g' /etc/iptables.up.rules
                sed -i "s;IP_VM_BI;$IPAPPBIS;" /etc/iptables.up.rules
				sed -i "s;X.X.X:1443;$IPAPPBIS:1443;" /etc/iptables.up.rules
        fi
        if [[ $IPUVIEW != "" ]]
        then
                sed -i '/444/s/^#//g' /etc/iptables.up.rules
                sed -i "s;IP_VM_UVIEW;$IPUVIEW;" /etc/iptables.up.rules
				sed -i "s;X.X.X.X:444;$IPUVIEW:444;" /etc/iptables.up.rules
        fi
        iptables-restore < /etc/iptables.up.rules
fi


################
#Main APP

		echo -e "${W}##### APP #####"

        if [ $ISHYPERV = true ]
        then
				echo -e "${G}[+] CONFIGURE ETH1 NETWORK"
                sed -i "s;.*auto eth1;auto eth1;" /etc/network/interfaces
                sed -i "s;.*allow-hotplug eth1;allow-hotplug eth1;" /etc/network/interfaces
                sed -i "s;.*iface eth1 inet static;iface eth1 inet static;" /etc/network/interfaces
                sed -i "s;.*address 10.42.42.X;\taddress $IPAPPINTERNE;" /etc/network/interfaces
                sed -i "/.*10.42.42.*/{n;s/.*/\tnetmask 255.255.255.0/}" /etc/network/interfaces
                systemctl restart networking
        fi
		
		if [[ $IPAPP != "" ]]
        then
			#Script.conf
			echo -e "${G}[+] CONFIGURE SCRIPTS.CONF" 
			sed -i "s;PRODUCTIONETH0IP=.*;PRODUCTIONETH0IP=$IPAPP;" /opt/scripts/scripts.conf
		fi
		
        #Resize disk4
		pvresize /dev/sdd
		sleep 5
		pvresize /dev/sdd
		FREEPE=+$(pvdisplay /dev/sdd | grep "Free PE" | sed -n -e 's/^.*E //p')
		FREEPE=${FREEPE//[[:blank:]]/}
        if [[ $FREEPE -ne 0 ]]
        then
			echo -e "${G}[+] RESIZE DISK 4${W}" 
			lvresize -l $FREEPE /dev/datadisks/datas
			xfs_growfs /mnt/data1/
        fi
		

		

		
        #Lien ECSIMAGING vers BDD
		echo -e "${G}[+] CONFIGURE CONFIG.INI"
		sed -i 's;.*sql_password.*;sql_password=daPD*taba-hzpsqhNA:a;' /opt/etmi/ECS/config.ini
		if [[ $ISHYPERV == "false" ]]
		then
			sed -i "s;.*sql_hostname.*;sql_hostname=10.42.42.102;" /opt/etmi/ECS/config.ini
		fi
		
        #UUID IMGPRD-APP
        HOSTBDD=$(grep "sql_hostname" /opt/etmi/ECS/config.ini | cut -d'=' -f2)
        PORTBDD=$(grep "sql_port" /opt/etmi/ECS/config.ini | cut -d'=' -f2)
        USERBDD=rwuser
		if echo "quit" | telnet "$HOSTBDD" "3306" 2>/dev/null | grep -q "Escape character is '^]'"; then
			echo -e "${G}[+] GENERATE BDDUID"
			mysql ecspreferences -h $HOSTBDD -P $PORTBDD -u$USERBDD -p'fA3?ytcPYKp!=i6KFR&S' -e "DELETE FROM configuration WHERE name='server_uuid';INSERT INTO configuration SET value=UUID(), name='server_uuid', comment='Identifiant unique du serveur, utilisé comme identifiant dans le système de mise à jour'; SELECT * FROM configuration WHERE name LIKE '%UUID%';" | grep uuid | cut -d$'\t' -f3
			BDDUID=$(mysql ecspreferences -h $HOSTBDD -P $PORTBDD -u$USERBDD -p'fA3?ytcPYKp!=i6KFR&S' -e "DELETE FROM configuration WHERE name='server_uuid';INSERT INTO configuration SET value=UUID(), name='server_uuid', comment='Identifiant unique du serveur, utilisé comme identifiant dans le système de mise à jour'; SELECT * FROM configuration WHERE name LIKE '%UUID%';" | grep uuid | cut -d$'\t' -f3)
		else
			echo -e "${R}[-] ERROR GENERATE BDDUID\n- From VM BDD: check iptables of vm BDD\n- From VM APP: check the bdd ip in /opt/etmi/ECS/config.ini"
			ERRORS+=("BDDUID")
		fi
		
		#Config fstab
		if [[ $IPNAS != "" ]]
		then
			echo -e "${G}[+] CREATE TEMPLATE FSTAB FOR NAS"
			echo "#BACKUPNAS - CIFS" >> /etc/fstab
			echo "#$IPNAS:/backupnas /mnt/backupnas nfs rw,auto 0 0" >> /etc/fstab
		fi
		
		#Crontab
		echo -e "${G}[+] EDIT CRONTAB"
		crontab -l | sed '/xtInitAll/s/^#//g' | crontab -
		crontab -l | sed '/compagnonApicrypt/s/^#//g' | crontab -
		
		#ZIP SQL
		#(crontab -l 2>/dev/null; echo -e "\n# Zip SQL\n#0 23   * * * /opt/scripts/sql-dumpzip.sh --rmsqlsrc --nodate /mnt/backupnas >> /var/log/etmi/scripts.log 2>&1") | crontab -
		
        

################
#Main INTEROP
elif [[ "$VMTYPE" == "interop" ]]
then
	echo -e "${W}##### INTEROP #####"

	#IPTABLES
	echo -e "${G}[+] CONFIGURE IPTABLES"
	sed -i "/.*FROM VPN CORWIN.*/d" /etc/iptables.up.rules
	sed -i "/.*10.10.14.0.*/d" /etc/iptables.up.rules
	if [[ $IPAPPBIS != "" ]]
	then
		sed -i "s;-A INPUT -p tcp -m tcp --dport 8080 -s 192.168.13.0/24 -j ACCEPT;-A INPUT -p tcp -m tcp --dport 8080 -s $IPAPPBIS -j ACCEPT;" /etc/iptables.up.rules
		sed -i "s;-A INPUT -p tcp -m tcp --dport 8443 -s 192.168.13.0/24 -j ACCEPT;-A INPUT -p tcp -m tcp --dport 8443 -s $IPAPPBIS -j ACCEPT;" /etc/iptables.up.rules
	fi
	sed -i 's;-A INPUT -p tcp -m tcp --dport 6661 -s 192.168.13.50 -j ACCEPT;-A INPUT -p tcp -m tcp --dport 6661 -j ACCEPT;' /etc/iptables.up.rules
	sed -i 's;-A INPUT -p tcp -m tcp --dport 6662 -s 192.168.13.50 -j ACCEPT;-A INPUT -p tcp -m tcp --dport 6662 -j ACCEPT;' /etc/iptables.up.rules
	iptables-restore < /etc/iptables.up.rules
	
	#Config fstab
	if [[ $IPAPP != "" ]]
	then
		echo -e "${G}[+] CONFIGURE FSTAB TO CONNECT TO APP"
		sed -i '/X.X.X.X/s/^#//g' /etc/fstab
		sed -i "s;X.X.X.X;$IPAPP;" /etc/fstab
	fi

	#config smb
	echo -e "${G}[+] CONFIGURE SAMBA TO CONNECT TO APP"
	sed -i "s;password=.*;password=rRDe6PYhhc@8oiQjH3ak;" /root/.smbpasswd

	#Patch iblogfile can't start mysql
	if [[ -f "/var/lib/mysql/ib_logfile0" ]]; then
		mv /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile0.bkp
	fi
	if [[ -f "/var/lib/mysql/ib_logfile1" ]]; then
		mv /var/lib/mysql/ib_logfile1 /var/lib/mysql/ib_logfile1.bkp
	fi
	
################
#Main UVIEW
elif [[ "$VMTYPE" == "uview" ]]
then
	echo -e "${W}##### UVIEW #####"
    sed -i "/post-up iptables-restore.*/d" /etc/network/interfaces

fi

#if [ $ISHYPERV == false ]
#then
	#echo -e "${G}[+] INSTALL VM-TOOLS${W}"
	#apt --fix-broken install -y
	#apt-get update -y
	#apt-get install open-vm-tools -y
#fi
#################################################################

if [ $ISMIPIH == true ]
then
	echo -e "${G}[+] SET PROXY${W}"
	echo -e "\nexport http_proxy=http://proxy.mipih.local:3128\nexport https_proxy=http://proxy.mipih.local:3128" >> /etc/bash.bashrc
	echo -e "\nhttps_proxy = http://proxy.mipih.local:3128/\nhttp_proxy = http://proxy.mipih.local:3128/\nuse_proxy = on\nno_proxy = 127.0.0.1,127.0.1.1,localhost" >> /etc/wgetrc
	echo -e "proxy=http://proxy.mipih.local:3128" > /root/.curlrc
fi

echo -e "${G}[+] LAUNCH AUTOUPDATE${W}"
/opt/scripts/autoupdate.sh
/opt/scripts/autoupdate.sh
/opt/scripts/autoupdate.sh
/opt/scripts/local-nagios-check.sh


DEPREADME="/root/depreadme.txt"
#CONTENU DU FICHIER DEPREADME
echo -e "${W}#################################" > $DEPREADME
echo -e "${W}TACHES RESTANTES POST DEPLOIEMENT" >> $DEPREADME
echo -e "${W}#################################\n" >> $DEPREADME

if [[ "$VMTYPE" == "hub" ]]
then
	echo -e "\n-------HUB-------" >> $DEPREADME
	echo 'Public key :' >> $DEPREADME
	cat /home/support/.ssh/id_rsa.pub >> $DEPREADME
	echo 'sur les autres VM, coller dans :' >> $DEPREADME
	echo 'nano /home/support/.ssh/authorized_keys' >> $DEPREADME
	echo 'nano /opt/scripts/auth/etmikey2' >> $DEPREADME
	echo 'chmod 700 /home/support/.ssh' >> $DEPREADME
	echo 'chmod 600 /home/support/.ssh/authorized_keys' >> $DEPREADME
fi

if [[ "$VMTYPE" == "app" ]]
then
	echo -e "\n-------APP-------" >> $DEPREADME
	echo "BDD UUID : $BDDUID" >> $DEPREADME
	echo 'Inscrire le UUID dans maj-imaging et selectionner la mise a jour' >> $DEPREADME
	echo 'dans un screen : /opt/scripts/launch-maj-imaging.sh' >> $DEPREADME
	echo 'Generer les certificats SSL' >> $DEPREADME
	echo 'Decommenter dans fstab la ligne du NAS' >> $DEPREADME
fi

echo -e "\n-------GLOBAL-------" >> $DEPREADME
echo 'Inscrire le site dans le monitoring Icinga' >> $DEPREADME
echo 'ATTENTION : si VM EXPORT, lancer les commandes :' >> $DEPREADME
echo 'dpkg-reconfigure tzdata' >> $DEPREADME
echo 'for PHPINIFILE in `find /etc/php*/ -name "php.ini"`; do sed -i "/date\.timezone\ =/c\date\.timezone\ =\ 'America\/Guadeloupe'" $PHPINIFILE; done' >> $DEPREADME

if [[ ${ERRORS[@]} != "" ]]; then
	echo -e "\n-------ERRORS-------" >> $DEPREADME
	for ERROR in ${ERRORS[@]}; do
		echo "$ERROR">> $DEPREADME
	done
fi

#CLEAN
rm $0
echo "" > /root/.bash_history
history -c && history -w

#REBOOT TO APPLY HOSTNAME
if [[ ${ERRORS[@]} == "" ]]; then
	echo -e "${G}##### Aucune erreur détectée lors du déploiement #####"
	echo -e "${W}Merci de lire le fichier $DEPREADME pour voir les tâches restantes"
	echo -e "${W}La VM va redémarrer dans 10 secondes"
	sleep 10 && reboot
else
	echo -e "${R}!!!!! Des erreurs ont été détectées lors du déploiement !!!!!"
	echo -e "${W}Merci de lire le fichier $DEPREADME pour les corriger et de redémarrer la VM"
fi
