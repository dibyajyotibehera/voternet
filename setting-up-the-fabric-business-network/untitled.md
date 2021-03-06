# Step 3 - Bring up peer nodes

## Till now ..

* We have created the docker network with fabric-ca container
* Registered and enrolled the peers and users needed for the app

## Next ..

* We are actually going to create the peer nodes for each org in fabric network

```text
COMPOSE_FILE_BASE=docker/docker-compose-voternet-net.yaml
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml
COMPOSE_FILES="-f ${COMPOSE_FILE_BASE} -f ${COMPOSE_FILE_COUCH}"

docker-compose ${COMPOSE_FILES} up -d 2>&1
```

* the first docker compose file here brings up 3 container based on  hyperledger/fabric-peer container.Pay special attention to the environment variables and volumes. This is how the crypto material generated in Step 2 is accessible to fabric peers while transaction processing

  ```text
  volumes:
      - ../organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/msp:/etc/hyperledger/fabric/msp
      - ../organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls:/etc/hyperledger/fabric/tls
  ```

   

* the second docker file is used to bring up couch dbs which will act as the datastore for world state of the ledger. Since ledger is stored only for the peers we have 2 couch dbs each for the 2 peer nodes \(of investorOrg and managementOrg\) and is not needed by the ordering service



