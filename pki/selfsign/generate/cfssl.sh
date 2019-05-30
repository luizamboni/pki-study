#!/bin/bash

# clean pki folder
rm -rf ../certs/*


# generate config 
cat > ../certs/config.json <<EOF
{
   "hosts": [
      "localhost",
      "www.example.com"
   ],
   "CN": "localhost",
   "key": {
      "algo": "rsa",
      "size": 2048
   },
   "names": [
      {
         "C": "BR",
         "L": "Rio de Janeiro",
         "O": "zamba",
         "OU": "exerciciosresolvidos site 1"
      }
   ],
   "ca": {
      "expiry": "262800h"
   }
}
EOF

# (optional) see config for root
cat ../certs/config.json


# gen 3 files
# 1 exerciciosresolvidos-key.pem (the privateKey of root certificate)
# 2 exerciciosresolvidos.csr     (the certificate sign request)
# 3 exerciciosresolvidos.pem     (the root certificat)
# cfssl selfsign localhost ../certs/config.json | cfssljson -bare ../certs/exerciciosresolvidos
cfssl selfsign localhost ../certs/config.json | cfssljson -bare ../certs/exerciciosresolvidos
