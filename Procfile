web: gunicorn httpbin:app -w 6 -b $VCAP_APP_HOST:$STACKATO_HARBOR --certfile=$HOME/ca-dist/server.crt --keyfile=$HOME/ca-dist/server.key --ca-certs=$HOME/ca-dist/chain.crt --cert-reqs 2 --log-file -
