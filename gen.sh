#!/bin/sh

# This script takes two arguments, first is the name of the client/configuration and an IP address.

ROOT_DIR=$(pwd)
CONF_ROOT_DIR="$ROOT_DIR"/confs

[ ! -d "$CONF_ROOT_DIR" ] && mkdir "$CONF_ROOT_DIR"

NAME="$1"
ADDRESS="$2"
CONF_TABLE="$CONF_ROOT_DIR"/conf.csv

[ ! -f "$CONF_TABLE" ] && printf "NAME,ADDRESS,PRIVATE KEY,PUBLIC KEY, PRESHARED KEY\n" > "$CONF_TABLE"


# Environment Variables
ENV_FILE="$ROOT_DIR"/gen.env

[ ! -f "$ENV_FILE" ] && printf "Server configuration does not exits.\nGenerating one...\n" && ./gen.server

SERVER_PUB=$(grep PublicKey "$ENV_FILE" | cut -d' ' -f 3)
ENDPOINT=$(grep Endpoint "$ENV_FILE" | cut -d' ' -f 3)
DNS=$(grep DNS "$ENV_FILE" | cut -d' ' -f 3)


# Make the directory of the configuration if unexisting
[ ! -d "$CONF_ROOT_DIR"/"$NAME" ] && mkdir "$CONF_ROOT_DIR"/"$NAME"

BASE="$CONF_ROOT_DIR"/"$NAME"/"$NAME"

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

{
printf "%s," "$NAME"
printf "%s," "$ADDRESS"
printf "%s," "$CLIENT_KEY_VAL"
printf "%s," "$CLIENT_PUB_VAL"
printf "%s\n" "$CLIENT_PSK_VAL"
} >> "$CONF_TABLE"

printf "\n%s\n" "$CLIENT_CONF"
echo "---------- BEGIN CLIENT CONFIGURATION -----------"
printf "\n\n"

{
	printf "[Interface]\n"
	printf "Address = %s/32\n" "$ADDRESS"
	printf "PrivateKey = %s\n" "$CLIENT_KEY_VAL"
	printf "DNS = %s\n\n" "$DNS"

	printf "[Peer]\n"
	printf "PublicKey = %s\n" "$SERVER_PUB"
	printf "PresharedKey = %s\n" "$CLIENT_PSK_VAL"
	printf "Endpoint = %s\n" "$ENDPOINT"
	printf "AllowedIPs = 0.0.0.0/0, ::/0"

} | tee -a "$CLIENT_CONF"


printf "\n\n"
echo "---------- END CLIENT CONFIGURATION -----------"
printf "\n\n"

SERVER_CONF="$ROOT_DIR"/gen.server.conf
printf "\n\n"
printf "\n\n"
printf "\n%s\n" "$SERVER_CONF"
echo "---------- BEGIN SERVER CONFIGURATION -----------"
printf "\n\n"

{
	printf "\n\n# %s\n" "$NAME"
	printf "[Peer]\n"
	printf "PublicKey = %s\n" "$CLIENT_PUB_VAL"
	printf "PresharedKey = %s\n" "$CLIENT_PSK_VAL"
	printf "AllowedIPs = %s/32\n" "$ADDRESS"
} | tee -a "$SERVER_CONF"

echo "---------- END SERVER CONFIGURATION -----------"
