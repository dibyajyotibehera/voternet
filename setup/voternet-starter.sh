#!/bin/bash
function _exit() {
  printf "Exiting:%s\n" "$1"
  exit -1
}

## Exit on first error, print all commands.
#set -ev
#set -o pipefail
export FABRIC_CFG_PATH=$PWD

COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
COMPOSE_FILE_BASE=docker/docker-compose-voternet-net.yaml
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml


function networkUp() {
  #  checkPrereqs
  #  # generate artifacts if they don't exist
  #  if [ ! -d "organizations/peerOrganizations" ]; then
  #    createOrgs
  #  fi
  ####docker compose up ca files
  infoln "Generating certificates using Fabric CA"
  docker-compose -f $COMPOSE_FILE_CA up -d 2>&1

  infoln "Installing fabric-ca-client"
  go get github.com/hyperledger/fabric-ca/cmd/...

  . organizations/fabric-ca/registerEnroll.sh

  infoln "Creating InvestorOrg Identities"
  createInvestorOrg

  infoln "Creating ManagementOrg Identities"
  createManagementOrg

  infoln "Creating Orderer Org Identities"
  createOrderer

  COMPOSE_FILES="-f ${COMPOSE_FILE_BASE} -f ${COMPOSE_FILE_COUCH}"

  docker-compose ${COMPOSE_FILES} up -d 2>&1

  docker ps -a
  if [ $? -ne 0 ]; then
    fatalln "Unable to start network"
  fi
}

# infoln echos in blue color
function infoln() {
  echo -e "${C_BLUE}${1}${C_RESET}"
}

networkUp
