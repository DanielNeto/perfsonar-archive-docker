#!/bin/bash

OPENSEARCH_CERTS_DIR=$PWD/certs

mkdir -p ${OPENSEARCH_CERTS_DIR}

# Generate Opensearch Certificates
# Root CA
openssl genrsa -out ${OPENSEARCH_CERTS_DIR}/root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key ${OPENSEARCH_CERTS_DIR}/root-ca-key.pem -subj "/O=perfSONAR/OU=Archive/CN=root" -out ${OPENSEARCH_CERTS_DIR}/root-ca.pem -days 7300
# Admin cert
openssl genrsa -out ${OPENSEARCH_CERTS_DIR}/admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ${OPENSEARCH_CERTS_DIR}/admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${OPENSEARCH_CERTS_DIR}/admin-key.pem
openssl req -new -key ${OPENSEARCH_CERTS_DIR}/admin-key.pem -subj "/O=perfSONAR/OU=Archive/CN=admin" -out ${OPENSEARCH_CERTS_DIR}/admin.csr
openssl x509 -req -in ${OPENSEARCH_CERTS_DIR}/admin.csr -CA ${OPENSEARCH_CERTS_DIR}/root-ca.pem -CAkey ${OPENSEARCH_CERTS_DIR}/root-ca-key.pem -CAcreateserial -sha256 -out ${OPENSEARCH_CERTS_DIR}/admin.pem -days 7300
# Node cert
openssl genrsa -out ${OPENSEARCH_CERTS_DIR}/node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ${OPENSEARCH_CERTS_DIR}/node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${OPENSEARCH_CERTS_DIR}/node-key.pem
openssl req -new -key ${OPENSEARCH_CERTS_DIR}/node-key.pem -subj "/O=perfSONAR/OU=Archive/CN=localhost" -out ${OPENSEARCH_CERTS_DIR}/node.csr
echo subjectAltName=DNS:localhost > ${OPENSEARCH_CERTS_DIR}/node.ext
openssl x509 -req -in ${OPENSEARCH_CERTS_DIR}/node.csr -CA ${OPENSEARCH_CERTS_DIR}/root-ca.pem -CAkey ${OPENSEARCH_CERTS_DIR}/root-ca-key.pem -CAcreateserial -sha256 -out ${OPENSEARCH_CERTS_DIR}/node.pem -days 7300 -extfile ${OPENSEARCH_CERTS_DIR}/node.ext
# Cleanup
rm -f ${OPENSEARCH_CERTS_DIR}/admin-key-temp.pem ${OPENSEARCH_CERTS_DIR}/admin.csr ${OPENSEARCH_CERTS_DIR}/node-key-temp.pem ${OPENSEARCH_CERTS_DIR}/node.csr ${OPENSEARCH_CERTS_DIR}/node.ext
# Add to Java cacerts
openssl x509 -in ${OPENSEARCH_CERTS_DIR}/root-ca.pem -inform pem -out ${OPENSEARCH_CERTS_DIR}/root-ca.der -outform der
