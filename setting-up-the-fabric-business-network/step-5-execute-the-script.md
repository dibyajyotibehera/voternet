# Step 5 - Execute the script

## Lets execute it 

{% hint style="info" %}
Note - all scripts are to be executed from within the setup directory
{% endhint %}

```
$ cd setup

$ ./voternet-starter.sh 
Generating certificates using Fabric CA
Creating ca_orderer       ... done
Creating ca_managementOrg ... done
Creating ca_investorOrg   ... done
Installing fabric-ca-client
Creating InvestorOrg Identities
Enrolling the CA admin

.....

$ docker ps -a
CONTAINER ID        IMAGE                               COMMAND                  CREATED             STATUS              PORTS                                            NAMES
ff20ccc25e8c        hyperledger/fabric-peer:latest      "peer node start --p…"   2 minutes ago       Up 2 minutes        0.0.0.0:7051->7051/tcp                           peer0.investorOrg.voternet.com
81afc74cbe01        hyperledger/fabric-peer:latest      "peer node start"        2 minutes ago       Up 2 minutes        7051/tcp, 0.0.0.0:9051->9051/tcp                 peer0.managementOrg.voternet.com
ad57478bee51        hyperledger/fabric-orderer:latest   "orderer"                2 minutes ago       Up 2 minutes        0.0.0.0:7050->7050/tcp, 0.0.0.0:7053->7053/tcp   orderer.example.com
80d16aed2b23        couchdb:3.1.1                       "tini -- /docker-ent…"   2 minutes ago       Up 2 minutes        4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp       couchdb0
83cbde137d79        couchdb:3.1.1                       "tini -- /docker-ent…"   2 minutes ago       Up 2 minutes        4369/tcp, 9100/tcp, 0.0.0.0:7984->5984/tcp       couchdb1
bcf68314f1ce        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   2 minutes ago       Up 2 minutes        7054/tcp, 0.0.0.0:9054->9054/tcp                 ca_orderer
aad19ed2fdf0        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   2 minutes ago       Up 2 minutes        0.0.0.0:7054->7054/tcp                           ca_investorOrg
38e591295a47        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   2 minutes ago       Up 2 minutes        7054/tcp, 0.0.0.0:8054->8054/tcp                 ca_managementOrg


```

{% hint style="info" %}
 Execute the voternet-starter.sh script  from within the setup directory and observe the logs for any errors.

at the end of the script you can check the various containers created in the voternet networj \(3 CA ,2 peers,2 couchdbs and one orderer.
{% endhint %}

Once you have verified the setup we can bring down the environment with voternet-cleanup.sh

{% code title="setup" %}
```bash
./voternet-cleanup.sh
Stopping peer0.investorOrg.voternet.com   ... done
Stopping peer0.managementOrg.voternet.com ... done
Stopping orderer.example.com              ... done
Stopping couchdb0                         ... done
Stopping couchdb1                         ... done
Stopping ca_orderer                       ... done
Stopping ca_investorOrg                   ... done
Stopping ca_managementOrg                 ... done
Removing peer0.investorOrg.voternet.com   ... done
Removing peer0.managementOrg.voternet.com ... done
Removing orderer.example.com              ... done
Removing couchdb0                         ... done
Removing couchdb1                         ... done
Removing ca_orderer                       ... done
Removing ca_investorOrg                   ... done
Removing ca_managementOrg                 ... done


```
{% endcode %}

{% hint style="info" %}
There is also a script monitordocker.sh  &lt;docker\_network&gt; script that you can run in another terminal to aggregate logs from docker container. This is helpful in triaging  any errors during container startup.

./monitordocker.sh voternet
{% endhint %}

