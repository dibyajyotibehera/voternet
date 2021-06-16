# What just happened

So what really happened when we ran the "peer chaincode" invoke command . How is this app different from a simple crud api on a database. Well here is what happened behind the scenes :

* Peer cli \(client\) sends the transaction request to InvestorOrg Peer and ManagementOrg. This is needed because our endorsement policy states that we need approval from both peers must endorse the transaction . A transaction proposal is generated and sent to the peers using  gRPC
* The endorsing peers validate and execute the transaction \( remember we had deployed the go chain-code on to the endorsing pears earlier\). The peers execute the transaction according to the current world - state . **However they do not update the ledger** . The pass-back the transaction result to the client.
* The client check the response and validates that the endorsement criteria has been satisfied.
* If all seems ok , client sends the transaction request and response to the ordering service \(remember we specified the ordering service in the peer cli command\)
* The ordering service compiles the transactions into a **"block"**.  
* The **block**  is send to **all \(** not just the endorsing one's\) on the channel.The peers do another round of validation to check if any thing has change in the mean\(in state db\) and tag it as valid or invalid
* The valid blocks are committed to the ledger and the world state is updated  by the peer. 
*  An event is emitted by each peer to the client to notify that the transaction has been processed .

{% hint style="info" %}
It worth while to review the detailed [transaction flow](https://hyperledger-fabric.readthedocs.io/en/release-2.2/txflow.html?highlight=transaction%20flow#transaction-flow) explained in the fabric docs.
{% endhint %}

