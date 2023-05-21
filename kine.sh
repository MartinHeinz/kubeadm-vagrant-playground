#!/bin/bash
kine --endpoint "postgres://postgres:somepass@localhost:5432/postgres" --ca-file /home/vagrant/ca.crt --cert-file /home/vagrant/server.crt --key-file /home/vagrant/server.key