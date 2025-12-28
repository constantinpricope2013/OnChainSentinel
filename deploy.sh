
# !/bin/bash


# Step 1. Create env
confluent environment create onchainsentinel
export ENV_ID=$(confluent environment list -o json | jq -r '.[] | select(.name=="onchainsentinel") | .id')
confluent environment use $ENV_ID
echo "✅ Step 1. Environment $ENV_ID Created"


# Step 2 Create cluste 
confluent kafka cluster create onchainsentinel-kafka \
  --cloud gcp \
  --region us-east1 \
  --type basic
export KAFKA_CLUSTER_ID=$(confluent kafka cluster list -o json \
  | jq -r 'map(select(.name=="onchainsentinel-kafka"))[0].id')
confluent kafka cluster use $KAFKA_CLUSTER_ID
echo "✅ Step 2. Kafka Cluster $KAFKA_CLUSTER_ID Created"


# Step 3. Create Flink compute pool 
confluent flink compute-pool create onchainsentinel-flink --cloud gcp --region us-east1 --max-cfu 5
export FLINK_POOL_ID=$(
  confluent flink compute-pool list -o json \
    | jq -r '.[] | select(.name=="onchainsentinel-flink") | .id'
)
confluent flink compute-pool use $FLINK_POOL_ID
echo "✅ Step 2. Flink compute pool $FLINK_POOL_ID created"

