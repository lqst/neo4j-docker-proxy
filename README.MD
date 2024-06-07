# Neo4j reverse proxy service for docker
Using envoy for docker as a reverse proxy for the neo4j bolt protocol

Pre-requesites: Aura Enterprise with Private Link Enabled
Why: This allows you to use your own ssl cert and domain name for the aura database

## How to

### 1. Cert
Add or generate your ssl cert

```sh
openssl req \
-newkey rsa:2048 \
-x509 \
-nodes \
-keyout server.key \
-new \
-out server.crt \
-subj /CN=haklof.corp \
-reqexts SAN \
-extensions SAN \
-config <(cat /etc/ssl/openssl.cnf \
    <(printf '[SAN]\nsubjectAltName=DNS:haklof.corp,IP:127.0.0.1')) \
-sha256 \
-days 3650
```

### 2. Envoy config
Modify the 4d741a64.production-orch-0477.neo4j.io value in envoy.yaml (2 places)
(this should have the value of Private URI for the Aura Database Instance)

```yaml
  clusters:
  - name: tcp_backend_service
    connect_timeout: 5s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: tcp_backend_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 4d741a64.production-orch-0477.neo4j.io
                port_value: 7687
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: 4d741a64.production-orch-0477.neo4j.io
```

### 3. Build the docker image

```sh
docker build -t proxy:v1 .
```

### 4. Launch a docker container

```sh
docker run --rm --name proxy -d -p 443:443 proxy:v1
```

### 5. Test
Test that you cann connect to the database
```sh
./bin/cypher-shell -a neo4j+ssc://haklof.corp:443  -d neo4j -u neo4j -p <password>
```


## Tips and tricks
- You may want to test, step by step with nc to check that you pass each layer
- dnsmasq is your friend for testing / resolving the fake domain (in this example haklof.corp)



# Todo
- [ ] Tidy up docker related stuff that may pose scrutity risks (like what user is running the service - https://www.envoyproxy.io/docs/envoy/latest/start/docker). 
- [ ] Add a lauch script in the container so no editig of the envoy.yaml yaml file is need. I.e. pass more arguements for PORT, CERTS and AURA_PRIVATE_URI