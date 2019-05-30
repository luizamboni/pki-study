#!/bin/bash

rm -rf ../certs/*

# generate a root privatekey
openssl genrsa -out ../certs/exerciciosresolvidos.net.key 2048

# (optional) example of howt extract publicKey from privateKey (only for curiosity, without use here)
# openssl rsa -in ../certs/exerciciosresolvidos.net.key -pubout -out ../certs/exerciciosresolvidos.public.net.key

# genreate a Certificate Sign Request 
openssl req -new -key ../certs/exerciciosresolvidos.net.key -out ../certs/exerciciosresolvidos.net.csr


# (optional) verify the data in CSR
# openssl req -text -in ../certs/exerciciosresolvidos.net.csr -noout -verify

# generate a certificate sign by privateKey
openssl x509 -req -days 365 -in ../certs/exerciciosresolvidos.net.csr -signkey ../certs/exerciciosresolvidos.net.key -out ../certs/exerciciosresolvidos.net.crt
