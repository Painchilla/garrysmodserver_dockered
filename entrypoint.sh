#! /bin/bash
#Setze Entsprechende Rechte für die Serverfiles
echo "Changing User-permissions on Gamefiles..."
sudo chown steam:steam /srv -R

COMMAND="/srv/gmod/srcds_run -ip 0.0.0.0 +game garrysmod +map $GMOD_MAP +maxplayers $GMOD_MAX_PLAYERS +gamemode $GMOD_GAMEMODE"

echo "Starting Garrysmod in mode $GMOD_GAMEMODE for $GMOD_MAX_PLAYERS Players on $GMOD_MAP"
if [[ $GMOD_WORKSHOP_COLLECTION == "false" ]]
then
	echo "Keine Workshop-Collection angegeben. Starte Server mit Vanilla-Files"
else
	if [[ $STEAM_APIKEY == "false" ]]
	then
		echo "You did not provide a Steam-APIKEY to the Container. It cannot use your providide Workshop-Collection without one."
		echo "Please provide a STEAM_APIKEY via the environment-variable"
	else
		echo "using Steam-Workshop-Collection with ID $GMOD_WORKSHOP_COLLECTION"
		COMMAND+=" +host_workshop_collection $GMOD_WORKSHOP_COLLECTION -apikey $STEAM_APIKEY"
	fi
fi

if [[ $GMOD_DEBUG == "true" ]]
then
	echo "$COMMAND"
fi
exec $COMMAND
