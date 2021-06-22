COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
COMPOSE_FILE_BASE=docker/docker-compose-voternet-net.yaml
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml

function networkDown() {
  docker-compose -f $COMPOSE_FILE_BASE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_CA  down --volumes --remove-orphans
  docker system prune --volumes -f

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
  rm  -rf ../wallet
}
# infoln echos in blue color
function infoln() {
  echo -e "${C_BLUE}${1}${C_RESET}"
}

networkDown