# Neo4j reverse proxy service for docker
Using nginx for docker as a reverse proxy for the neo4j bolt protocol

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
    <(printf '[SAN]\nsubjectAltName=DNS.1:haklof.corp,DNS.2:database.haklof.corp,IP:127.0.0.1')) \
-sha256 \
-days 3650
```

### 2. nginx config (default.conf)
Set your private connecion uri 4d741a64.production-orch-0477.neo4j.io 

### 3. Build the docker image
REMARK: dist.tgz (neo4j workspace dist) is not yet available to the public
```sh
docker build -t aura-proxy:v1 ./
```

### 4. Launch a docker container
```sh
docker run --rm --name aura-proxy -d -v ./default.conf:/etc/nginx/nginx.conf -p 443:443 aura-proxy:v1
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
- [ ] Tidy up docker related stuff that may pose scrutity risks  
- [ ] nginx best practices and performance
- [ ] Make config esier, i.e. pass arguements for PORT, CERTS and AURA_PRIVATE_URI
