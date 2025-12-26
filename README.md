# OnChainSentinel
This repository contains a minimal Proof of Concept demonstrating:
- Real-time behavior ingestion (Kafka)
- Risk output to a downstream Kafka topic
- Optional sink to BigQuery on Google Cloud

Architecture: Kafka → Flink (Gemini/Vertex AI) → Kafka → (optional BigQuery)

---

## SETUP

### Login to Confluent & select env/cluster

```
confluent login
```


### Environment
```
confluent environment create onchainsentinel
confluent environment list # Optional to list environments
export ENV_ID=$(confluent environment list -o json | jq -r '.[] | select(.name=="onchainsentinel") | .id')
confluent environment use $ENV_ID
confluent environment delete $ENV_ID
```



### Cluster

```
confluent kafka cluster create onchainsentinel-kafka \
  --cloud gcp \
  --region us-east1 \
  --type basic
confluent kafka cluster list # Optional to list the clusters
export KAFKA_CLUSTER_ID=$(confluent kafka cluster list -o json | jq -r 'map(select(.name=="onchainsentinel-kafka"))[0].id')
confluent kafka cluster use $KAFKA_CLUSTER_ID
```
 

### Create topics
```
kafka/create_topics.sh
```

### Create topics
```
kafka/create_schemas.sh
```

### Create Flink compute pool 
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




## Start Flink SQL shell

```
confluent flink shell --compute-pool $FLINK_POOL_ID --database $KAFKA_CLUSTER_ID
```

Note: Ctrl + Q to exit shell


# Model creation
Note: Unfortunatly we could not use managed models (available only in AWS specific region) and opt for a remote AI model

## Remote AI model Gemini AI

Generate an API Key from https://aistudio.google.com/app/apikey.

The endpoint is https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent.

Gemini models are also supported through the Gemini AI provider, which you may prefer due to integrated Google Cloud billing.

1. Create Connection

```
CREATE CONNECTION googleai_connection
WITH (
  'type' = 'googleai',
  'endpoint' = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
  'api-key' = '<your-gcp-api-key>'
);
```

```
SHOW CONNECTIONS;
```

```
DROP CONNECTION googleai_connection;
```


2. CREATE MODEL
```
CREATE MODEL model_tx_analyzer
INPUT (`text` VARCHAR(2147483647))
OUTPUT (`output` VARCHAR(2147483647))
WITH (
  'googleai.connection' = 'googleai_connection',
  'googleai.system_prompt' = 'You are a blockchain AI risk classifier.\\nClassify the following transaction as HIGH, MEDIUM, or LOW risk',
  'provider' = 'googleai',
  'task' = 'text_generation'
);
```

```
SHOW MODELS;
```


```
DROP MODEL model_tx_analyzer
```




### Apply SQL in this exact order

:> flink/01_behavior_raw.sql
:> flink/02_behavior_prompt.sql
:> flink/03_behavior_risk_scores.sql
:> flink/04_model_create_managed_gemma.sql
:> flink/05_ai_enrichment.sql


---

## TEST ROUND

### Run producer once
python kafka/producer.py

### Check enriched risk stream
confluent kafka topic consume onchainsentinel.risk.scores --from-beginning

Expected:
{"address":"0xTEST"...,"response_text":"SUSPICIOUS: abnormal burstiness"}