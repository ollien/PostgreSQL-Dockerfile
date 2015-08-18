#!/bin/bash
echo "Initializing roles..."
service postgresql start
sudo -u postgres psql -c "DO \$\$ BEGIN IF NOT EXISTS(SELECT * FROM pg_catalog.pg_user WHERE usename='root') THEN CREATE ROLE root SUPERUSER LOGIN; END IF; END \$\$;"
service postgresql stop
echo "Roles Initialized."
echo "Setting up network addresses..."
connString="host all all 0.0.0.0/0 trust" 
if  !(grep "$connString" /etc/postgresql/9.4/main/pg_hba.conf) then
 echo $connString >> /etc/postgresql/9.4/main/pg_hba.conf;
fi
sed -i "s/listen_addresses.*/listen_addresses='*'/g" /etc/postgresql/9.4/main/postgresql.conf
sed -i "s/#listen_addresses=/listen_addresses=/g" /etc/postgresql/9.4/main/postgresql.conf
echo "Network addresses setup."
echo "Laying the trap..."
trap "echo 'Exiting World!'" TERM
echo "Starting database..."
exec sudo -u postgres /usr/lib/postgresql/9.4/bin/postgres --config-file=/etc/postgresql/9.4/main/postgresql.conf
