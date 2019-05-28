#!/bin/bash

rm -rf pki/*
cat > ./pki/config.json <<EOF
{
 "CN": "localhost",
 "key": {
    "algo": "ecdsa",
    "size": 256
 },
 "names": [
 {
    "C": "BR",
    "L": "Rio de Janeiro",
    "O": "zamba",
    "OU": "exerciciosresolvidos site"
 }
 ],
 "ca": {
    "expiry": "262800h"
 }
}
EOF

cat ./pki/config.json


cfssl selfsign localhost ./pki/config.json | cfssljson -bare ./pki/exerciciosresolvidos
