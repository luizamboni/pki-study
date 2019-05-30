#!/bin/bash

rm -rf ../certs/*
mkdir -p ../certs/ca ../certs/intermediate ../certs/certificates

cat > ca-sr.json <<EOF 
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

cat > intermediate-ca.json <<EOF 
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

cfssl gencert -initca ca-sr.json | cfssljson -bare ../certs/ca/ca



cat > intermediate.json <<EOF 
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



# generete other pair of private/public keys, now for intermediate
cfssl genkey -initca intermediate-ca.json | cfssljson -bare ../certs/intermediate/cluster

# sign the csr of intermediate certs with CA certs
cfssl sign -ca ../certs/ca/ca.pem -ca-key ../certs/ca/ca-key.pem \
       --config intermediate.json -profile cluster ../certs/intermediate/cluster.csr \
      | cfssljson -bare ../certs/intermediate/cluster 


cat > certificates.json <<EOF
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

cat > peer.json <<EOF 
{
  "CN": "Peer",
  "hosts": [
    "127.0.0.1",
    "localhost"
  ]
}
EOF


cfssl gencert -ca=../certs/intermediate/cluster.pem \
              -ca-key=../certs/intermediate/cluster-key.pem \
              -config=certificates.json -profile=peer peer.json \
              | cfssljson -bare ../certs/certificates/peer


# bundle all certs in a bundle file
# its need be ordered by the root to more specific
# cat ../certs/certificates/peer.pem ../certs/intermediate/cluster.pem  ../certs/ca/ca.pem  > ../certs/bundle.pem
cat ../certs/intermediate/cluster.pem  ../certs/ca/ca.pem  > ../certs/bundle.pem

# clean config json files
rm *.json