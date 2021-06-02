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
CHANNEL_NAME="votingchannel"
DELAY="3"
MAX_RETRY="5"
VERBOSE="false"

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

function configureChannel() {
  set -x
  FABRIC_CFG_PATH=${PWD}/config
  BLOCKFILE="../channel-artifacts/${CHANNEL_NAME}.block"

  infoln "Downloading configtxgen"
  VERSION=2.3.2
  ARCH=$(echo "$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')")
  BINARY_FILE=hyperledger-fabric-${ARCH}-${VERSION}.tar.gz
  if [ -d bin ]; then
     infoln "binaries already downloaded" && cd bin
  else
    download "${BINARY_FILE}" "https://github.com/hyperledger/fabric/releases/download/v${VERSION}/${BINARY_FILE}"  && cd bin
  fi

  infoln "Generating channel genesis block '${CHANNEL_NAME}.block'"
  createChannelGenesisBlock

  infoln "Creating channel ${CHANNEL_NAME}"
  createChannel
  infoln "Channel '$CHANNEL_NAME' created"
  set +x
}

# This will download the .tar.gz
download() {
  local BINARY_FILE=$1
  local URL=$2
  echo "===> Downloading: " "${URL}"
  curl -L --retry 5 --retry-delay 3 "${URL}" | tar xz || rc=$?
  if [ -n "$rc" ]; then
    echo "==> There was an error downloading the binary file."
    return 22
  else
    echo "==> Done."
  fi
}

createChannelGenesisBlock() {
	set -x
	./configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ${BLOCKFILE} -channelID $CHANNEL_NAME
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
	local ORDERER_CA=../organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
	local ORDERER_ADMIN_TLS_SIGN_CERT=../organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/server.crt
	local ORDERER_ADMIN_TLS_PRIVATE_KEY=../organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/server.key


	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		./osnadmin channel join --channelID $CHANNEL_NAME --config-block ${BLOCKFILE} -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
      infoln "Channel '$CHANNEL_NAME' creation failed"
      exit 1
  fi
}
networkUp
configureChannel
