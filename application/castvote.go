package main

import (
	"fmt"
	"github.com/google/uuid"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/gateway"
	"io/ioutil"
	"log"
	"os"
	"time"
)

func main() {
	if len(os.Args) <= 2 {
		fmt.Printf("provide voter id and candidate id like so: castvote voter1 candidate1")
		os.Exit(1)
	}

	voter := os.Args[1]
	candidate := os.Args[2]

	certPath := "../setup/organizations/fabric-ca/investorOrg/users/User1@investorOrg.voternet.com/msp/signcerts/cert.pem"
	keyDir := "../setup/organizations/fabric-ca/investorOrg/users/User1@investorOrg.voternet.com/msp/keyStore/"
	configFilePath := "../setup/organizations/fabric-ca/connection.yaml"

	wallet, err := gateway.NewFileSystemWallet("wallet")
	if err != nil {
		log.Fatalf("could not create wallet: %v", err)
	}
	if !wallet.Exists("user") {
		createWallet(certPath, keyDir, wallet)
	}

	gw, err := gateway.Connect(
		gateway.WithConfig(config.FromFile(configFilePath)),
		gateway.WithIdentity(wallet, "user"),
	)
	if err != nil {
		log.Fatalf("couldnt connect to gateway: %v", err)
	}

	defer gw.Close()

	network, err := gw.GetNetwork("votingchannel")
	if err != nil {
		log.Fatalf("couldnt connect to channel: %v", err)
	}

	contract := network.GetContract("voternetchaincode")
	result, err := contract.SubmitTransaction("Cast", voter, time.Now().String(), candidate, uuid.New().String())
	if err != nil {
		log.Fatalf("couldnt execute transaction: %v", err)
	}
	log.Println(string(result))
}

func createWallet(certPath string, keyDir string, wallet *gateway.Wallet) {
	cert, err := ioutil.ReadFile(certPath)
	if err != nil {
		log.Fatalf("could not read cert: %v", err)
	}

	files, err := ioutil.ReadDir(keyDir)
	if err != nil {
		log.Fatalf("could not read key dir: %v", err)
	}

	key, err := ioutil.ReadFile(keyDir + files[0].Name())
	if err != nil {
		log.Fatalf("could not read key file: %v", err)
	}

	err = wallet.Put("user", gateway.NewX509Identity("InvestorOrgMSP", string(cert), string(key)))
	if err != nil {
		log.Fatalf("could not read update wallet: %v", err)
	}
}
