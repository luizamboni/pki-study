#!/bin/bash

rm -rf ./certs/*
mkdir -p ./certs/ca ./certs/intermediate ./certs/certificates

cat > ca-cert.json <<EOF 
{
    "CN": "Zamba CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
          "C": "BR",
          "L": "Rio de Janeiro",
          "O": "Zamba TI",
          "ST": "Rio de Janeiro"
        }
    ]
}
EOF

# generate a new key and signed certificate
printf "\ngenerate root CA:\n"
cfssl gencert -initca ca-cert.json | cfssljson -bare ./certs/ca/ca


cat > intermediate-cert.json <<EOF 
{
    "CN": "Zamba Ops Intermediate",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
          "C": "BR",
          "L": "Rio de Janeiro",
          "O": "Zamba TI",
          "ST": "Rio de Janeiro"
        }
    ]
}
EOF

cat > intermediate-sr.json <<EOF 
{
  "signing": {
    "profiles": {
      "cluster": {
        "expiry": "43800h",
        "usages": [
          "signing",
          "key encipherment",
          "cert sign",
          "crl sign",
          "server auth",
          "client auth"
        ],
        "ca_constraint": {
          "is_ca": true
        }
      }
    }
  }
}
EOF


printf "\ngenerate intermediate CA:\n"
# generete other pair of private/public keys, now for intermediate
cfssl genkey -initca -loglevel=0 intermediate-cert.json | cfssljson -bare ./certs/intermediate/cluster

printf "\nsign intermediate certificate\n"
# sign the csr of intermediate certs with CA certs
cfssl sign -ca ./certs/ca/ca.pem -ca-key ./certs/ca/ca-key.pem \
       --config intermediate-sr.json \
       -profile cluster \
       ./certs/intermediate/cluster.csr \
      | cfssljson -bare ./certs/intermediate/cluster 


cat > certificates-sr.json <<EOF
{
  "signing": {
    "default": {
        "expiry": "43800h"
    },
    "profiles": {
      "server": {
        "expiry": "43800h",
        "usages": [
          "signing",
          "digital signing",
          "key encipherment",
          "server auth"
        ]
      },
      "peer": {
        "expiry": "43800h",
        "usages": [
          "signing",
          "digital signature",
          "key encipherment", 
          "client auth",
          "server auth"
        ]
      },
      "client": {
        "expiry": "43800h",
        "usages": [
          "signing",
          "digital signature",
          "key encipherment", 
          "client auth"
        ]
      }
    }
  }
}
EOF

cat > client-cert.json <<EOF 
{
  "CN": "Client",
  "hosts": [
    "127.0.0.1",
    "localhost"
  ]
}
EOF

cat > server-cert.json <<EOF 
{
  "CN": "Server",
  "hosts": [
    "127.0.0.1",
    "localhost"
  ]
}
EOF

cat > peer-cert.json <<EOF 
{
  "CN": "Peer",
  "hosts": [
    "127.0.0.1",
    "localhost"
  ]
}
EOF

printf "\ngenerate Peer cert and sign: \n"
cfssl gencert -ca=./certs/intermediate/cluster.pem \
              -ca-key=./certs/intermediate/cluster-key.pem \
              -config=certificates-sr.json \
              -profile=peer \
              -loglevel=0 \
              peer-cert.json \
              | cfssljson -bare ./certs/certificates/peer

printf "\ngenerate Client cert and sign: \n"
cfssl gencert -ca=./certs/intermediate/cluster.pem \
              -ca-key=./certs/intermediate/cluster-key.pem \
              -config=certificates-sr.json \
              -profile=client \
              -loglevel=0 \
              client-cert.json \
              | cfssljson -bare ./certs/certificates/client

printf '\ngenerate Server cert and sign: \n'
cfssl gencert -ca=./certs/intermediate/cluster.pem \
              -ca-key=./certs/intermediate/cluster-key.pem \
              -config=certificates-sr.json \
              -profile=server \
              -loglevel=0 \
              server-cert.json \
              | cfssljson -bare ./certs/certificates/server

# bundle all certs in a bundle file
# its need be ordered by the root to more specific
# cat ./certs/certificates/peer.pem ./certs/intermediate/cluster.pem  ./certs/ca/ca.pem  > ./certs/bundle.pem
cat ./certs/intermediate/cluster.pem  ./certs/ca/ca.pem  > ./certs/bundle.pem

# clean config json files
rm *.json