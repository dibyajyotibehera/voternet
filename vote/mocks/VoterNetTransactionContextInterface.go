// Code generated by mockery v2.8.0. DO NOT EDIT.

package mocks

import (
	cid "github.com/hyperledger/fabric-chaincode-go/pkg/cid"
	mock "github.com/stretchr/testify/mock"

	shim "github.com/hyperledger/fabric-chaincode-go/shim"
)

// VoterNetTransactionContextInterface is an autogenerated mock type for the VoterNetTransactionContextInterface type
type VoterNetTransactionContextInterface struct {
	mock.Mock
}

// GetClientIdentity provides a mock function with given fields:
func (_m *VoterNetTransactionContextInterface) GetClientIdentity() cid.ClientIdentity {
	ret := _m.Called()

	var r0 cid.ClientIdentity
	if rf, ok := ret.Get(0).(func() cid.ClientIdentity); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(cid.ClientIdentity)
		}
	}

	return r0
}

// GetStub provides a mock function with given fields:
func (_m *VoterNetTransactionContextInterface) GetStub() shim.ChaincodeStubInterface {
	ret := _m.Called()

	var r0 shim.ChaincodeStubInterface
	if rf, ok := ret.Get(0).(func() shim.ChaincodeStubInterface); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(shim.ChaincodeStubInterface)
		}
	}

	return r0
}

// GetVotedList provides a mock function with given fields:
func (_m *VoterNetTransactionContextInterface) GetVotedList() map[string]bool {
	ret := _m.Called()

	var r0 map[string]bool
	if rf, ok := ret.Get(0).(func() map[string]bool); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(map[string]bool)
		}
	}

	return r0
}
