# Step 4 - Configure a channel

Till now ..

* We have created the docker network with fabric-ca container
* Registered and enrolled the peers and users needed for the app
* Added peer nodes and couch dbs to the docker network

Next

* we will create a channel 

## Channel

* [Channel](https://hyperledger-fabric.readthedocs.io/en/release-2.2/capabilities_concept.html) is one of the most important concepts in a fabric network
* Inshort - channel is a logical group of organisations in a fabric network which share the same ledger smart contracts
* There can be x number of  channels in a fabric network. Each has its own ledger \(& world state\) .Each channel can have y number of organisations as its participants
* Here we will create one channel with 2 orgs \(investorOrg and managementOrg\)
* Peers of each org will need to endorse a transaction before it can be added to the ledger



```text
function configureChannel() {
 ......
  createChannelGenesisBlock

  createChannel
  infoln "Channel '$CHANNEL_NAME' created"

  ## Join all the peers to the channel
  infoln "Joining investorOrg peer to the channel..."
  joinChannel investorOrg
  infoln "Joining managementOrg peer to the channel..."
  joinChannel managementOrg
```

 Lets review the script to configure the "votingChannel" 

* Downloads the fabric helper binaries - most importantly configtxgen
* Create the genesis block for the channel ledger . The configtx.yaml contains the configuration for the channel .

  ```text
  ./configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ${BLOCKFILE} -channelID $CHANNEL_NAME
  ```

  *  Amongst other important configs this has the endorsement [policies](https://hyperledger-fabric.readthedocs.io/en/release-2.2/create_channel/channel_policies.html) for transaction. Majority Endorsement means majority of orgs in the channel have to endorse the transaction to be added to ledger

   

![](../.gitbook/assets/image%20%282%29.png)

* configure channels on the ordering service

  ```text
  ./osnadmin channel join --channelID $CHANNEL_NAME --config-block ${BLOCKFILE} -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" >&log.txt 
  ```

* join both the peers to the channel  . take a note of the environment variables set before invoking peer binary. most importantly \(CORE\_PEER\* variable\) . this is how we control  for which orgs  peer invoke the peer command.

```text
./peer channel join -b $BLOCKFILE >&log.txt
```

 



