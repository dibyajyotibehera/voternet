# Deploy and invoke the chain code

Here is out  main method which will be starting the chaincode when we deploy it to fabric runtime on peer nodes

```text
main.go

func main() {
   voteContract := new(vote.VoteContract)
   chaincode, err := contractapi.NewChaincode(voteContract)
   if err != nil {
      panic(err)
   }

   err = chaincode.Start()
   if err != nil {
      panic(err.Error())
   }
}
```

 

## Waltkthrough of deployment script

To deploy a chaincode is no trivial task :\). It has to go through a set of peer [lifecycle stages](https://hyperledger-fabric.readthedocs.io/en/release-2.2/chaincode_lifecycle.html) before it can run on peer nodes . This is intentional so that all parties \(investorOrg and managementOrg in this case\) approve the definition of chaincode. Lets walk through the script used for deploying which does that  voter-net chaincode\(voternet-deployChainCode.sh\) .

**Step 1 -** First we compile and package the  golang code into a tar.gz file . Apart from name of chain code we have to give version and sequence of chaincode , which we have to increment we edit and redeploy the chaincode again. version is a string we use for our tacking purposes \(eg 1.0 or 1.0.1\) , sequence is an int used by fabric to track how many times it has been redefined

```text
voternet-deployChainCode.sh
------------
CC_NAME=voternetchaincode
CC_VERSION=${1:-"1.0"}
CC_SEQUENCE=${2:-"1"}
./bin/peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ../chaincode --label ${CC_NAME}_${CC_VERSION}
```

 **Step 2 -**   install chain code on both peers \( to do so we need to set the right env variables - look at setInvestorVars and setManagementVars methods\)

```text
./bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz
```

 **Step 3** - approve the chaincode with **approveformyorg** sub-command . However we need to get the package id for the installed chaincode , which we get by **queryinstalled** sub command .

```text
CC_PACKAGE_ID=$(./bin/peer lifecycle chaincode queryinstalled | sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}")
res=$?


./bin/peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tls --cafile $ORDERER_CA
res=$?
```

 **Step 4 -**  check if the chaincode has been approved by all orgs as per the policy in the channel \(in this case both orgs need to approve it before it can be activated\)

```text
./bin/peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence $CC_SEQUENCE
```

 **Step 5** - Finally send the commit transaction to the order node \(abbreviated explanation - it goes through the whole transaction flow actually\).\(for fabric, chaincode installation is also a transaction\) This finishes the "installation"  process . 

Also verify if the commit succeeded

```text
./bin/peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence $CC_SEQUENCE --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_INVST_ROOTCERT_FILE --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_MGMT_ROOTCERT_FILE
./bin/peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}
```

**Step 6 -** Finally we invoke a dummy chaincode method to see if the chaincode is accessible . This of it like  a liveliness test for microservices.

```text
./bin/peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_INVST_ROOTCERT_FILE --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_MGMT_ROOTCERT_FILE -c '{"function":"LiveTest","Args":[]}'
```

## Lets now invoke the deploy script

As usual we run the script from inside the setup directory 

```text
# in setup dir now
./voternet-deployChainCode.sh 

# or if we are redeploying then something like this

./voternet-deployChainCode.sh 2 2
```

If  chain code is deployed successfully , it will print the repsonse from LiveTest function

```text
2021-06-14 19:35:51.179 IST [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200 payload:"hi! from votecontract" 
+
```

{% hint style="info" %}
Also please check you docker containers now . You can see a docker container for the chaincode for each peer starting with dev-peer0\*.For each chaincode deployed the fabric peers creates a docker container which execute chaincode contracts
{% endhint %}

```text
docker ps -a
CONTAINER ID        IMAGE                                                                                                                                                                                        COMMAND                  CREATED             STATUS              PORTS                                            NAMES
0446c048e397        dev-peer0.investororg.voternet.com-voternetchaincode_3-b5cc13de5b9973d4a37a794e7c634518f7083e3cc99051b6207a8a8700a9724e-94cf24f61e4e48eebab89c058de7ef8d41757239542216c9c4e03a5e4dfbd1bc     "chaincode -peer.add???"   24 minutes ago      Up 24 minutes                                                        dev-peer0.investorOrg.voternet.com-voternetchaincode_3-b5cc13de5b9973d4a37a794e7c634518f7083e3cc99051b6207a8a8700a9724e
c9387f221096        dev-peer0.managementorg.voternet.com-voternetchaincode_3-b5cc13de5b9973d4a37a794e7c634518f7083e3cc99051b6207a8a8700a9724e-59467f8a3a1b039a7aa83bdfbd923a24e1b9e2a65e5a963927fa342e8c892f2c   "chaincode -peer.add???"   24 minutes ago      Up 24 minutes                                                        dev-peer0.managementOrg.voternet.com-voternetchaincode_3-b5cc13de5b9973d4a37a794e7c634518f7083e3cc99051b6207a8a8700a9724e

```

## Invoking the chaincode contract

```text
CORE_PEER_TLS_ENABLED=true CORE_PEER_TLS_ROOTCERT_FILE=../organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/ca.crt CORE_PEER_MSPCONFIGPATH=../organizations/fabric-ca/investorOrg/users/User1@investorOrg.voternet.com/msp CORE_PEER_LOCALMSPID="InvestorOrgMSP" ORDERER_CA=../organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem FABRIC_CFG_PATH=./config ./bin/peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ../organizations/fabric-ca/ordererOrg/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C votingchannel -n voternetchaincode --peerAddresses localhost:7051 --tlsRootCertFiles ./organizations/fabric-ca/investorOrg/peers/peer0.investorOrg.voternet.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ./organizations/fabric-ca/managementOrg/peers/peer0.managementOrg.voternet.com/tls/ca.crt -c '{"function":"Cast","Args":["voterid6", "2021-06-05:12:05", "candidateid1", "voteid-1"]}'
```

Execute the above command to cast a vote for user . Lets now deconstruct the command 

There are couple of env vars need for the peer invoke subcommand to work , \(Worth taking a look at the tls configuration [document](https://hyperledger-fabric.readthedocs.io/en/release-2.2/enable_tls.html) here.

* CORE\_PEER\_TLS\_ENABLED  - Indicate peer node needs tls for connection
* CORE\_PEER\_TLS\_ROOTCERT\_FILE - path of tls cert for peer
* CORE\_PEER\_MSPCONFIGPATH - path of msp folder - \(note  we are pointing to User1 , but any other user like admin will also work\)
*  ORDERER\_CA -  path of  cert for orderer
* FABRIC\_CFG\_PATH -  default config directory for running peer cli command

Now lets look at the peer chaincode invoke subcommand arguments

* -o - Ordering service endpoint
* ordererTLSHostnameOverride -The hostname override to use when validating the TLS connection to the orderer
* cafile - cert for orderer node
* C - the channel id
* n - chaincode id
* peerAddresses - address of peer node \(note we supply both the peer nodes since our chaincode needs to be endorsed by both orgs\)
* tlsRootCertFiles - certfiles for peers
* c - the command string in json format - \(note how we supply the function name and  arguments

if the invocation is successful you can see an output like this : If you see an error \( use monitordocker.sh in another terminal to get the peer logs and triage as explained earlier\)

```text
2021-06-16 13:01:38.700 IST [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200 
```

{% hint style="info" %}
if you try the same command again , you can see an error this time as expected

Error: endorsement failure during invoke. response: status:500 message:"voter already voted"

Try and invoke the **GetVoteCountForCand contract to get the vote count for the candidateid**
{% endhint %}

