sudo su -

wget -q https://github.com/k3s-io/kine/releases/download/v0.10.1/kine-amd64
install -m 755 kine-amd64 /usr/local/sbin/kine && rm kine-amd64

apt -y install postgresql postgresql-contrib
systemctl start postgresql.service

# Generate self signed root CA cert
openssl req -addext "subjectAltName = DNS:localhost" -nodes -x509 -newkey rsa:2048 -keyout ca.key -out ca.crt -subj "/CN=localhost"

# Generate server cert to be signed
openssl req -addext "subjectAltName = DNS:localhost" -nodes -newkey rsa:2048 -keyout server.key -out server.csr -subj "/CN=localhost"

# Sign the server cert
openssl x509 -extfile <(printf "subjectAltName=DNS:localhost") -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

chmod og-rwx ca.key
chmod og-rwx server.key

cp {server.crt,server.key,ca.crt} /var/lib/postgresql/
chown postgres.postgres /var/lib/postgresql/server.key
cp {server.crt,server.key,ca.crt} /home/vagrant

sed -i -e "s|ssl_cert_file.*|ssl_cert_file = '/var/lib/postgresql/server.crt'|g" /etc/postgresql/14/main/postgresql.conf
sed -i -e "s|ssl_key_file.*|ssl_key_file = '/var/lib/postgresql/server.key'|g" /etc/postgresql/14/main/postgresql.conf
sed -i -e "s|#ssl_ca_file.*|ssl_ca_file = '/var/lib/postgresql/ca.crt'|g" /etc/postgresql/14/main/postgresql.conf

# Edit /etc/postgresql/14/main/pg_hba.conf
# Change line to 'host    all             all             127.0.0.1/32            trust'

sed -i -e "s|host    all             all             127.0.0.1/32            scram-sha-256|host    all             all             127.0.0.1/32            trust|g" /etc/postgresql/14/main/pg_hba.conf
systemctl restart postgresql.service
psql -U postgres -p 5432 -h 127.0.0.1 -c "ALTER ROLE postgres WITH PASSWORD 'somepass';"
sed -i -e "s|host    all             all             127.0.0.1/32            trust|host    all             all             127.0.0.1/32            scram-sha-256|g" /etc/postgresql/14/main/pg_hba.conf

systemctl restart postgresql.service

# https://github.com/k3s-io/kine/issues/76
kine --endpoint "postgres://postgres:somepass@localhost:5432/postgres" --ca-file ca.crt --cert-file server.crt --key-file server.key

# TODO kubeadm