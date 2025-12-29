

## 🔓 Login to Confluent & select env/cluster

```
confluent login
```


### 🏠︎ Environment
```
confluent environment create onchainsentinel
confluent environment list # Optional to list environments
export ENV_ID=$(confluent environment list -o json | jq -r '.[] | select(.name=="onchainsentinel") | .id')
confluent environment use $ENV_ID
confluent environment delete $ENV_ID
```



### ☸️ Cluster

```
confluent kafka cluster create onchainsentinel-kafka \
  --cloud gcp \
  --region us-east1 \
  --type basic
confluent kafka cluster list # Optional to list the clusters
export KAFKA_CLUSTER_ID=$(confluent kafka cluster list -o json | jq -r 'map(select(.name=="onchainsentinel-kafka"))[0].id')
confluent kafka cluster use $KAFKA_CLUSTER_ID
```
 

### 📚 Create topics
```
kafka/create_topics.sh
```

### 🗒️ Create schemas
```
kafka/create_schemas.sh
```

### 🖥️ Create Flink compute pool 
```
confluent flink compute-pool create onchainsentinel-flink --cloud gcp --region us-east1 --max-cfu 5
```

```
confluent flink compute-pool list # Optional to list compute pools
export FLINK_POOL_ID=$( confluent flink compute-pool list -o json | jq -r '.[] | select(.name=="onchainsentinel-flink") | .id'
)
confluent flink compute-pool use $FLINK_POOL_ID
confluent flink compute-pool delete $FLINK_POOL_ID
```




## </> Start Flink SQL shell

```
confluent flink shell --compute-pool $FLINK_POOL_ID --database $KAFKA_CLUSTER_ID
```

Note: Ctrl + Q to exit shell
