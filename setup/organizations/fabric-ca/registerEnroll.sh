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
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/msp" --csr.hosts peer0.org1.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/investorOrg/msp/config.yaml" "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls" --enrollment.profile tls --csr.hosts peer0.investorOrg.voternet.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/tls/ca.crt"
  cp "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/tls/signcerts/"* "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/tls/server.crt"
  cp "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/tls/keystore/"* "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/tlsca/tlsca.org1.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/ca"
  cp "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/peers/peer0.org1.example.com/msp/cacerts/"* "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/ca/ca.org1.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/users/User1@org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/msp/config.yaml" "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/users/User1@org1.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/users/Admin@org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/msp/config.yaml" "${PWD}/organizations/fabric-ca/investorOrg.voternet.com/users/Admin@org1.example.com/msp/config.yaml"
}

function createOrg2() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/fabric-ca/org2.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/org2.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-org2 --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/fabric-ca/org2.example.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/msp" --csr.hosts peer0.org2.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/org2.example.com/msp/config.yaml" "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls" --enrollment.profile tls --csr.hosts peer0.org2.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
  cp "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls/signcerts/"* "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls/server.crt"
  cp "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls/keystore/"* "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/fabric-ca/org2.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/org2.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/fabric-ca/org2.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/"* "${PWD}/organizations/fabric-ca/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/fabric-ca/org2.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/org2.example.com/peers/peer0.org2.example.com/msp/cacerts/"* "${PWD}/organizations/fabric-ca/org2.example.com/ca/ca.org2.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/fabric-ca/org2.example.com/users/User1@org2.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/org2.example.com/msp/config.yaml" "${PWD}/organizations/fabric-ca/org2.example.com/users/User1@org2.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/fabric-ca/org2.example.com/users/Admin@org2.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/fabric-ca/org2.example.com/msp/config.yaml" "${PWD}/organizations/fabric-ca/org2.example.com/users/Admin@org2.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

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
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

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
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}
