# Recap

We covered a lot of ground so far in this tutorial. Lets review.

**Setting up a Fabric Business Network**

* We created scripts to set up [Fabric CA](https://hyperledger-fabric.readthedocs.io/en/release-2.0/identity/identity.html#certificate-authorities)'s for  voternet . Fabric CAs are responsible to manage certs used all the identities \(orgs,users,nodes\) within the fabric network. Each org gets their own CA.

  In real life you will most probably use third party CAs like Verisign or GoDaddy.  

* We add scripts to register users with their roles using fabric-ca-client using the CA admin.

```text
fabric-ca-client register --caname ca-investorOrg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/investorOrg/tls-cert.pem"
```

* We then enrolled these users to generate the certs and create the [MSP](https://hyperledger-fabric.readthedocs.io/en/release-2.0/membership/membership.html) . MSP  is nothing but a folder structure within the fabric network which gives recognition to the certs generated  by CA above . In short , MSPs are the fabric component which interfaces with CAs to grant these users access to the fabric network.
* We created fabric nodes for each org using docker compose.Note-  these nodes have access to the above msp via docker mount, so then can validate the transactions.
* Then we created a [Channel](https://hyperledger-fabric.readthedocs.io/en/release-2.2/capabilities_concept.html) . A channel is a group of orgs which need participate in transactions on the fabric network. Other orgs on the network \(outside of the channel\) will not be able to access the transaction data of a channel. 
* We configured the channel with the [endorsement](https://hyperledger-fabric.readthedocs.io/en/release-2.2/developapps/endorsementpolicies.html) policies . The configs are stored in configtx.yaml.
* We added the channel configs on to the orderes and added the nodes for each org on to the channel.

**Writing the chaincode**

* **A** smart contract has to implement contractapi.ContractInterface. Easy way is to embed contractapi.Contract in your own custom contract struct.
* Create a composite key for transaction data using ctx.GetStub\(\).CreateCompositeKey api.
* Similary you can read and write to to the world state db using GetState and PutState api.
* We also wrote tests for the contract.
* We wrote a script to deploy the contract using **peer lifecycle** commands.
* We invoke the the contract using **peer chaincode invoke** command.

**Writing the application side code**

* In real world app we have to provide an application interface to invoke the transactions. Thats where this piece of code comes in.
* This client code is responsible  to the present certs of the user , and also know the network configuration of the fabric network. The network configuration is managed via the gateway module 
* Submit transaction to the fabric network using SubmitTransaction api in Gateway module

