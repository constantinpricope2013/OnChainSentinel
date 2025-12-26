
# !/bin/bash


# Step 1. Create env
confluent environment create onchainsentinel
echo "✅ Step 1. Environment Created"


# Step 2 Create cluste 
confluent kafka cluster create onchainsentinel-kafka \
  --cloud gcp \
  --region us-east1 \
  --type basic
echo "✅ Step 2. Kafka Cluster Created"


# Step 3. Create Flink compute pool 
confluent flink compute-pool create onchainsentinel-flink --cloud gcp --region us-east1 --max-cfu 5
echo "✅ Step 2. Flink compute pool created"

# Step 4. Create Kafka topic - we should wait so that kafka is ready

