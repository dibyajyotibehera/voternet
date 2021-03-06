# Step 2 - Enroll organisations with Fabric CA

## Till now ..

* we have set up docker network\(voternet\) with 3 fabric ca containers via docker compose
* installed fabric-ca-client command

## Next ..

We will create identities for the different users and nodes in respective fabric ca's for all the 3 organisations that are need by the application.

Lets review  registerEnroll.sh - There are 3 functions to register the 3 organisations \(investor,management and orderer\) with 3 respective ca that were create in step 1.

```text
registerEnroll.sh

function createInvestorOrg() {
  infoln "Enrolling the CA admin"

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/fabric-ca/investorOrg/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-investorOrg --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

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
....................
```

All identity are first registered with a CA by a CA admin. This identity is then enrolled by the user of the identity.

For each organisation we register and enroll 3 identities \(user1, one org admin , and an identity for the peer node \(peer0\)\)

## Registering

The aim of registering process is to create an identity by a ca admin. The ca admin provides the id/secret pair for the identity. This id/secret pair is then .passed on to the user of identity out of band . The user then enrolls \(generates public cert and private key\) on it 

```text
fabric-ca-client register --caname ca-investorOrg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
```

 

* id.name - ID of the identity
* caname - Name of the CA to enroll within the server
* id.secret - secret of the identity
* tls.cerfiles -TLS CA root signed certificate . \(generated in step 1 when CA was created\)
* id.type -The type of the identity. There are four possible types: `peer`, `orderer`, `admin`, and `client`

{% hint style="info" %}
Even though we have not specified the host name in register command. It gets picked from fabric-ca-client-config.yaml file which we had seeded. 
{% endhint %}

## Enrolling

Once the identities are registered they can enroll themselves using the id and password recieved from CA admin.The objective is to generate the public cert and private key for the identity which can then be used by the identity for any interaction \(eg invoking transaction\).

```text
fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-investorOrg -M "${PWD}/organizations/fabric-ca/investorOrg/users/User1@investorOrg.voternet.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
```

* u - url containing id , password and ca server url
* caname - Name of the CA to enroll within the server
* M - path to MSP\(Membership provider\) folder.The MSP is special folder stucture which maps identities to roles in fabric network.This folder structure can be consumed by fabric to validate operations like adding organisations to channels
* tls.cerfiles -TLS CA root signed certificate . \(generated in step 1 when CA was created\)

{% hint style="info" %}
After invoking the voternet-starter.sh will see a folder structure like below which contains all the crypto materials for each org and its identities . This will be used the fabric transaction flow to validate the actors.

Details regarding fabric ca can be found in official [docs](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#register-an-identity)
{% endhint %}

![](../.gitbook/assets/image%20%281%29.png)

