package main

import (
	"github.com/dibyajyotibehera/voternet/vote"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

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
