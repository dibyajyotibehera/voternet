# Create a chain code

## Till now ..

We have created a  fabric network with 2 organisations and also a channels where these 2 orgs participate for the voting process. Also majority \( majority of 2 org is 2\) endorsement is required to for any transaction result to be committed to the result

## Next

We will write a chaincode for casting a vote for a candidate

* We create a voteContract.go file
* In fabric a smart contract has to implement contractapi.ContractInterface . The easiest way to do so is by embedding contractapi.Contract struct in our custom contract.
* The cast api takes in TransactionContextInterface from fabric-contract-api-go/contractapi which gives us apis to modify the ledger and other relevant fields for a vote. Note in fabric a chaincode method we can only pass primitive types \(bool, float32,int etc\) or a struct which has primitive fields
* 1 -  first we create a composite key \(here its with voterid field but we can use multiple fields also\)- Think of it as primary key for of the vote collections. all crud operations on "vote" will be by using this key.
* 2 - we check if there is a vote with this key in the world state. We return an error if the vote exists for this key
* 3 - we create this vote in the world state

```text
voteContract.go

type VoteContract struct {
	contractapi.Contract
}

func (v *VoteContract) Cast(ctx contractapi.TransactionContextInterface,
   voterid string, issueDateTime string, candidateid string, voteid string) error {
   vote := Vote{
      Voteid:        voteid,
      Voterid:       voterid,
      IssueDateTime: issueDateTime,
      Candidateid:   candidateid,
   }
   key, err := ctx.GetStub().CreateCompositeKey("vote", []string{voterid}) ---> 1  
   if err != nil {
      return xerrors.Errorf("unable to create key %w", err)
   }

   state, err := ctx.GetStub().GetState(key) ----> 2
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

   err = ctx.GetStub().PutState(key, bytes) .----> 3 
   if err != nil {
      return xerrors.Errorf("unable to update state %w", err)
   }

   return nil
}
```

 

## The tests

{% hint style="info" %}
We have used [mockery](https://github.com/vektra/mockery) to generate mocks for the interfaces we are going to use  
{% endhint %}

First lets us write test to verify our expectation

**Test - 1** is a simple test to assert no error are returned if  fabric apis do not error

```text
func TestVoteContract_Cast(t *testing.T) {
   voteContract := vote.VoteContract{}
   mockTrxCtx := &mocks.VoterNetTransactionContextInterface{}
   mockStub := &mocks.ChaincodeStubInterface{}
   mockTrxCtx.On("GetStub").Return(mockStub)
   mockTrxCtx.On("IncrVoteCountForCand", "candidate1").Return()
   mockStub.On("CreateCompositeKey", "vote", []string{"voterId1"}).Return("key1", nil)
   mockStub.On("GetState", "key1").Return(nil, nil)
   mockStub.On("PutState", "key1", mock.AnythingOfType("[]uint8")).Return(nil, nil)
   err := voteContract.Cast(mockTrxCtx, "voterId1", "2021-06-05", "candidate1", "vote1")
   require.NoError(t, err)
}
```

 **Test-2  -** is to verify that the same user identified by user-id field cannot vote again



```text
func TestVoteContract_Cast_DoesnotAllowDuplicateVote(t *testing.T) {
   voteContract := vote.VoteContract{}
   mockTrxCtx := &mocks.VoterNetTransactionContextInterface{}
   mockStub := &mocks.ChaincodeStubInterface{}
   mockTrxCtx.On("GetStub").Return(mockStub)
   mockTrxCtx.On("IncrVoteCountForCand", "candidate1").Return()
   mockStub.On("CreateCompositeKey", "vote", []string{"voterId1"}).Return("key1", nil)
   marshal, _ := json.Marshal(vote.Vote{})
   mockStub.On("GetState", "key1").Return(marshal, nil)

   err := voteContract.Cast(mockTrxCtx, "voterId1", "2021-06-05", "candidate1", "vote1")
   require.EqualError(t, err, "voter already voted")
}
```

 

