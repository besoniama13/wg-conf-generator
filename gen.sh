#!/bin/sh

# This script takes two arguments, first is the name of the client/configuration and an IP address.

WD=$(pwd)
PWD="$WD"/confs

[ ! -d "$PWD" ] && mkdir "$PWD"

NAME="$1"
ADDRESS="$2"
CONF_TABLE="$PWD"/conf.csv

printf "%s," "$NAME" | tee -a "$CONF_TABLE"
printf "%s," "$ADDRESS" | tee -a "$CONF_TABLE"

# Environment Variables

ENV_FILE="$WD"/gen.env

SERVER_PUB=$(grep PublicKey "$ENV_FILE" | cut -d'=' -f 2)
ENDPOINT=$(grep Endpoint "$ENV_FILE" | cut -d'=' -f 2)
DNS=$(grep DNS "$ENV_FILE" | cut -d'=' -f 2)


# Made the directory of the configuration if unexisting
[ ! -d "$PWD"/"$NAME" ] && mkdir "$PWD"/"$NAME"

BASE="$PWD"/"$NAME"/"$NAME"

CLIENT_KEY="$BASE".key
CLIENT_PUB="$BASE".pub
CLIENT_PSK="$BASE".psk
CLIENT_CONF="$BASE".conf

# Generates the Private and Public Key to the $NAME directory
wg genkey | (umask 0077 && tee "$CLIENT_KEY" ) | wg pubkey > "$CLIENT_PUB"

# Generates the Pre Shared Key to the $NAME directory
umask 0077 && wg genpsk > "$CLIENT_PSK"

CLIENT_KEY_VAL="$( cat "$BASE".key )"
CLIENT_PUB_VAL="$( cat "$BASE".pub )"
CLIENT_PSK_VAL="$( cat "$BASE".psk )"

printf "%s," "$CLIENT_KEY_VAL" | tee -a "$CONF_TABLE"
printf "%s," "$CLIENT_PUB_VAL" | tee -a "$CONF_TABLE"
printf "%s\n" "$CLIENT_PSK_VAL" | tee -a "$CONF_TABLE"

echo "---------- BEGIN CLIENT CONFIGURATION -----------"
printf "\n%s" "$CLIENT_CONF"
printf "\n\n"
printf "[Interface]\n" | tee "$CLIENT_CONF"
printf "Address = %s/32\n" "$ADDRESS" | tee -a "$CLIENT_CONF"
printf "PrivateKey = %s\n" "$CLIENT_KEY_VAL" | tee -a "$CLIENT_CONF"
printf "DNS = %s\n\n" "$DNS" | tee -a "$CLIENT_CONF"

printf "[Peer]\n" | tee -a "$CLIENT_CONF"
printf "PublicKey = %s\n" "$SERVER_PUB" | tee -a "$CLIENT_CONF"
printf "PresharedKey = %s\n" "$CLIENT_PSK_VAL" | tee -a "$CLIENT_CONF"
printf "Endpoint = %s\n" "$ENDPOINT" | tee -a "$CLIENT_CONF"
printf "AllowedIPs = 0.0.0.0/0, ::/0" | tee -a "$CLIENT_CONF"
printf "\n\n"
echo "---------- END CLIENT CONFIGURATION -----------"
printf "\n\n"

SERVER_CONF="$BASE".server.conf
printf "\n\n"
printf "\n\n"
echo "---------- BEGIN SERVER CONFIGURATION -----------"
printf "\n%s" "$SERVER_CONF"
printf "\n\n"

printf "# %s\n" "$NAME" | tee "$SERVER_CONF"
printf "[Peer]\n" | tee -a "$SERVER_CONF"
printf "PublicKey = %s\n" "$CLIENT_PUB_VAL" | tee -a "$SERVER_CONF"
printf "PresharedKey = %s\n" "$CLIENT_PSK_VAL" | tee -a "$SERVER_CONF"
printf "AllowedIPs = %s/32\n" "$ADDRESS" | tee -a "$SERVER_CONF"

echo "---------- BEGIN SERVER CONFIGURATION -----------"
