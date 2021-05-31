COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
COMPOSE_FILE_BASE=docker/docker-compose-voternet-net.yaml
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml

function networkDown() {
  # stop org3 containers also in addition to org1 and org2, in case we were running sample to add org3
  docker-compose -f $COMPOSE_FILE_BASE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_CA  down --volumes --remove-orphans
  rm -rf ./organizations/fabric-ca/investorOrg/ca
  rm -rf ./organizations/fabric-ca/investorOrg/msp
  rm -rf ./organizations/fabric-ca/investorOrg/peers
  rm -rf ./organizations/fabric-ca/investorOrg/tlsca
  rm -rf ./organizations/fabric-ca/investorOrg/users
  rm  ./organizations/fabric-ca/investorOrg/ca-cert.pem
  rm  ./organizations/fabric-ca/investorOrg/fabric-ca-server.db
  rm  ./organizations/fabric-ca/investorOrg/IssuerPublicKey
  rm  ./organizations/fabric-ca/investorOrg/IssuerRevocationPublicKey
  rm  ./organizations/fabric-ca/investorOrg/tls-cert.pem
  
  
   rm -rf ./organizations/fabric-ca/managementOrg/ca
  rm -rf ./organizations/fabric-ca/managementOrg/msp
  rm -rf ./organizations/fabric-ca/managementOrg/peers
  rm -rf ./organizations/fabric-ca/managementOrg/tlsca
  rm -rf ./organizations/fabric-ca/managementOrg/users
  rm  ./organizations/fabric-ca/managementOrg/ca-cert.pem
  rm  ./organizations/fabric-ca/managementOrg/fabric-ca-server.db
  rm  ./organizations/fabric-ca/managementOrg/IssuerPublicKey
  rm  ./organizations/fabric-ca/managementOrg/IssuerRevocationPublicKey
  rm  ./organizations/fabric-ca/managementOrg/tls-cert.pem

  rm  -rf ./organizations/fabric-ca/ordererOrg



#  docker-compose -f $COMPOSE_FILE_COUCH_ORG3 -f $COMPOSE_FILE_ORG3 down --volumes --remove-orphans
  # Don't remove the generated artifacts -- note, the ledgers are always removed
    # Bring down the network, deleting the volumes
    #Cleanup the chaincode containers
#  infoln "Removing remaining containers"
#  docker rm -f $(docker ps -aq --filter label=service=hyperledger-fabric) 2>/dev/null || true
#  docker rm -f $(docker ps -aq --filter name='dev-peer*') 2>/dev/null || true

  #Cleanup images
#  removeUnwantedImages
#  # remove orderer block and other channel configuration transactions and certs
#  docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf system-genesis-block/*.block organizations/peerOrganizations organizations/ordererOrganizations'
#  ## remove fabric ca artifacts
#  docker run --rm -v "$(pwd):/data" busybox sh -c 'rm -rf /etc/hyperledger/fabric-ca-server/msp /etc/hyperledger/fabric-ca-server/tls-cert.pem /etc/hyperledger/fabric-ca-server/ca-cert.pem /etc/hyperledger/fabric-ca-server/IssuerPublicKey /etc/hyperledger/fabric-ca-server/IssuerRevocationPublicKey /etc/hyperledger/fabric-ca-server/fabric-ca-server.db'
#  docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/org2/msp organizations/fabric-ca/org2/tls-cert.pem organizations/fabric-ca/org2/ca-cert.pem organizations/fabric-ca/org2/IssuerPublicKey organizations/fabric-ca/org2/IssuerRevocationPublicKey organizations/fabric-ca/org2/fabric-ca-server.db'
#  docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/ordererOrg/msp organizations/fabric-ca/ordererOrg/tls-cert.pem organizations/fabric-ca/ordererOrg/ca-cert.pem organizations/fabric-ca/ordererOrg/IssuerPublicKey organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey organizations/fabric-ca/ordererOrg/fabric-ca-server.db'
#  docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf addOrg3/fabric-ca/org3/msp addOrg3/fabric-ca/org3/tls-cert.pem addOrg3/fabric-ca/org3/ca-cert.pem addOrg3/fabric-ca/org3/IssuerPublicKey addOrg3/fabric-ca/org3/IssuerRevocationPublicKey addOrg3/fabric-ca/org3/fabric-ca-server.db'
#  # remove channel and script artifacts
#  docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf channel-artifacts log.txt *.tar.gz'
}
# infoln echos in blue color
function infoln() {
  echo -e "${C_BLUE}${1}${C_RESET}"
}

networkDown