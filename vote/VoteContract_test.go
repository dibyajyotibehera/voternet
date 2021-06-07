package vote

import (
	"encoding/json"
	"github.com/dibyajyotibehera/voternet/vote/mocks"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
	"testing"
)

// mockery --name=VoterNetTransactionContextInterface
// mockery --srcpkg=github.com/hyperledger/fabric-chaincode-go/shim --name=ChaincodeStubInterface
func TestVoteContract_Cast(t *testing.T) {
	voteContract := VoteContract{}
	mockTrxCtx := &mocks.VoterNetTransactionContextInterface{}
	mockStub := &mocks.ChaincodeStubInterface{}
	mockTrxCtx.On("GetStub").Return(mockStub)
	mockStub.On("CreateCompositeKey", "vote", []string{"voterId1"}).Return("key1", nil)
	mockStub.On("GetState", "key1").Return(nil, nil)
	mockStub.On("PutState", "key1", mock.AnythingOfType("[]uint8")).Return(nil, nil)

	err := voteContract.Cast(mockTrxCtx, "voterId1", "2021-06-05", "candidate1", "vote1")
	require.NoError(t, err)
}

func TestVoteContract_Cast_DoesnotAllowDuplicateVote(t *testing.T) {
	voteContract := VoteContract{}
	mockTrxCtx := &mocks.VoterNetTransactionContextInterface{}
	mockStub := &mocks.ChaincodeStubInterface{}
	mockTrxCtx.On("GetStub").Return(mockStub)
	mockStub.On("CreateCompositeKey", "vote", []string{"voterId1"}).Return("key1", nil)
	marshal, _ := json.Marshal(Vote{})
	mockStub.On("GetState", "key1").Return(marshal, nil)

	err := voteContract.Cast(mockTrxCtx, "voterId1", "2021-06-05", "candidate1", "vote1")
	require.EqualError(t, err, "voter already voted")

}
