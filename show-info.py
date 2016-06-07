#!/usr/bin/env python

import json
import os
import pprint

ss = json.loads(os.environ['STACKATO_SERVICES'])
host = ss['httpbin-port']['hostname']
port = ss['httpbin-port']['port']

print("*"*20)
if not os.path.isdir('ca-dist'):
    print("** WARNING - ca-dist doesn't appear to exist, did you initialize the CA?\n") 
print("httpbin will be available via Harbor on {0}:{1}\n".format(host, port))
print("Example of connecting using curl when service does not have TLS enabled:")
print("  $ curl http://{0}.nip.io:{1}/get?foo=bar\n".format(host, port))
print("Example of connecting using curl when service has TLS enabled:")
print("  $ curl --cacert ca-dist/chain.crt https://{0}.nip.io:{1}/get?foo=bar\n".format(host, port))
print("Example of connecting using curl when service has TLS enabled, & presenting a client certificate:")
print("  $ curl --cacert ca-dist/chain.crt https://{0}.nip.io:{1}/get?foo=bar --cert ca-dist/client1.crt --key ca-dist/client1.key\n".format(host, port))
print("*"*20)
