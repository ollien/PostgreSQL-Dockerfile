#!/bin/bash

if [ -z $POSTGRES_USERNAME ]; then
	POSTGRES_USERNAME="root"
fi

if [ -z $POSTGRES_LISTEN_ADDRESS ]; then
	POSTGRES_LISTEN_ADDRESS="0.0.0.0/0"
elif [[ ! $POSTGRES_LISTEN_ADDRESS =~ .*\/[0-9]{1,2}$ ]]; then
	POSTGRES_LISTEN_ADDRESS="$POSTGRES_LISTEN_ADDRESS/0"
fi

if [[ $POSTGRES_LISTEN_ADDRESS =~ ^0\.0\.0\.0 ]]; then
	POSTGRES_LISTEN_ADDRESSES="*"
else
	POSTGRES_LISTEN_ADDRESSES=$(echo $POSTGRES_LISTEN_ADDRESS | sed "s/\/[0-9]\{1,2\}$//g")
fi

if [ -z $POSTGRES_LISTEN_PORT ]; then
	POSTGRES_LISTEN_PORT=5432
fi

service postgresql start

POSTGRES_CONFIG_LOCATION=$(psql -qAtX -c "SHOW config_file;" postgres)
POSTGRES_HBA_LOCATION=$(psql -qAtX -c "SHOW hba_file;" postgres)
POSTGRES_VERSION=$(psql -qAtX -c "SELECT version();" |grep -Po "(?<=PostgreSQL[[:space:]])[[:digit:]]\.[[:digit:]]")

echo "Initializing role $POSTGRES_USERNAME..."

if [ -z $POSTGRES_PASSWORD ]; then
	sudo -u postgres psql -c "DO \$\$ BEGIN IF NOT EXISTS(SELECT * FROM pg_catalog.pg_user WHERE usename='$POSTGRES_USERNAME') THEN CREATE ROLE $POSTGRES_USERNAME SUPERUSER LOGIN; END IF; END \$\$;"
	echo "Initialized role $POSTGRES_USERNAME without password. Be warned: Anyone will be able to connect to this."
	#Allow connections with no auth
	connString="host all all $POSTGRES_LISTEN_ADDRESS trust"

else
	sudo -u postgres psql -c "DO \$\$ BEGIN IF NOT EXISTS(SELECT * FROM pg_catalog.pg_user WHERE usename='$POSTGRES_USERNAME') THEN CREATE ROLE $POSTGRES_USERNAME SUPERUSER LOGIN PASSWORD '$POSTGRES_PASSWORD'; END IF; END \$\$;"
	echo "Initialized role $POSTGRES_USERNAME with password."
	#Allow connections with auth
	connString="host all all $POSTGRES_LISTEN_ADDRESS md5"
fi
service postgresql stop;

echo "Setting up network addresses..."
#If our connString isn't already in there, add it in.
if !(grep "$connString" $POSTGRES_HBA_LOCATION) then
 echo $connString >> $POSTGRES_HBA_LOCATION;
fi
#Replace listen address with all everything.
sed -i "s/listen_addresses.*/listen_addresses = '$POSTGRES_LISTEN_ADDRESSES'/g" $POSTGRES_CONFIG_LOCATION
sed -i "s/#listen_addresses/listen_addresses/g" $POSTGRES_CONFIG_LOCATION
sed -Ei "s/port *= *[0-9]+/port = $POSTGRES_LISTEN_PORT/g" $POSTGRES_CONFIG_LOCATION
echo "Network addresses setup."
echo "Starting database..."
exec pg_ctlcluster $POSTGRES_VERSION main start --foreground
