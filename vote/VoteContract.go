package vote

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"golang.org/x/xerrors"
)

type VoteContract struct {
	contractapi.Contract
}

func (v *VoteContract) LiveTest() string {
	return "hi! from votecontract"
}

func (v *VoteContract) Cast(ctx contractapi.TransactionContextInterface,
	voterid string, issueDateTime string, candidateid string, voteid string) error {
	vote := Vote{
		Voteid:        voteid,
		Voterid:       voterid,
		IssueDateTime: issueDateTime,
		Candidateid:   candidateid,
	}
	key, err := ctx.GetStub().CreateCompositeKey("vote", []string{voterid})
	if err != nil {
		return xerrors.Errorf("unable to create key %w", err)
	}

	state, err := ctx.GetStub().GetState(key)
	if err != nil {
		return xerrors.Errorf("unable to get state for key %w", err)
	}
	if state != nil {
		return fmt.Errorf("voter already voted")
	}

	bytes, err := json.Marshal(vote)
	if err != nil {
		return xerrors.Errorf("unable to marshal vote %w", err)
	}

	err = ctx.GetStub().PutState(key, bytes)
	if err != nil {
		return xerrors.Errorf("unable to update state %w", err)
	}

	return nil
}

func (v *VoteContract) GetVoteCountForCand(ctx contractapi.TransactionContextInterface, candidateId string) (int64, error) {
	queryString := fmt.Sprintf("{\"selector\":{\"candidateid\":\"%s\"}}", candidateId)
	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)
	var c int64
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return 0, err
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		_, err := resultsIterator.Next()
		if err != nil {
			return 0, err
		}
		c++
	}
	return c, nil
}
