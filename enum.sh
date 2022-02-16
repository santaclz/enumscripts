#!/bin/bash

if [[ -z $1 ]]; then
	echo -e "\nUsage: ./enum.sh <IP>\n"
	exit
fi

IP=$1

# Port scan
PORTS=`rustscan -a $IP -g | cut -d"[" -f2 | cut -d"]" -f1`
echo "[+] Open ports: "$PORTS
sudo nmap -T4 -sV -sC -p$PORTS $1 -oN portscan.txt

# Open in firefox if web server present
# Note: Regex checks could easily be fooled!
if [[ "$PORTS" =~ .*"80".* ]]; then
	echo "[+] HTTP server found"
	URL=http://$IP
	firefox $URL
	firefox view-source:$URL

	# Check Host header
	VHOST=`curl -sI $URL | grep Location | cut -d" " -f2 | cut -d"/" -f3`

	if [[ -n $VHOST ]]; then
		echo "[+] Hostname found: $VHOST"
		echo "Adding to /etc/hosts..."
		# TODO check if already exists
		CMD="echo "$IP"  "$VHOST" >> /etc/hosts"
		sudo sh -c "$CMD"
	fi
fi

if [[ "$PORTS" =~ .*"443".* ]]; then
	echo "[+] HTTPS server found"
	URL=http://$IP
	firefox $URL
	firefox view-source:$URL

	# Check Host header
	VHOST=`curl -sI $URL | grep Location | cut -d" " -f2 | cut -d"/" -f3`
	echo "Hostname found: $VHOST"
	echo "[*] Target uses https... Check manually"
fi


# gobuster

# subdomains
#ffuf -w ~/SecLists/Discovery/DNS/subdomains-top1million-110000.txt -u $URL -H "Host: FUZZ."$VHOST"" -mc 200 -o subdomains.txt
