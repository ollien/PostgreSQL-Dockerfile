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

echo "Initializing role $POSTGRES_USERNAME..."

service postgresql start
if [ -z $POSTGRES_PASSWORD ]; then
	sudo -u postgres psql -c "DO \$\$ BEGIN IF NOT EXISTS(SELECT * FROM pg_catalog.pg_user WHERE usename='$POSTGRES_USERNAME') THEN CREATE ROLE root SUPERUSER LOGIN; END IF; END \$\$;"
	echo "Initialisd role $POSTGRES_USERNAME without passoword. Be warned: Anyone will be able to connect to this."
	#Allow connections with no auth
	connString="host all all $POSTGRES_LISTEN_ADDRESS trust" 

else
	sudo -u postgres psql -c "DO \$\$ BEGIN IF NOT EXISTS(SELECT * FROM pg_catalog.pg_user WHERE usename='$POSTGRES_USERNAME') THEN CREATE ROLE root SUPERUSER LOGIN PASSWORD '$POSTGRES_PASSWORD'; END IF; END \$\$;"
	echo "Initialized role $POSTGRES_USERNAME with password."
	#Allow connections with auth
	connString="host all all $POSTGRES_LISTEN_ADDRESS md5" 
fi
service postgresql stop;

echo "Setting up network addresses..."
#If our connString isn't already in there, add it in. 
if !(grep "$connString" /etc/postgresql/9.4/main/pg_hba.conf) then
 echo $connString >> /etc/postgresql/9.4/main/pg_hba.conf;
fi
#Replace listen address with all everything.
sed -i "s/listen_addresses.*/listen_addresses='$POSTGRES_LISTEN_ADDRESSES'/g" /etc/postgresql/9.4/main/postgresql.conf
sed -i "s/#listen_addresses=/listen_addresses=/g" /etc/postgresql/9.4/main/postgresql.conf
echo "Network addresses setup."
echo "Starting database..."
cat /etc/postgresql/9.4/main/pg_hba.conf
exec sudo -u postgres /usr/lib/postgresql/9.4/bin/postgres --config-file=/etc/postgresql/9.4/main/postgresql.conf