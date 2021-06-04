package vote

import "github.com/hyperledger/fabric-contract-api-go/contractapi"

type VoterNetTransactionContextInterface interface {
	contractapi.TransactionContextInterface
	GetVotedList() map[string]bool
}

type VoterNetTransactionContext struct {
	contractapi.TransactionContext
	voterlist *map[string]bool
}

func (v *VoterNetTransactionContext) GetVotedList() map[string]bool {
	return *v.voterlist
}
