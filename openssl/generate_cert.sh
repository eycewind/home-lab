#!/bin/sh
CA_KEY="/app/data/ca-key.pem"
CA_CERT="/app/data/ca.pem"

# Update as per requirements
CERT_KEY="/app/data/cert-key-dns.pem"
CERT_CSR="/app/data/cert-dns.csr"
CERT_FINAL="/app/data/cert-dns.pem"
SUBJECT_ALT_NAME="DNS:naio.bas.it,IP:10.0.0.5"
PASSPHRASE="abcdef"

if [ ! -f $CA_KEY ] ; then
  openssl genrsa -aes256 -passout pass:$PASSPHRASE -out $CA_KEY 4096
fi

if [ ! -f $CA_CERT ]; then
  openssl req \
    -new \
    -key $CA_KEY \
    -x509 \
    -days 3650 \
    -out $CA_CERT \
    -subj "/C=PK/ST=ICT/L=Islamabad/O=HASHA/CN=bas.it" \
    -passin pass:$PASSPHRASE
fi

openssl genrsa -passout pass:$PASSPHRASE -out $CERT_KEY 4096
openssl req -new -sha256 -subj '/CN=bas.it' -key $CERT_KEY -passout pass:$PASSPHRASE -out $CERT_CSR
echo "subjectAltName=$SUBJECT_ALT_NAME" > /app/data/extfile.cnf
# openssl x509 -req -sha256 -days 365 -in $CERT_CSR -CA $CA_CERT -CAkey $CA_KEY -out $CERT_FINAL -extfile data/extfile.cnf -CAcreateserial
TMP_CA_KEY=$(mktemp)
openssl rsa -passin pass:$PASSPHRASE -in $CA_KEY -out $TMP_CA_KEY
openssl x509 -req -sha256 -days 365 -in $CERT_CSR -CA $CA_CERT -CAkey $TMP_CA_KEY -out $CERT_FINAL -extfile /app/data/extfile.cnf -CAcreateserial

rm $TMP_CA_KEY