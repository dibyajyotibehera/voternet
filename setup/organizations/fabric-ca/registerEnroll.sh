#!/bin/bash

function createInvestorOrg() {
  infoln "Enrolling the CA admin"

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/investorOrg/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-investorOrg --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-investorOrg.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-investorOrg.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-investorOrg.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-investorOrg.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/fabric-ca/investorOrg/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-investorOrg --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-investorOrg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-investorOrg --id.name investorOrgadmin --id.secret org1adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/msp" --csr.hosts peer0.investorOrg.voternet.com --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/investorOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls" --enrollment.profile tls --csr.hosts peer0.investorOrg.voternet.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"

  cp "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/ca.crt"
  cp "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/signcerts/"* "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/server.crt"
  cp "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/keystore/"* "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/server.key"

  mkdir -p "${PWD}/organizations/fabric-ca/investorOrg/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/investorOrg/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/fabric-ca/investorOrg/tlsca"
  cp "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/investorOrg/tlsca/tlsca.investorOrg.voternet.com-cert.pem"

  mkdir -p "${PWD}/organizations/fabric-ca/investorOrg/ca"
  cp "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/msp/cacerts/"* "${PWD}/organizations/fabric-ca/investorOrg/ca/ca.investorOrg.voternet.com-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg/users/User1@investorOrg.voternet.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/investorOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/investorOrg/users/User1@investorOrg.voternet.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://investorOrgadmin:org1adminpw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg/users/Admin@investorOrg.voternet.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/investorOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/investorOrg/users/Admin@investorOrg.voternet.com/msp/config.yaml"
}

function createManagementOrg() {
 infoln "Enrolling the CA admin"

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/managementOrg/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-managementOrg --tls.certfiles "${PWD}/organizations/fabric-ca/managementOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-managementOrg.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-managementOrg.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-managementOrg.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-managementOrg.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/fabric-ca/managementOrg/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-managementOrg --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/managementOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-managementOrg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/managementOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-managementOrg --id.name managementOrgadmin --id.secret org1adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/managementOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-managementOrg -M "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/msp" --csr.hosts peer0.managementOrg.voternet.com --tls.certfiles "${PWD}/organizations/fabric-ca/managementOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/managementOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-managementOrg -M "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls" --enrollment.profile tls --csr.hosts peer0.managementOrg.voternet.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/managementOrg/tls-cert.pem"

  cp "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/ca.crt"
  cp "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/signcerts/"* "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/server.crt"
  cp "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/keystore/"* "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/server.key"

  mkdir -p "${PWD}/organizations/fabric-ca/managementOrg/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/managementOrg/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/fabric-ca/managementOrg/tlsca"
  cp "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/managementOrg/tlsca/tlsca.managementOrg.voternet.com-cert.pem"

  mkdir -p "${PWD}/organizations/fabric-ca/managementOrg/ca"
  cp "${PWD}/organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/msp/cacerts/"* "${PWD}/organizations/fabric-ca/managementOrg/ca/ca.managementOrg.voternet.com-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-managementOrg -M "${PWD}/organizations/fabric-ca/managementOrg/users/User1@managementOrg.voternet.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/managementOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/managementOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/managementOrg/users/User1@managementOrg.voternet.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://managementOrgadmin:org1adminpw@localhost:8054 --caname ca-managementOrg -M "${PWD}/organizations/fabric-ca/managementOrg/users/Admin@managementOrg.voternet.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/managementOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/managementOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/managementOrg/users/Admin@managementOrg.voternet.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/fabric-ca/ordererOrg

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/ordererOrg

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/fabric-ca/ordererOrg/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/ordererOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/fabric-ca/ordererOrg/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/ordererOrg/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/fabric-ca/ordererOrg/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/ordererOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/ordererOrg/users/Admin@example.com/msp/config.yaml"
}
