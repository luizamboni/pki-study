#!/bin/bash

rm -rf pki/*

# generate a root privatekey
openssl genrsa -out pki/exerciciosresolvidos.net.key 2048

# (optional) example of howt extract publicKey from privateKey (only for curiosity, without use here)
# openssl rsa -in pki/exerciciosresolvidos.net.key -pubout -out pki/exerciciosresolvidos.public.net.key

# genreate a Certificate Sign Request 
openssl req -new -key pki/exerciciosresolvidos.net.key -out pki/exerciciosresolvidos.net.csr


# (optional) verify the data in CSR
# openssl req -text -in pki/exerciciosresolvidos.net.csr -noout -verify

# generate a certificate sign by privateKey
openssl x509 -req -days 365 -in pki/exerciciosresolvidos.net.csr -signkey pki/exerciciosresolvidos.net.key -out pki/exerciciosresolvidos.net.crt
