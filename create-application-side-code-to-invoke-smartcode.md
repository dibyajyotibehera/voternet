# Create application side code to invoke smartcode



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
cd application 

 application % go run castvote.go user2 candidate1
 [fabsdk/core] 2021/06/22 09:59:01 UTC - cryptosuite.GetDefault -> INFO No default cryptosuite found, using default SW implementation
2021/06/22 15:29:03 

application % go run castvote.go user2 candidate1
 [fabsdk/core] 2021/06/22 09:59:11 UTC - cryptosuite.GetDefault -> INFO No default cryptosuite found, using default SW implementation
2021/06/22 15:29:11 couldnt execute transaction: Failed to submit: Multiple errors occurred: - Transaction processing for endorser [localhost:7051]: Chaincode status Code: (500) UNKNOWN. Description: voter already voted - Transaction processing for endorser [localhost:9051]: Chaincode status Code: (500) UNKNOWN. Description: voter already voted
exit status 1

```

