#!/bin/bash

rm -rf ./certs/*

# generate a root privatekey
openssl genrsa -out ./certs/exerciciosresolvidos.key 2048

# (optional) example of howt extract publicKey from privateKey (only for curiosity, without use here)
# openssl rsa -in ../certs/exerciciosresolvidos.key -pubout -out ../certs/exerciciosresolvidos.key

# genreate a Certificate Sign Request 
openssl req -new -key ./certs/exerciciosresolvidos.key \
                -subj "/C=BR/ST=Rio de Janeiro/L=Rio de Janeiro/O=Zamba/OU=Zamba TI/CN=localhost" \
                -out ./certs/exerciciosresolvidos.csr


# (optional) verify the data in CSR
# openssl req -text -in ../certs/exerciciosresolvidos.csr -noout -verify

# generate a certificate sign by privateKey
openssl x509 -req -days 365 -in ./certs/exerciciosresolvidos.csr -signkey ./certs/exerciciosresolvidos.key -out ./certs/exerciciosresolvidos.crt
