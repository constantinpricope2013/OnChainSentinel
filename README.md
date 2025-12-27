

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/logo-light.png">
  <img alt="OnChainSentinel Logo" src="assets/logo-light.png" width="300">
</picture>


## 📝 Description
This repository contains a minimal Proof of Concept demonstrating:
- Real-time behavior ingestion (Kafka)
- Risk assesment through Gemini API remote model

# Architecture
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/arhitecture-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/arhitecture-light.png">
  <img alt="OnChainSentinel Logo" src="assets/arhitecture-light.png" width="300">
</picture>

---

# 🛠️ SETUP

For this project we use confluent and google cloud (gcloud) cli.

As components we use:
1. Confluent Cloud 
 - Kafka 
 - Flink AI
2. Google Cloud Platform 
  - Gemini API exposure
  - Cloud Run
  - BigTables


Extra details:
 We created schemas, logo using draw.io (Check ./assets/OnChainSentinel.drawio)




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


# ֎ Model creation
Note: Unfortunatly we could not use managed models (available only in AWS specific region) and opt for a remote AI model

## 🔌 Remote AI model Gemini AI

Generate an API Key from https://aistudio.google.com/app/apikey.

The endpoint is https://generativelanguage.googleapis.com/v1beta/models/gemini-3.0-flash:generateContent.

Gemini models are also supported through the Gemini AI provider, which you may prefer due to integrated Google Cloud billing.

1. Create Connection

```
CREATE CONNECTION googleai_connection
WITH (
  'type' = 'googleai',
  'endpoint' = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.0-flash:generateContent',
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
INPUT (
    chain STRING,
    txId STRING,
    address STRING,
    toAddress STRING,
    value DOUBLE,
    tx_count BIGINT,
    ts STRING
)
OUTPUT (
    risk_level STRING,
    reason STRING
)
WITH (
  'googleai.connection' = 'googleai_connection',
  'googleai.system_prompt' = 'You are a blockchain fraud risk classifier. \
Evaluate raw transaction data using faud behavioral or fraud patterns indicators. \
Classify overall risk as LOW, MEDIUM, or HIGH. ALWAYS return two fields: \
risk_level and reason (one concise sentence).',
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

---
1. flink/create_connection.sql
2. flink/create_model.sql
3. 


---

## 🧪 TEST ROUND

### Run producer once
```
python kafka/producer.py
```


### Check enriched risk stream
```
confluent kafka topic consume onchainsentinel.risk.scores --from-beginning
```


Expected:
{"address":"0xTEST"...,"response_text":"HIGH: abnormal values"}