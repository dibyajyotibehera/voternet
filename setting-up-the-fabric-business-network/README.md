# Setting up the Fabric Business Network

## Business Requirement

We are going to create a fabric smart contract to bring more transparency into corporate voting process. Most companies use some form of remote voting to achieve consensus amongst investors/shareholders , management and other related parties \(auditors etc\).There is a considerable difference between the interests of these groups. There are several problems if the corporate organisation controls the voting process.

* With one party controlling the e-voting process , there needs to 100% assurance that results have not be tampered.
* The controlling organisation will have undue advantage as it can acesss  voting results earlier than others

So , we are going to implement a fabric network involving an investor organisation and a corporate organisation.The fabric contract\(aka chaincode\) will be approved and executed by both the organisation to ensure no one has an upper hand.

## Walk through of setup script

We will walk through the shell [script](https://github.com/dibyajyotibehera/voternet/blob/master/setup/voternet-starter.sh) for automating the process of setting of the fabric network. 



{% hint style="info" %}
 This script is largely based on fabric samples setup [scripts](https://github.com/hyperledger/fabric-samples/blob/main/commercial-paper/network-starter.sh) , however its is much more simpler to grok as it targets only our business requirement.
{% endhint %}

## 







