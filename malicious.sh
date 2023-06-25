#!/bin/bash

# Chemin vers le fichier temporaire
TEMP_FILE="/tmp/malicious_ips.txt"

# Chemin vers le fichier contenant les règles de pare-feu actuelles
IPTABLES_RULES="/etc/iptables.rules"

# Télécharger la liste d'adresses IP malveillantes
curl https://raw.githubusercontent.com/duggytuxy/malicious_ip_addresses/main/botnets_zombies_scanner_spam_ips.txt -o $TEMP_FILE

# Lire chaque ligne du fichier temporaire
while IFS= read -r ip
do
  # Vérifier si l'adresse IP est déjà dans les règles de pare-feu
  if ! grep -q "$ip" $IPTABLES_RULES; then
    # Si elle n'est pas présente, ajouter une nouvelle règle pour bloquer cette adresse IP
    iptables -A INPUT -s $ip -j DROP
    
    # Ajouter l'adresse IP aux règles de pare-feu
    echo "-A INPUT -s $ip -j DROP" >> $IPTABLES_RULES
  fi
done < $TEMP_FILE

# Sauvegarder les règles de pare-feu
iptables-save > $IPTABLES_RULES

# Redémarrer le pare-feu
/etc/init.d/iptables restart
