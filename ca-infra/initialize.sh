# https://jamielinux.com/docs/openssl-certificate-authority/index.html

if [ -e root/certs/root.crt ]
  then
    echo "Skipping bootstrap of CA, already exists"

  else

    echo "=== Generating root CA ==="
    mkdir root
    cp openssl-ca.cnf.root root/openssl-ca.cnf
    cd root
    mkdir certs crl newcerts private
    chmod 700 private
    touch index.txt
    echo 1000 > serial
    openssl genrsa -out private/root.key 1024
    chmod 400 private/root.key
    openssl req -config openssl-ca.cnf -new -x509 -days 365 -extensions v3_ca -key private/root.key -out certs/root.crt -subj "/C=US/ST=Washington/L=Seattle/O=Global Security/OU=Stackato Cloud/CN=Stackato Cloud Root CA"
    cd ..

    echo "=== Generating intermediate CA ==="
    mkdir intermediate
    cp openssl-ca.cnf.intermediate intermediate/openssl-ca.cnf
    cd intermediate
    mkdir certs crl csr newcerts private
    chmod 700 private
    touch index.txt
    echo 1000 > serial
    echo 1000 > crlnumber

    openssl genrsa -out private/intermediate.key 1024
    openssl req -config openssl-ca.cnf -new -sha256 -key private/intermediate.key -out csr/intermediate.csr -subj "/C=US/ST=Washington/L=Seattle/O=Global Security/OU=Stackato Cloud/CN=Stackato Cloud Intermediate CA"
    cd ../root
    openssl ca -batch -config openssl-ca.cnf -extensions v3_intermediate_ca -days 365 -notext -md sha256 -in ../intermediate/csr/intermediate.csr -out ../intermediate/certs/intermediate.crt
    chmod  444 ../intermediate/certs/intermediate.crt
    cd ..

    echo "=== Creating certificate chain ==="
    cat intermediate/certs/intermediate.crt root/certs/root.crt > intermediate/certs/chain.crt
    chmod 444 intermediate/certs/chain.crt

    echo "=== Creating server certificate ==="
    cd intermediate
    openssl genrsa -out private/server.key 1024
    chmod 400 private/server.key
    openssl req -new -sha256 -key private/server.key -out csr/server.csr -subj "/C=US/ST=Washington/L=Seattle/O=Global Security/OU=Stackato Cloud/CN=192.168.55.133.nip.io"
    openssl ca -batch -config openssl-ca.cnf -extensions server_cert -days 365 -notext -md sha256 -in csr/server.csr -out certs/server.crt
    chmod 444 certs/server.crt
    cd ..

    echo "=== Creating client certificate ==="
    cd intermediate
    openssl genrsa -out private/client1.key 1024
    chmod 400 private/client1.key
    openssl req -new -sha256 -key private/client1.key -out csr/client1.csr -subj "/C=US/ST=Washington/L=Seattle/O=Global Security/OU=Stackato Cloud/CN=client1"
    openssl ca -batch -config openssl-ca.cnf -extensions usr_cert -days 365 -notext -md sha256 -in csr/client1.csr -out certs/client1.crt
    chmod 444 certs/client1.crt
    cd ..


    echo "=== Copying needed certs & keys into ca-dist ==="
    rm -rf ../ca-dist
    mkdir ../ca-dist
    cp intermediate/certs/server.crt ../ca-dist
    cp intermediate/certs/client1.crt ../ca-dist
    cp intermediate/private/server.key ../ca-dist
    cp intermediate/private/client1.key ../ca-dist
    cp intermediate/certs/chain.crt ../ca-dist

  fi
