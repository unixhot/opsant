#!/bin/sh

# create self-signed server certificate:

# read -p "Enter your domain [www.example.com]: " DOMAIN_NAME
#Config 
source ./install.config

# create dir for ssl
if [ ! -d ./conf/nginx-conf.d/ssl ];then
  mkdir -p ./conf/nginx-conf.d/ssl 
fi 

cp ./conf/openssl.cnf ./conf/nginx-conf.d/ssl/
cd ./conf/nginx-conf.d/ssl

echo "Create server key..."

openssl genrsa -des3 -passout pass:opsany -out $DOMAIN_NAME.key 2048 >/dev/null 2>&1

echo "Create server certificate signing request..."

SUBJECT="/C=CN/ST=BeiJing/L=BeiJing/O=BeiJing/OU=OpsAny/CN=OpsAny"

openssl req -new -passin pass:opsany -subj $SUBJECT -key $DOMAIN_NAME.key -out $DOMAIN_NAME.csr >/dev/null 2>&1

echo "Remove password..."

mv $DOMAIN_NAME.key $DOMAIN_NAME.origin.key
openssl rsa -passin pass:opsany -in $DOMAIN_NAME.origin.key  -out $DOMAIN_NAME.key >/dev/null 2>&1

echo "Sign SSL certificate..."

openssl x509 -req -days 3650 -extfile openssl.cnf -extensions 'v3_req'  -in $DOMAIN_NAME.csr -signkey $DOMAIN_NAME.key -out $DOMAIN_NAME.crt >/dev/null 2>&1

openssl x509 -in ${DOMAIN_NAME}.crt -out ${DOMAIN_NAME}.pem -outform PEM >/dev/null 2>&1

mv ${DOMAIN_NAME}.pem ${DOMAIN_NAME}.origin.pem

cat ${DOMAIN_NAME}.key ${DOMAIN_NAME}.origin.pem > ${DOMAIN_NAME}.pem

rm -f ./conf/openssl.cnf
