# Create application side code to invoke smartcode

We created the castvote.go as a client to invoke castvote contract in voternetchaincode.

* First create a wallet for any registered user \(user1 in this case\). a wallet is nothing but a file containing the users certs,msp info which will be used by the client app to invoke transaction .It represents the identity which invokes the transaction.
* gateway is responsible for setting up the network configuration for the transaction . Amongst other things it uses service discovery to get all the endorsers info for submitting the transaction.
* The minimal network info is provided in the config file connection.yaml
* finally  get the contract from the channel and invoke the transaction

```text
castvote.go

wallet, err := gateway.NewFileSystemWallet("wallet")

gw, err := gateway.Connect(
   gateway.WithConfig(config.FromFile(configFilePath)),
   gateway.WithIdentity(wallet, "user"),
)

network, err := gw.GetNetwork("votingchannel")

contract := network.GetContract("voternetchaincode")
result, err := contract.SubmitTransaction("Cast", voter, time.Now().String(), candidate, uuid.New().String())


```

```text
cd application  // else the filepaths will be wrong

 application % go run castvote.go user2 candidate1
 [fabsdk/core] 2021/06/22 09:59:01 UTC - cryptosuite.GetDefault -> INFO No default cryptosuite found, using default SW implementation
2021/06/22 15:29:03 

application % go run castvote.go user2 candidate1
 [fabsdk/core] 2021/06/22 09:59:11 UTC - cryptosuite.GetDefault -> INFO No default cryptosuite found, using default SW implementation
2021/06/22 15:29:11 couldnt execute transaction: Failed to submit: Multiple errors occurred: - Transaction processing for endorser [localhost:7051]: Chaincode status Code: (500) UNKNOWN. Description: voter already voted - Transaction processing for endorser [localhost:9051]: Chaincode status Code: (500) UNKNOWN. Description: voter already voted
exit status 1

```

