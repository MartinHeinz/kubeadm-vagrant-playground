sudo su -

wget -q https://github.com/k3s-io/kine/releases/download/v0.10.1/kine-amd64
install -m 755 kine-amd64 /usr/local/sbin/kine && rm kine-amd64

apt -y install postgresql postgresql-contrib
systemctl start postgresql.service

openssl req -new -nodes -text -out root.csr \
  -keyout root.key -subj "/CN=localhost"
chmod og-rwx root.key

openssl x509 -req -in root.csr -text -days 3650 \
  -extfile /etc/ssl/openssl.cnf -extensions v3_ca \
  -signkey root.key -out root.crt

openssl req -new -nodes -text -out server.csr \
  -keyout server.key -subj "/CN=localhost"
chmod og-rwx server.key

openssl x509 -req -in server.csr -text -days 365 \
  -CA root.crt -CAkey root.key -CAcreateserial \
  -out server.crt

cp {server.crt,server.key,root.crt} /var/lib/postgresql/
chown postgres.postgres /var/lib/postgresql/server.key
cp {server.crt,server.key,root.crt} /home/vagrant

sed -i -e "s|ssl_cert_file.*|ssl_cert_file = '/var/lib/postgresql/server.crt'|g" /etc/postgresql/14/main/postgresql.conf
sed -i -e "s|ssl_key_file.*|ssl_key_file = '/var/lib/postgresql/server.key'|g" /etc/postgresql/14/main/postgresql.conf
sed -i -e "s|#ssl_ca_file.*|ssl_ca_file = '/var/lib/postgresql/root.crt'|g" /etc/postgresql/14/main/postgresql.conf

# Edit /etc/postgresql/14/main/pg_hba.conf
# Change line to 'host    all             all             127.0.0.1/32            trust'

sed -i -e "s|host    all             all             127.0.0.1/32            scram-sha-256|host    all             all             127.0.0.1/32            trust|g" /etc/postgresql/14/main/pg_hba.conf
systemctl restart postgresql.service
psql -U postgres -p 5432 -h 127.0.0.1 -c "ALTER ROLE postgres WITH PASSWORD 'somepass';"
sed -i -e "s|host    all             all             127.0.0.1/32            trust|host    all             all             127.0.0.1/32            scram-sha-256|g" /etc/postgresql/14/main/pg_hba.conf

systemctl restart postgresql.service

# https://github.com/k3s-io/kine/issues/76
kine --endpoint "postgres://postgres:somepass@tcp(localhost:5432)/postgres" --ca-file root.crt --cert-file server.crt --key-file server.key

# TODO kubeadm