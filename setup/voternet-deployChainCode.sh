#!/bin/bash

export FABRIC_CFG_PATH=$PWD/config/
CC_NAME=voternetchaincode
CC_VERSION=${1:-"1.0"}
CC_SEQUENCE=${2:-"1"}
CHANNEL_NAME=votingchannel
rm ${CC_NAME}.tar.gz

echo "Packaging chain code: "
./bin/peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ../chaincode --label ${CC_NAME}_${CC_VERSION}

setInvestorVars() {
  export CORE_PEER_TLS_ENABLED=true
  export ORDERER_CA=../organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export CORE_PEER_LOCALMSPID="InvestorOrgMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=../organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=../organizations/fabric-ca/investorOrg/users/Admin@investorOrg.voternet.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
}

setManagementVars() {
  export CORE_PEER_TLS_ENABLED=true
  export ORDERER_CA=../organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export CORE_PEER_LOCALMSPID="ManagementOrgMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=../organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=../organizations/fabric-ca/managementOrg/users/Admin@managementOrg.voternet.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "$2"
    exit 1
  fi
}

echo "Install  chain code for investorOrg "
setInvestorVars
./bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz
res=$?
verifyResult $res "Chaincode installation on peer0.investorOrg has failed"

CC_PACKAGE_ID=$(./bin/peer lifecycle chaincode queryinstalled | sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}")
res=$?

verifyResult $res "Query installed on peer0.investorOrg has failed"

./bin/peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tls --cafile $ORDERER_CA
res=$?
verifyResult $res "Chaincode appproval on peer0.investorOrg has failed"

./bin/peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence $CC_SEQUENCE
res=$?
verifyResult $res "Chaincode checkcommitreadiness on peer0.investorOrg has failed"

echo "Install  chain code for managementOrg "
setManagementVars

./bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz
res=$?
verifyResult $res "Chaincode installation on peer0.managementOrg has failed"
CC_PACKAGE_ID1=$(./bin/peer lifecycle chaincode queryinstalled | sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}")
res=$?
verifyResult $res "Query installed on peer0.managementOrg has failed"
./bin/peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tls --cafile $ORDERER_CA
res=$?
verifyResult $res "Chaincode appproval on peer0.managementOrg has failed"
./bin/peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence $CC_SEQUENCE
res=$?
verifyResult $res "Chaincode checkcommitreadiness on peer0.managementOrg has failed"

CORE_PEER_TLS_MGMT_ROOTCERT_FILE=./organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/ca.crt
CORE_PEER_TLS_INVST_ROOTCERT_FILE=./organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/ca.crt

set -x
./bin/peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence $CC_SEQUENCE --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_INVST_ROOTCERT_FILE --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_MGMT_ROOTCERT_FILE
res=$?
set +x
verifyResult $res "Chaincode definition commit failed "

set -x
./bin/peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}
set +x
res=$?
verifyResult $res "Chaincode querycommitted failed "


set -x
./bin/peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_INVST_ROOTCERT_FILE --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_MGMT_ROOTCERT_FILE -c '{"function":"LiveTest","Args":[]}'
set +x
res=$?
verifyResult $res "Chaincode invoke failed "
